import Foundation
import BlotDomain

public struct AddSpecificationRevision: Codable, Equatable, Sendable {
    public let runId: UUID
    public let content: String
    public init(runId: UUID, content: String) {
        self.runId = runId
        self.content = content
    }
}
