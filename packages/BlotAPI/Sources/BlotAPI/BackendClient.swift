import Foundation

/// ID команды создаётся до отправки и может повторно использоваться после обрыва.
public actor BackendClient {
    public nonisolated let baseURL: URL
    private let session: URLSession
    private var token: String?
    private var pendingDirectory: URL?

    public init(baseURL: URL, token: String? = nil, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.token = token
        self.session = session
    }

    public func useToken(_ value: String?) { if value != token { pendingDirectory = nil }; token = value }

    /// Каталог выбирает приложение для конкретной установки и аккаунта; токены сюда не записываются.
    public func persistPendingCommands(in directory: URL) throws {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
        pendingDirectory = directory
    }

    public func recoverPendingCommands() async throws -> [BackendReceipt] {
        guard let pendingDirectory else { return [] }
        let files = try FileManager.default.contentsOfDirectory(at: pendingDirectory, includingPropertiesForKeys: nil).filter { $0.pathExtension == "json" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        var result: [BackendReceipt] = []
        for file in files {
            let bytes = try Data(contentsOf: file)
            do {
                let response = try await perform("v2/commands", method: "POST", body: bytes)
                result.append(try JSONDecoder().decode(BackendReceipt.self, from: response))
                try FileManager.default.removeItem(at: file)
            } catch let failure as BackendFailure where failure.isDefiniteRejection {
                let rejected = pendingDirectory.appendingPathComponent("rejected")
                try FileManager.default.createDirectory(at: rejected, withIntermediateDirectories: true, attributes: [.posixPermissions: 0o700])
                let entry = BackendRejectedCommand(command: try JSONDecoder().decode(BackendJSON.self, from: bytes), error: failure)
                let destination = rejected.appendingPathComponent(file.lastPathComponent)
                try JSONEncoder().encode(entry).write(to: destination, options: .atomic)
                try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: destination.path)
                try FileManager.default.removeItem(at: file)
            }
        }
        return result
    }

    public func rejectedCommands() throws -> [BackendRejectedCommand] {
        guard let pendingDirectory else { return [] }
        let directory = pendingDirectory.appendingPathComponent("rejected")
        guard FileManager.default.fileExists(atPath: directory.path) else { return [] }
        return try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "json" }.map { try JSONDecoder().decode(BackendRejectedCommand.self, from: Data(contentsOf: $0)) }
    }

    public func records<Value: Codable & Sendable>(_ kind: String, projectId: UUID? = nil, parentId: UUID? = nil, as type: Value.Type) async throws -> [BackendEntity<Value>] {
        var result: [BackendEntity<Value>] = []
        var cursor: String?
        while true {
            var path = "v2/records/\(kind)?limit=500"
            if let cursor { path += "&cursor=\(cursor)" }
            if let projectId { path += "&projectId=\(projectId.uuidString)" }
            if let parentId { path += "&parentId=\(parentId.uuidString)" }
            let page = try await get(path, as: [BackendEntity<Value>].self)
            result.append(contentsOf: page)
            if page.count < 500 { return result }
            cursor = Self.cursor(page.last!)
        }
    }

    public func bytes(_ path: String) async throws -> Data { try await perform(path, method: "GET", body: nil) }

    public func get<Result: Decodable & Sendable>(_ path: String, as type: Result.Type) async throws -> Result {
        let data = try await perform(path, method: "GET", body: nil)
        return try JSONDecoder().decode(type, from: data)
    }

    public func post<Payload: Encodable & Sendable, Result: Decodable & Sendable>(
        _ path: String, body: Payload, as type: Result.Type
    ) async throws -> Result {
        let data = try await perform(path, method: "POST", body: JSONEncoder().encode(body))
        return try JSONDecoder().decode(type, from: data)
    }

    public func put<Payload: Encodable & Sendable>(_ path: String, body: Payload) async throws {
        _ = try await perform(path, method: "PUT", body: JSONEncoder().encode(body))
    }

    public func command<Payload: Encodable & Sendable>(
        _ type: String, payload: Payload, projectId: UUID? = nil,
        expectedVersion: Int64? = nil, commandId: UUID = UUID()
    ) async throws -> BackendReceipt {
        let command = CommandV2(commandId: commandId, type: type, projectId: projectId,
                                expectedVersion: expectedVersion, payload: payload)
        let bytes = try JSONEncoder().encode(command)
        let file = pendingDirectory?.appendingPathComponent(commandId.uuidString + ".json")
        if let file {
            if FileManager.default.fileExists(atPath: file.path) {
                let previous = try Data(contentsOf: file)
                let original = try JSONSerialization.jsonObject(with: previous) as? NSDictionary
                let current = try JSONSerialization.jsonObject(with: bytes) as? NSDictionary
                guard original == current else { throw URLError(.dataNotAllowed) }
            } else {
                try bytes.write(to: file, options: .atomic)
                try FileManager.default.setAttributes([.posixPermissions: 0o600], ofItemAtPath: file.path)
            }
        }
        do {
            let response = try await perform("v2/commands", method: "POST", body: bytes)
            let receipt = try JSONDecoder().decode(BackendReceipt.self, from: response)
            if let file { try FileManager.default.removeItem(at: file) }
            return receipt
        } catch let failure as BackendFailure where failure.isDefiniteRejection {
            if let file { try FileManager.default.removeItem(at: file) }
            throw failure
        }
    }

    public func snapshot() async throws -> BackendSnapshot {
        var snapshot = try await get("v2/snapshot", as: BackendSnapshot.self)
        guard snapshot.schemaVersion == 2, Int64(snapshot.watermark) != nil else { throw URLError(.cannotParseResponse) }
        for (kind, firstCursor) in snapshot.nextCursors ?? [:] {
            var cursor = firstCursor
            while true {
                let page = try await get("v2/records/\(kind)?limit=500&cursor=\(cursor)", as: [BackendEntity<BackendJSON>].self)
                snapshot.records[kind, default: []].append(contentsOf: page)
                if page.count < 500 { break }
                cursor = Self.cursor(page.last!)
            }
        }
        return snapshot
    }

    public func events(after: Int64) throws -> AsyncThrowingStream<BackendEvent, any Error> {
        guard let token else { throw URLError(.userAuthenticationRequired) }
        return BackendEventStream(session: session).events(baseURL: baseURL, token: token, after: after)
    }

    /// При перезапуске встроенного сервера сохраняем и временную сессию, и очередь команд.
    public func transferSession(to client: BackendClient) async throws {
        if let token { await client.useToken(token) }
        if let pendingDirectory { try await client.persistPendingCommands(in: pendingDirectory) }
    }

    private static func cursor<Value>(_ entity: BackendEntity<Value>) -> String {
        Data("\(entity.createdAt)\n\(entity.id.uuidString.lowercased())".utf8).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }

    private func perform(_ path: String, method: String, body: Data?) async throws -> Data {
        guard !path.hasPrefix("/"), !path.contains(".."),
              let url = URL(string: path, relativeTo: baseURL)?.absoluteURL,
              url.host == baseURL.host, url.port == baseURL.port else { throw URLError(.badURL) }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.httpBody = body
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        guard (200..<300).contains(http.statusCode) else {
            if var failure = try? JSONDecoder().decode(BackendFailure.self, from: data) { failure.httpStatus = http.statusCode; throw failure }
            throw URLError(.badServerResponse)
        }
        return data
    }
}

public struct CommandV2<Payload: Encodable & Sendable>: Encodable, Sendable {
    public let schemaVersion = 2
    public let commandId: UUID
    public let type: String
    public let projectId: UUID?
    public let expectedVersion: Int64?
    public let payload: Payload
}
