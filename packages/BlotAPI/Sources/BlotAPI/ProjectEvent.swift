import Foundation

/// Unknown event types are preserved for forward compatibility; consumers may skip them.
public struct ProjectEvent: Codable, Equatable, Sendable {
    public let schemaVersion: Int
    public let eventId: UUID
    public let seq: String
    public let projectId: UUID
    public let runId: UUID?
    public let entityId: UUID
    public let entityVersion: Int64
    public let occurredAt: Date
    public let type: String
    public let payload: [String: String]
    private enum CodingKeys: String, CodingKey { case schemaVersion, eventId, seq, projectId, runId, entityId, entityVersion, occurredAt, type, payload }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        schemaVersion = try c.decode(Int.self, forKey: .schemaVersion)
        eventId = try c.decode(UUID.self, forKey: .eventId)
        seq = try c.decode(String.self, forKey: .seq)
        projectId = try c.decode(UUID.self, forKey: .projectId)
        runId = try c.decodeIfPresent(UUID.self, forKey: .runId)
        entityId = try c.decode(UUID.self, forKey: .entityId)
        entityVersion = try c.decode(Int64.self, forKey: .entityVersion)
        occurredAt = try c.decode(Date.self, forKey: .occurredAt)
        type = try c.decode(String.self, forKey: .type)
        payload = try c.decode([String: String].self, forKey: .payload)
        guard schemaVersion == 1, entityVersion >= 0, let number = Int64(seq), number > 0, !type.isEmpty else {
            throw DecodingError.dataCorrupted(.init(codingPath: decoder.codingPath, debugDescription: "Invalid or unsupported event envelope"))
        }
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(schemaVersion, forKey: .schemaVersion)
        try c.encode(eventId, forKey: .eventId)
        try c.encode(seq, forKey: .seq)
        try c.encode(projectId, forKey: .projectId)
        try c.encode(runId, forKey: .runId)
        try c.encode(entityId, forKey: .entityId)
        try c.encode(entityVersion, forKey: .entityVersion)
        try c.encode(occurredAt, forKey: .occurredAt)
        try c.encode(type, forKey: .type)
        try c.encode(payload, forKey: .payload)
    }
}
