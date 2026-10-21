import Foundation
import Observation

public typealias WorkspaceRow = BackendEntity<BackendJSON>

@MainActor
@Observable
public final class LiveWorkspace {
    public private(set) var records: WorkspaceRecords?
    public private(set) var error: String?
    public private(set) var loading = true
    public private(set) var cursor: Int64 = 0
    public let commands: WorkspaceCommands
    public private(set) var recoveringCommands = false
    public private(set) var recoveryError: String?
    private var epoch = UUID()
    private let client: @MainActor () -> BackendClient
    public init(client: @escaping @MainActor () -> BackendClient) {
        self.client = client
        self.commands = WorkspaceCommands(client: client)
    }

    public func clear() {
        epoch = UUID()
        records = nil
        commands.clear()
        error = nil
        loading = true
        cursor = 0
        recoveringCommands = false
        recoveryError = nil
    }

    public func selectAccount(_ ownerID: UUID) {
        clear()
        records = WorkspaceRecords(ownerID: ownerID)
    }
    public func beginCommandRecovery() {
        recoveringCommands = true
        recoveryError = nil
    }
    public func commandRecoveryFailed(_ description: String) {
        recoveringCommands = false
        recoveryError = description
    }
    public func recoverPendingCommands() async {
        let expected = epoch
        recoveringCommands = true
        recoveryError = nil
        do {
            _ = try await client().recoverPendingCommands()
            guard epoch == expected else { return }
            recoveringCommands = false
            await refresh()
        } catch {
            guard epoch == expected else { return }
            recoveringCommands = false
            recoveryError = error.localizedDescription
        }
    }

    public func rows(_ kind: String, projectID: UUID? = nil, parentID: UUID? = nil) -> [WorkspaceRow] {
        records?.rows(kind, projectID: projectID, parentID: parentID) ?? []
    }
    public func find(_ kind: String, _ id: UUID?) -> WorkspaceRow? { records?.find(kind, id: id) }
    public func find(_ kind: String, _ id: String) -> WorkspaceRow? { find(kind, UUID(uuidString: id)) }

    public func observe(client: BackendClient, ownerID: UUID) async {
        guard !_Concurrency.Task.isCancelled else { return }
        if records == nil { selectAccount(ownerID) }
        guard records?.ownerID == ownerID else { return }
        let observationEpoch = epoch
        while !_Concurrency.Task.isCancelled && epoch == observationEpoch {
            do {
                for try await update in BackendSynchronization(client: client).updates() {
                    try _Concurrency.Task.checkCancellation()
                    guard epoch == observationEpoch else { return }
                    switch update {
                    case .snapshot(let snapshot):
                        try records?.install(snapshot)
                        cursor = Int64(snapshot.watermark) ?? 0
                        loading = false
                        error = nil
                    case .event(let event):
                        try await apply(event, client: client, epoch: observationEpoch)
                        try _Concurrency.Task.checkCancellation()
                        guard epoch == observationEpoch else { return }
                        cursor = max(event.sequence ?? cursor, cursor)
                        error = nil
                    case .connectionLost(let description):
                        error = description
                        loading = false
                    }
                }
            } catch is CancellationError { return } catch {
                guard epoch == observationEpoch else { return }
                self.error = error.localizedDescription
                loading = false
            }
            do { try await _Concurrency.Task.sleep(for: .seconds(2)) } catch { return }
        }
    }

    private func apply(_ event: BackendEvent, client: BackendClient, epoch expected: UUID) async throws {
        let parts = event.type.split(separator: ".")
        guard parts.count == 2, let id = event.payload.uuid("id") else { return }
        let kind = parts[0].uppercased()
        if parts[1] == "deleted" {
            records?.remove(kind, id: id)
            return
        }
        guard ["created", "updated"].contains(parts[1]) else { return }
        do {
            let row = try await client.get("v2/records/\(kind)/\(id.uuidString)", as: WorkspaceRow.self)
            guard epoch == expected, !_Concurrency.Task.isCancelled else { return }
            try records?.save(kind, row)
        } catch let failure as BackendFailure where failure.httpStatus == 404 {
            guard epoch == expected else { return }
            records?.remove(kind, id: id)
        }
    }

    public func refresh() async {
        let expected = epoch
        do {
            let snapshot = try await client().snapshot()
            guard epoch == expected, !_Concurrency.Task.isCancelled else { return }
            if (Int64(snapshot.watermark) ?? 0) >= cursor {
                try records?.install(snapshot, preservingNewer: true)
            }
            loading = false
            error = nil
        } catch { if epoch == expected { self.error = error.localizedDescription } }
    }

    @discardableResult
    public func send(
        _ type: String, payload: BackendJSON, row: WorkspaceRow? = nil,
        projectID: UUID? = nil, key: String? = nil
    ) async throws -> BackendReceipt {
        guard !recoveringCommands && recoveryError == nil else {
            throw NSError(
                domain: "BlotWorkspace", code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Сначала завершите восстановление ранее отправленных команд"
                ])
        }
        let expected = epoch
        let receipt = try await commands.send(
            type, payload: payload, projectID: projectID ?? row?.projectId,
            version: row?.version, key: key ?? type + ":" + (row?.id.uuidString ?? "new"))
        await refresh()
        guard epoch == expected else { throw CancellationError() }
        return receipt
    }
}
