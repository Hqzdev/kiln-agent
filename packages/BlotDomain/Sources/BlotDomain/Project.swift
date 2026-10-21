import Foundation

public struct Project: Codable, Equatable, Sendable {
    public let id: UUID
    public let name: String
    public let repositoryPath: String
    public let createdAt: Date
    public init(id: UUID, name: String, repositoryPath: String, createdAt: Date) throws {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, repositoryPath.hasPrefix("/") else { throw DomainValidation.invalidValue }
        self.id = id
        self.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        self.repositoryPath = repositoryPath
        self.createdAt = createdAt
    }
    private enum CodingKeys: String, CodingKey { case id, name, repositoryPath, createdAt }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(id: c.decode(UUID.self, forKey: .id), name: c.decode(String.self, forKey: .name), repositoryPath: c.decode(String.self, forKey: .repositoryPath), createdAt: c.decode(Date.self, forKey: .createdAt))
    }
}
