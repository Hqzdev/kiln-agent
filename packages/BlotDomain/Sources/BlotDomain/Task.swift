import Foundation

public struct Task: Codable, Equatable, Sendable {
    public let id: UUID
    public let projectId: UUID
    public let runId: UUID
    public let title: String
    public let acceptanceCriteria: [String]
    public let dependencyIds: Set<UUID>
    public let createdAt: Date
    public init(id: UUID, projectId: UUID, runId: UUID, title: String, acceptanceCriteria: [String], dependencyIds: Set<UUID>, createdAt: Date) throws {
        guard !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, !acceptanceCriteria.isEmpty, acceptanceCriteria.allSatisfy({ !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }), !dependencyIds.contains(id) else { throw DomainValidation.invalidValue }
        self.id = id
        self.projectId = projectId
        self.runId = runId
        self.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        self.acceptanceCriteria = acceptanceCriteria.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        self.dependencyIds = dependencyIds
        self.createdAt = createdAt
    }
    private enum CodingKeys: String, CodingKey { case id, projectId, runId, title, acceptanceCriteria, dependencyIds, createdAt }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(id: c.decode(UUID.self, forKey: .id), projectId: c.decode(UUID.self, forKey: .projectId), runId: c.decode(UUID.self, forKey: .runId), title: c.decode(String.self, forKey: .title), acceptanceCriteria: c.decode([String].self, forKey: .acceptanceCriteria), dependencyIds: c.decode(Set<UUID>.self, forKey: .dependencyIds), createdAt: c.decode(Date.self, forKey: .createdAt))
    }
}
