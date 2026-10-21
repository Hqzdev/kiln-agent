import Foundation
import Testing
@testable import BlotDomain

@Test func creationAndDecodingRejectInvalidValues() throws {
    #expect(throws: DomainValidation.self) {
        try Project(id: UUID(), name: " ", repositoryPath: "/tmp", createdAt: Date())
    }
    #expect(throws: DomainValidation.self) {
        try SpecificationRevision(id: UUID(), runId: UUID(), revision: 0, content: "spec", createdAt: Date())
    }
    let id = UUID()
    #expect(throws: DomainValidation.self) {
        try Task(id: id, projectId: UUID(), runId: UUID(), title: "task", acceptanceCriteria: ["done"], dependencyIds: [id], createdAt: Date())
    }
    let project = try Project(id: id, name: "Blot", repositoryPath: "/tmp", createdAt: Date(timeIntervalSince1970: 0))
    #expect(try JSONDecoder().decode(Project.self, from: JSONEncoder().encode(project)) == project)
    let invalid = Data("{\"id\":\"\(id)\",\"name\":\"\",\"repositoryPath\":\"/tmp\",\"createdAt\":0}".utf8)
    #expect(throws: DomainValidation.self) { try JSONDecoder().decode(Project.self, from: invalid) }
}

@Test func allModelsRoundTripAndNormalize() throws {
    let id = UUID(), projectId = UUID(), runId = UUID(), now = Date(timeIntervalSince1970: 0)
    let run = try Run(id: runId, projectId: projectId, goal: " goal ", createdAt: now, status: .draft, version: 0)
    #expect(run.goal == "goal")
    #expect(try JSONDecoder().decode(Run.self, from: JSONEncoder().encode(run)) == run)
    let revision = try SpecificationRevision(id: id, runId: runId, revision: 1, content: " spec ", createdAt: now)
    #expect(revision.content == "spec")
    #expect(try JSONDecoder().decode(SpecificationRevision.self, from: JSONEncoder().encode(revision)) == revision)
    let task = try Task(id: id, projectId: projectId, runId: runId, title: " task ", acceptanceCriteria: [" done "], dependencyIds: [], createdAt: now)
    #expect(task.acceptanceCriteria == ["done"])
    #expect(try JSONDecoder().decode(Task.self, from: JSONEncoder().encode(task)) == task)
    #expect(throws: DomainValidation.self) { try Run(id: runId, projectId: projectId, goal: "goal", createdAt: now, status: .draft, version: -1) }
    #expect(throws: DomainValidation.self) { try Project(id: id, name: "name", repositoryPath: "relative", createdAt: now) }
    #expect(throws: DomainValidation.self) { try Task(id: id, projectId: projectId, runId: runId, title: "task", acceptanceCriteria: [], dependencyIds: [], createdAt: now) }
}
