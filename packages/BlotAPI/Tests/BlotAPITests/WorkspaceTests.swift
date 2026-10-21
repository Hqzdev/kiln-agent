import Foundation
import Testing

@testable import BlotAPI

@Test func workspaceRejectsForeignRecordsAndKeepsNewerVersions() throws {
    let owner = UUID()
    let id = UUID()
    var records = WorkspaceRecords(ownerID: owner)
    let current = try workspaceRow(owner: owner, id: id, version: 4, fields: ["status": "RUNNING"])
    try records.save("RUN", current)
    try records.save("RUN", workspaceRow(owner: owner, id: id, version: 2, fields: ["status": "PLANNING"]))
    #expect(records.find("RUN", id: id)?.version == 4)
    let older = BackendSnapshot(
        schemaVersion: 2, watermark: "8",
        records: ["RUN": [try workspaceRow(owner: owner, id: id, version: 3)]], nextCursors: nil)
    try records.install(older, preservingNewer: true)
    #expect(records.find("RUN", id: id)?.data.text("status") == "RUNNING")
    #expect(throws: (any Error).self) { try records.save("RUN", workspaceRow(owner: UUID(), id: UUID())) }
    #expect(records.rows("RUN").count == 1)
}

@Test func projectRemovalClearsChildrenAndPreservesOtherProjectsAndGlobalSkills() throws {
    let owner = UUID()
    let project = UUID()
    let other = UUID()
    let task = UUID()
    let skill = UUID()
    var records = WorkspaceRecords(ownerID: owner)
    try records.save("PROJECT", workspaceRow(owner: owner, id: project))
    try records.save("PROJECT", workspaceRow(owner: owner, id: other))
    try records.save("TASK", workspaceRow(owner: owner, id: task, project: project))
    try records.save("SKILL", workspaceRow(owner: owner, id: skill))
    records.remove("PROJECT", id: project)
    #expect(records.find("PROJECT", id: project) == nil)
    #expect(records.find("TASK", id: task) == nil)
    #expect(records.find("PROJECT", id: other) != nil)
    #expect(records.find("SKILL", id: skill) != nil)
}

@Test func graphUsesRecordedSourcesAndKeepsTwoSessionsWithTheSameRole() throws {
    let owner = UUID()
    let project = UUID()
    let run = UUID()
    let firstTask = UUID()
    let secondTask = UUID()
    let author = UUID()
    let child = UUID()
    let unrelated = UUID()
    let assignment = UUID()
    let inbox = UUID()
    let review = UUID()
    var records = WorkspaceRecords(ownerID: owner)
    try records.save(
        "TASK",
        workspaceRow(
            owner: owner, id: firstTask, project: project, parent: run,
            fields: ["title": "First", "role": "BACKEND", "dependencies": []]))
    try records.save(
        "TASK",
        workspaceRow(
            owner: owner, id: secondTask, project: project, parent: run,
            fields: ["title": "Second", "dependencies": [firstTask.uuidString, UUID().uuidString]]))
    try records.save(
        "AGENT_SESSION",
        workspaceRow(
            owner: owner, id: author, project: project, parent: run,
            fields: ["role": "BACKEND", "status": "RUNNING"]))
    try records.save(
        "AGENT_SESSION",
        workspaceRow(
            owner: owner, id: child, project: project, parent: run,
            fields: ["role": "BACKEND", "parentSessionId": author.uuidString, "status": "QUEUED"]))
    try records.save(
        "AGENT_SESSION",
        workspaceRow(owner: owner, id: unrelated, parent: UUID(), fields: ["role": "BACKEND"]))
    try records.save(
        "ASSIGNMENT",
        workspaceRow(
            owner: owner, id: assignment,
            fields: ["taskId": firstTask.uuidString, "sessionId": author.uuidString]))
    try records.save(
        "INBOX",
        workspaceRow(
            owner: owner, id: inbox,
            fields: [
                "senderSessionId": author.uuidString, "recipientSessionId": child.uuidString,
                "processed": false,
            ]))
    try records.save(
        "REVIEW",
        workspaceRow(
            owner: owner, id: review,
            fields: [
                "authorSessionId": author.uuidString, "reviewerSessionId": child.uuidString,
                "decision": "accepted",
            ]))
    let communication = WorkspaceGraph(records: records, runID: run, mode: .communication)
    #expect(communication.nodes.filter { $0.kind == "AGENT_SESSION" }.count == 2)
    #expect(communication.edges.count == 3)
    #expect(communication.edges.allSatisfy { records.find($0.sourceKind, id: $0.sourceID) != nil })
    #expect(!communication.nodes.contains { $0.recordID == unrelated })
    let organization = WorkspaceGraph(records: records, runID: run, mode: .organization)
    #expect(organization.edges.contains { $0.sourceKind == "AGENT_SESSION" && $0.sourceID == child })
    let dependencies = WorkspaceGraph(records: records, runID: run, mode: .dependencies)
    #expect(dependencies.nodes.count == 2)
    #expect(dependencies.edges.count == 1)
    #expect(dependencies.edges.first?.sourceID == secondTask)
    #expect(WorkspaceGraph(records: records, runID: UUID(), mode: .organization).nodes.isEmpty)
}

