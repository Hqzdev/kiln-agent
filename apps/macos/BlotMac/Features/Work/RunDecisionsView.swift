import BlotAPI
import SwiftUI

struct RunDecisionsView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    private var sessionIDs: Set<UUID> { Set(app.workspace.rows("AGENT_SESSION", parentID: run.id).map(\.id)) }
    var body: some View {
        ForEach(
            app.workspace.rows("CHECKPOINT", projectID: run.projectId).filter {
                $0.data.flag("open")
                    && ($0.parentId == run.id || $0.parentId.map(sessionIDs.contains) == true)
            }, id: \.id
        ) { question in RunQuestionView(question: question) }
        ForEach(
            app.workspace.rows("PREPARED_ACTION", projectID: run.projectId).filter {
                $0.data.uuid("sessionId").map(sessionIDs.contains) == true
                    && ["PREPARED", "EXECUTING"].contains($0.data.text("status"))
            }, id: \.id
        ) { action in PreparedActionView(action: action) }
    }
}

private struct RunQuestionView: View {
    @Environment(AppState.self) private var app
    let question: WorkspaceRow
    @State private var answer = ""
    var body: some View {
        SettingsGroup(title: "Нужен ваш ответ") {
            VStack(alignment: .leading, spacing: 12) {
                Text(question.data.text("question")).textSelection(.enabled)
                ForEach(question.data.strings("options"), id: \.self) { option in
                    Button(option) { submit(option) }
                }
                TextField("Свой ответ", text: $answer, axis: .vertical)
                Button("Отправить ответ") { submit(answer) }.disabled(
                    answer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }.padding(16).disabled(!app.workspace.commands.active.isEmpty)
        }
    }
    private func submit(_ content: String) {
        Task {
            try? await app.workspace.send(
                "user.answer",
                payload: .object(["id": .string(question.id.uuidString), "answer": .string(content)]),
                row: question)
        }
    }
}

struct PreparedActionView: View {
    @Environment(AppState.self) private var app
    let action: WorkspaceRow
    private var grants: [WorkspaceRow] {
        app.workspace.rows("GRANT", parentID: action.id).filter {
            !$0.data.flag("revoked") && $0.data.integer("usesRemaining") > 0
                && $0.data.text("actionHash") == action.data.text("hash")
                && WorkspaceDate.parse($0.data.text("expiresAt")).map { $0 > Date() } == true
        }
    }
    var body: some View {
        SettingsGroup(title: "Разрешение · " + action.data.text("capability")) {
            VStack(alignment: .leading, spacing: 12) {
                Text(action.data.value("arguments").formatted).font(KFont.mono(11)).textSelection(.enabled)
                Text("SHA-256: " + action.data.text("hash")).font(KFont.mono(10)).textSelection(.enabled)
                Text("Исходный коммит: " + action.data.text("baseSha")).font(KFont.mono(10)).textSelection(
                    .enabled)
                if let artifactID = action.data.value("arguments").uuid("artifactId") {
                    ArtifactLink(id: artifactID)
                }
                if action.data.text("status") == "PREPARED" {
                    if grants.isEmpty {
                        HStack {
                            WorkspaceActionButton(
                                title: "Разрешить один раз на 5 минут", command: "permission.grant",
                                row: action,
                                payload: .object([
                                    "id": .string(action.id.uuidString), "seconds": .integer(300),
                                    "uses": .integer(1),
                                ]))
                            WorkspaceActionButton(title: "Отклонить", command: "permission.deny", row: action)
                        }
                    } else {
                        Text("Разрешение выдано для этого точного действия.").foregroundStyle(K.success)
                        if action.data.text("capability").hasPrefix("git.") {
                            WorkspaceActionButton(
                                title: "Выполнить разрешённую операцию Git", command: "git.execute",
                                row: action)
                        }
                        ForEach(grants, id: \.id) { grant in
                            WorkspaceActionButton(
                                title: "Отозвать разрешение", command: "permission.revoke", row: grant)
                        }
                    }
                } else {
                    Text("Действие выполняется…")
                }
            }.padding(16)
        }
    }
}

enum WorkspaceDate {
    static func parse(_ value: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: value) { return date }
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: value)
    }
}
