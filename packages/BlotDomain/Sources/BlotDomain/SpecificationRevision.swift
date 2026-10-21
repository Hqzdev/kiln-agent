import Foundation

public struct SpecificationRevision: Codable, Equatable, Sendable {
    public let id: UUID
    public let runId: UUID
    public let revision: Int
    public let content: String
    public let createdAt: Date
    public init(id: UUID, runId: UUID, revision: Int, content: String, createdAt: Date) throws {
        guard revision >= 1, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { throw DomainValidation.invalidValue }
        self.id = id
        self.runId = runId
        self.revision = revision
        self.content = content.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = createdAt
    }
    private enum CodingKeys: String, CodingKey { case id, runId, revision, content, createdAt }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(id: c.decode(UUID.self, forKey: .id), runId: c.decode(UUID.self, forKey: .runId), revision: c.decode(Int.self, forKey: .revision), content: c.decode(String.self, forKey: .content), createdAt: c.decode(Date.self, forKey: .createdAt))
    }
}
