import Foundation
import Observation

@MainActor
@Observable
public final class WorkspaceCommands {
    public struct Pending: Identifiable {
        public let id = UUID()
        public let key: String
        public let type: String
        public let payload: BackendJSON
        public let projectID: UUID?
        public let version: Int64?
    }
    public private(set) var pending: [String: Pending] = [:]
    public private(set) var active: Set<String> = []
    public private(set) var error: String?
    private var epoch = UUID()
    private let client: @MainActor () -> BackendClient
    public init(client: @escaping @MainActor () -> BackendClient) { self.client = client }

    public func clear() {
        epoch = UUID()
        pending = [:]
        active = []
        error = nil
    }

    public func send(
        _ type: String, payload: BackendJSON, projectID: UUID? = nil,
        version: Int64? = nil, key: String
    ) async throws -> BackendReceipt {
        guard !active.contains(key) else { throw commandError("Дождитесь ответа на команду") }
        let command =
            pending[key]
            ?? Pending(key: key, type: type, payload: payload, projectID: projectID, version: version)
        pending[key] = command
        return try await execute(command)
    }

    @discardableResult
    public func retry(_ command: Pending) async -> BackendReceipt? {
        guard pending[command.key]?.id == command.id else { return nil }
        do { return try await execute(command) } catch { return nil /* Ошибка остаётся рядом с очередью. */ }
    }

    private func execute(_ command: Pending) async throws -> BackendReceipt {
        let originalEpoch = epoch
        guard !active.contains(command.key) else { throw commandError("Команда уже отправляется") }
        active.insert(command.key)
        error = nil
        defer { if epoch == originalEpoch { active.remove(command.key) } }
        do {
            // После обрыва повторяется точный исходный payload и тот же commandId.
            let receipt = try await client().command(
                command.type, payload: command.payload,
                projectId: command.projectID, expectedVersion: command.version, commandId: command.id)
            guard epoch == originalEpoch else { throw CancellationError() }
            pending[command.key] = nil
            return receipt
        } catch {
            if epoch == originalEpoch {
                if let failure = error as? BackendFailure, failure.isDefiniteRejection {
                    pending[command.key] = nil
                }
                self.error = error.localizedDescription
            }
            throw error
        }
    }

    private func commandError(_ text: String) -> NSError {
        NSError(domain: "BlotCommand", code: 1, userInfo: [NSLocalizedDescriptionKey: text])
    }
}
