import Foundation
import Testing

@testable import BlotAPI

@Test func commandKeepsOriginalIdentityAfterLostResponse() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = fixtureSession()
    let first = BackendClient(baseURL: URL(string: "https://fixture.invalid/fail/")!, session: session)
    try await first.persistPendingCommands(in: directory)
    let id = UUID()
    do {
        _ = try await first.command("run.create", payload: ["goal": "Original goal"], commandId: id)
        Issue.record("Expected a lost response")
    } catch {}
    #expect(
        FileManager.default.fileExists(atPath: directory.appendingPathComponent(id.uuidString + ".json").path)
    )
    let reconnected = BackendClient(
        baseURL: URL(string: "https://fixture.invalid/success/")!, session: session)
    try await reconnected.persistPendingCommands(in: directory)
    let receipts = try await reconnected.recoverPendingCommands()
    #expect(receipts.count == 1)
    #expect(receipts.first?.commandId == id)
    #expect(
        !FileManager.default.fileExists(
            atPath: directory.appendingPathComponent(id.uuidString + ".json").path))
}

@Test func confirmedRejectionDoesNotBlockFollowingRecovery() async throws {
    let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    defer { try? FileManager.default.removeItem(at: directory) }
    let session = fixtureSession()
    let first = BackendClient(baseURL: URL(string: "https://fixture.invalid/fail/")!, session: session)
    try await first.persistPendingCommands(in: directory)
    do {
        _ = try await first.command("run.pause", payload: ["id": UUID().uuidString])
        Issue.record("Expected a lost response")
    } catch {}
    let reconnected = BackendClient(
        baseURL: URL(string: "https://fixture.invalid/reject/")!, session: session)
    try await reconnected.persistPendingCommands(in: directory)
    #expect(try await reconnected.recoverPendingCommands().isEmpty)
    let rejected = try await reconnected.rejectedCommands()
    #expect(rejected.count == 1)
    #expect(rejected.first?.error.code == "version_conflict")
}

private func fixtureSession() -> URLSession {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [CommandProtocolFixture.self]
    return URLSession(configuration: configuration)
}

@MainActor @Test func workspaceCommandsKeepOriginalPayloadAndIgnoreOldAccountRetry() async throws {
    let session = fixtureSession()
    var client = BackendClient(baseURL: URL(string: "https://fixture.invalid/fail/")!, session: session)
    let commands = WorkspaceCommands(client: { client })
    do {
        _ = try await commands.send(
            "run.create", payload: .object(["goal": .string("Original")]), key: "create")
        Issue.record("Expected network failure")
    } catch {}
    let pending = try #require(commands.pending["create"])
    #expect(pending.payload.text("goal") == "Original")
    client = BackendClient(baseURL: URL(string: "https://fixture.invalid/success/")!, session: session)
    let receipt = try await commands.send(
        "run.create", payload: .object(["goal": .string("Edited")]), key: "create")
    #expect(receipt.commandId == pending.id)
    #expect(commands.pending.isEmpty)
    commands.clear()
    await commands.retry(pending)
    #expect(commands.pending.isEmpty)
    #expect(commands.active.isEmpty)
}

@Test func synchronizationReportsLostConnectionInsteadOfShowingStaleDataAsLive() async throws {
    let client = BackendClient(
        baseURL: URL(string: "https://fixture.invalid/fail/")!, session: fixtureSession())
    for try await update in BackendSynchronization(client: client).updates().prefix(1) {
        guard case .connectionLost(let description) = update else {
            Issue.record("Expected connection error")
            return
        }
        #expect(!description.isEmpty)
    }
}

private final class CommandProtocolFixture: URLProtocol, @unchecked Sendable {
    override class func canInit(with request: URLRequest) -> Bool { request.url?.host == "fixture.invalid" }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }
    override func stopLoading() {}
    override func startLoading() {
        guard let url = request.url else { return }
        if url.path.hasPrefix("/fail/") {
            client?.urlProtocol(self, didFailWithError: URLError(.networkConnectionLost))
            return
        }
        do {
            let status: Int
            let response: [String: Any]
            if url.path.hasPrefix("/reject/") {
                status = 409
                response = ["code": "version_conflict", "message": "Refresh the version"]
            } else {
                let value = try JSONSerialization.jsonObject(with: body()) as? [String: Any]
                guard let id = value?["commandId"] as? String else { throw URLError(.cannotParseResponse) }
                status = 202
                response = ["commandId": id, "decision": "accepted", "operationId": id, "result": NSNull()]
            }
            let http = HTTPURLResponse(
                url: url, statusCode: status, httpVersion: "HTTP/1.1",
                headerFields: ["Content-Type": "application/json"])!
            client?.urlProtocol(self, didReceive: http, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: try JSONSerialization.data(withJSONObject: response))
            client?.urlProtocolDidFinishLoading(self)
        } catch { client?.urlProtocol(self, didFailWithError: error) }
    }
    private func body() -> Data {
        if let data = request.httpBody { return data }
        guard let stream = request.httpBodyStream else { return Data() }
        stream.open()
        defer { stream.close() }
        var result = Data()
        var buffer = [UInt8](repeating: 0, count: 1024)
        while true {
            let count = stream.read(&buffer, maxLength: 1024)
            if count <= 0 { break }
            result.append(contentsOf: buffer.prefix(count))
        }
        return result
    }
}
