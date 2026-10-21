import Foundation
import BlotDomain

public struct CreateRun: Codable, Equatable, Sendable {
    public let projectId: UUID
    public let goal: String
    public init(projectId: UUID, goal: String) {
        self.projectId = projectId
        self.goal = goal
    }
}
