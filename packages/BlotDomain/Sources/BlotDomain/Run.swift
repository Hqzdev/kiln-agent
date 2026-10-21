import Foundation

public struct Run: Codable, Equatable, Sendable {
    public let id: UUID
    public let projectId: UUID
    public let goal: String
    public let createdAt: Date
    public let status: RunStatus
    public let version: Int64
    public init(id: UUID, projectId: UUID, goal: String, createdAt: Date, status: RunStatus, version: Int64) throws {
        guard !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, version >= 0 else { throw DomainValidation.invalidValue }
        self.id = id
        self.projectId = projectId
        self.goal = goal.trimmingCharacters(in: .whitespacesAndNewlines)
        self.createdAt = createdAt
        self.status = status
        self.version = version
    }
    private enum CodingKeys: String, CodingKey { case id, projectId, goal, createdAt, status, version }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(id: c.decode(UUID.self, forKey: .id), projectId: c.decode(UUID.self, forKey: .projectId), goal: c.decode(String.self, forKey: .goal), createdAt: c.decode(Date.self, forKey: .createdAt), status: c.decode(RunStatus.self, forKey: .status), version: c.decode(Int64.self, forKey: .version))
    }
}
