import Foundation
import BlotDomain

public struct CreateTask: Codable, Equatable, Sendable {
    public let projectId: UUID
    public let runId: UUID
    public let title: String
    public let acceptanceCriteria: [String]
    public let dependencyIds: Set<UUID>
    public init(projectId: UUID, runId: UUID, title: String, acceptanceCriteria: [String], dependencyIds: Set<UUID>) {
        self.projectId = projectId
        self.runId = runId
        self.title = title
        self.acceptanceCriteria = acceptanceCriteria
        self.dependencyIds = dependencyIds
    }
}