@Test func desktopWorkspaceDecodesRealJavaSnapshotWhenProvided() throws {
    guard let directory = ProcessInfo.processInfo.environment["BLOT_HTTP_FIXTURES"] else { return }
    let url = URL(fileURLWithPath: directory).appendingPathComponent("workspace-desktop.json")
    let snapshot = try JSONDecoder().decode(BackendSnapshot.self, from: Data(contentsOf: url))
    let project = try #require(snapshot.records["PROJECT"]?.first)
    var records = WorkspaceRecords(ownerID: project.ownerId)
    try records.install(snapshot)
    #expect(records.rows("RUN").count == 2)
    #expect(records.rows("SKILL").first?.data.flag("enabled") == false)
    let automation = try #require(records.rows("AUTOMATION").first)
    #expect(automation.data.text("timezone") == "Asia/Yekaterinburg")
    let history = records.rows("CHECKPOINT", parentID: automation.id).filter {
        $0.data.text("phase") == "automation_run"
    }
    #expect(history.count == 1)
    #expect(records.find("RUN", id: history.first?.data.uuid("runId")) != nil)
    let run = try #require(records.rows("RUN").first { $0.data.text("status") == "CANCELLED" })
    let graph = WorkspaceGraph(records: records, runID: run.id, mode: .dependencies)
    #expect(graph.nodes.count == 1)
    #expect(graph.edges.isEmpty)
}

@MainActor @Test func liveWorkspaceLoadsSnapshotAndFetchesChangedRecordFromEvent() async throws {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [WorkspaceProtocolFixture.self]
    let client = BackendClient(
        baseURL: URL(string: "https://workspace.invalid/")!, token: "fixture",
        session: URLSession(configuration: configuration))
    let workspace = LiveWorkspace(client: { client })
    workspace.selectAccount(WorkspaceProtocolFixture.owner)
    let observation = _Concurrency.Task {
        await workspace.observe(client: client, ownerID: WorkspaceProtocolFixture.owner)
    }
    defer { observation.cancel() }
    for _ in 0..<200 {
        if workspace.find("RUN", WorkspaceProtocolFixture.run)?.version == 2 { break }
        try await _Concurrency.Task.sleep(for: .milliseconds(10))
    }
    #expect(workspace.find("RUN", WorkspaceProtocolFixture.run)?.data.text("status") == "RUNNING")
    #expect(workspace.cursor == 1)
    observation.cancel()
    let other = UUID()
    workspace.selectAccount(other)
    try await _Concurrency.Task.sleep(for: .milliseconds(20))
    #expect(workspace.records?.ownerID == other)
    #expect(workspace.rows("RUN").isEmpty)
    #expect(workspace.cursor == 0)
}

private final class WorkspaceProtocolFixture: URLProtocol, @unchecked Sendable {
    static let owner = UUID()
    static let run = UUID()
    override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "workspace.invalid" }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}
    override func startLoading() {
        guard let url = request.url else { return }
        do {
            let data: Data
            let contentType: String
            if url.path.hasSuffix("/snapshot") {
                let row = try workspaceRow(owner: Self.owner, id: Self.run, fields: ["status": "PLANNING"])
                data = try JSONEncoder().encode(
                    BackendSnapshot(
                        schemaVersion: 2, watermark: "0", records: ["RUN": [row]], nextCursors: nil))
                contentType = "application/json"
            } else if url.path.hasPrefix("/v2/records/RUN/") {
                data = try JSONEncoder().encode(
                    workspaceRow(owner: Self.owner, id: Self.run, version: 2, fields: ["status": "RUNNING"]))
                contentType = "application/json"
            } else {
                let event = BackendEvent(
                    schemaVersion: 2, seq: "1", eventId: UUID(), projectId: nil, type: "run.updated",
                    occurredAt: "2026-10-21T00:00:01Z", payload: .object(["id": .string(Self.run.uuidString)])
                )
                let text = String(decoding: try JSONEncoder().encode(event), as: UTF8.self)
                data = Data("data: \(text)\n\n".utf8)
                contentType = "text/event-stream"
            }
            let response = HTTPURLResponse(
                url: url, statusCode: 200, httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": contentType])!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
}

private func workspaceRow(
    owner: UUID, id: UUID, version: Int64 = 0, project: UUID? = nil, parent: UUID? = nil,
    fields: [String: Any] = [:]
) throws -> WorkspaceRow {
    var value: [String: Any] = [
        "id": id.uuidString, "ownerId": owner.uuidString, "version": version,
        "createdAt": "2026-10-21T00:00:00Z", "updatedAt": "2026-10-21T00:00:00Z", "data": fields,
    ]
    value["projectId"] = project?.uuidString
    value["parentId"] = parent?.uuidString
    return try JSONDecoder().decode(WorkspaceRow.self, from: JSONSerialization.data(withJSONObject: value))
}
