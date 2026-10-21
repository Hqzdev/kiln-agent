import Foundation

/// Только подтверждённые сервером записи. Кэш одного аккаунта не принимает чужие данные.
public struct WorkspaceRecords: Sendable {
    public let ownerID: UUID
    private var values: [String: [UUID: BackendEntity<BackendJSON>]] = [:]

    public init(ownerID: UUID) { self.ownerID = ownerID }

    public mutating func install(_ snapshot: BackendSnapshot, preservingNewer: Bool = false) throws {
        guard snapshot.schemaVersion == 2 else { throw URLError(.cannotParseResponse) }
        var next = WorkspaceRecords(ownerID: ownerID)
        for (kind, rows) in snapshot.records {
            for row in rows { try next.save(kind, row) }
        }
        if preservingNewer {
            for (kind, rows) in values {
                for row in rows.values where next.find(kind, id: row.id) != nil { try next.save(kind, row) }
            }
        }
        self = next
    }

    public mutating func save(_ kind: String, _ row: BackendEntity<BackendJSON>) throws {
        guard row.ownerId == ownerID else { throw URLError(.userAuthenticationRequired) }
        if let current = values[kind]?[row.id], current.version > row.version { return }
        values[kind, default: [:]][row.id] = row
    }

    public mutating func remove(_ kind: String, id: UUID) {
        values[kind]?[id] = nil
        if kind == "PROJECT" {
            for key in Array(values.keys) { values[key] = values[key]?.filter { $0.value.projectId != id } }
        }
    }

    public func find(_ kind: String, id: UUID?) -> BackendEntity<BackendJSON>? {
        guard let id else { return nil }
        return values[kind]?[id]
    }

    public func rows(_ kind: String, projectID: UUID? = nil, parentID: UUID? = nil) -> [BackendEntity<
        BackendJSON
    >] {
        (values[kind]?.values.map { $0 } ?? []).filter {
            (projectID == nil || $0.projectId == projectID) && (parentID == nil || $0.parentId == parentID)
        }.sorted { ($0.createdAt, $0.id.uuidString) < ($1.createdAt, $1.id.uuidString) }
    }
}
