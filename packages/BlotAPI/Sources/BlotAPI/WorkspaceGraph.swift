import Foundation

public enum WorkspaceGraphMode: Sendable { case organization, communication, dependencies }

public struct WorkspaceGraphNode: Identifiable, Sendable {
    public let kind: String
    public let recordID: UUID
    public let title: String
    public let status: String
    public let role: String
    public var id: String { kind + "|" + recordID.uuidString }
}

public struct WorkspaceGraphEdge: Identifiable, Sendable {
    public let id: String
    public let from: String
    public let to: String
    public let label: String
    public let sourceKind: String
    public let sourceID: UUID
    public var source: String { sourceKind + "|" + sourceID.uuidString }
}

/// Все узлы и связи имеют источник в сохранённых данных. Пустой запуск даёт пустой граф.
public struct WorkspaceGraph: Sendable {
    public let nodes: [WorkspaceGraphNode]
    public let edges: [WorkspaceGraphEdge]

    public init(records: WorkspaceRecords, runID: UUID, mode: WorkspaceGraphMode) {
        let tasks = records.rows("TASK", parentID: runID)
        let sessions = mode == .dependencies ? [] : records.rows("AGENT_SESSION", parentID: runID)
        var nodes = tasks.map {
            WorkspaceGraphNode(
                kind: "TASK", recordID: $0.id, title: $0.data.text("title"), status: $0.data.text("status"),
                role: $0.data.text("role"))
        }
        nodes += sessions.map {
            WorkspaceGraphNode(
                kind: "AGENT_SESSION", recordID: $0.id,
                title: $0.data.text("role") + " · " + String($0.id.uuidString.prefix(8)),
                status: $0.data.text("status") + " " + $0.data.text("waitingReason"),
                role: $0.data.text("role"))
        }
        let nodeIDs = Set(nodes.map(\.id))
        var edges: [WorkspaceGraphEdge] = []
        func append(
            _ id: String, fromKind: String, from: UUID?, toKind: String, to: UUID?, label: String,
            sourceKind: String, sourceID: UUID
        ) {
            guard let from, let to else { return }
            let a = fromKind + "|" + from.uuidString
            let b = toKind + "|" + to.uuidString
            guard nodeIDs.contains(a), nodeIDs.contains(b) else { return }
            edges.append(
                WorkspaceGraphEdge(
                    id: id, from: a, to: b, label: label, sourceKind: sourceKind, sourceID: sourceID))
        }
        if mode == .dependencies {
            for task in tasks {
                for dependency in task.data.strings("dependencies") {
                    append(
                        task.id.uuidString + ":" + dependency, fromKind: "TASK",
                        from: UUID(uuidString: dependency), toKind: "TASK", to: task.id,
                        label: "Зависимость", sourceKind: "TASK", sourceID: task.id)
                }
            }
        } else {
            for assignment in records.rows("ASSIGNMENT") {
                append(
                    assignment.id.uuidString, fromKind: "TASK", from: assignment.data.uuid("taskId"),
                    toKind: "AGENT_SESSION", to: assignment.data.uuid("sessionId"),
                    label: "Назначение", sourceKind: "ASSIGNMENT", sourceID: assignment.id)
            }
            if mode == .organization {
                for session in sessions {
                    append(
                        "parent:" + session.id.uuidString, fromKind: "AGENT_SESSION",
                        from: session.data.uuid("parentSessionId"), toKind: "AGENT_SESSION", to: session.id,
                        label: "Родительская сессия", sourceKind: "AGENT_SESSION", sourceID: session.id)
                }
            } else {
                for message in records.rows("INBOX") {
                    append(
                        message.id.uuidString, fromKind: "AGENT_SESSION",
                        from: message.data.uuid("senderSessionId"), toKind: "AGENT_SESSION",
                        to: message.data.uuid("recipientSessionId"),
                        label: message.data.flag("processed") ? "Сообщение обработано" : "Входящее сообщение",
                        sourceKind: "INBOX", sourceID: message.id)
                }
                for review in records.rows("REVIEW") {
                    append(
                        review.id.uuidString, fromKind: "AGENT_SESSION",
                        from: review.data.uuid("authorSessionId"), toKind: "AGENT_SESSION",
                        to: review.data.uuid("reviewerSessionId"),
                        label: "Ревью: " + review.data.text("decision"), sourceKind: "REVIEW",
                        sourceID: review.id)
                }
            }
        }
        self.nodes = nodes
        self.edges = edges
    }
}
