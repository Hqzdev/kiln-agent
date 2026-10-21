import Foundation
import BlotDomain

public enum CommandPayload: Equatable, Sendable {
    case createProject(CreateProject)
    case createRun(CreateRun)
    case changeRunStatus(ChangeRunStatus)
    case addSpecificationRevision(AddSpecificationRevision)
    case createTask(CreateTask)
}
public struct Command: Codable, Equatable, Sendable {
    public let commandId: UUID
    public let payload: CommandPayload
    public let expectedVersion: Int64?
    public init(commandId: UUID = UUID(), payload: CommandPayload, expectedVersion: Int64? = nil) { self.commandId = commandId; self.payload = payload; self.expectedVersion = expectedVersion }
    private enum CodingKeys: String, CodingKey { case schemaVersion, commandId, type, payload, projectId, expectedVersion }
    private struct Goal: Codable { let goal: String }
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        guard try c.decode(Int.self, forKey: .schemaVersion) == 1 else {
            throw DecodingError.dataCorruptedError(forKey: .schemaVersion, in: c, debugDescription: "Unsupported schema version")
        }
        commandId = try c.decode(UUID.self, forKey: .commandId)
        expectedVersion = try c.decodeIfPresent(Int64.self, forKey: .expectedVersion)
        switch try c.decode(String.self, forKey: .type) {
        case "project.create": payload = .createProject(try c.decode(CreateProject.self, forKey: .payload))
        case "run.create": payload = .createRun(CreateRun(projectId: try c.decode(UUID.self, forKey: .projectId), goal: try c.decode(Goal.self, forKey: .payload).goal))
        case "run.status.change": payload = .changeRunStatus(try c.decode(ChangeRunStatus.self, forKey: .payload))
        case "specification.revision.create": payload = .addSpecificationRevision(try c.decode(AddSpecificationRevision.self, forKey: .payload))
        case "task.create": payload = .createTask(try c.decode(CreateTask.self, forKey: .payload))
        default: throw DecodingError.dataCorruptedError(forKey: .type, in: c, debugDescription: "Unsupported command type")
        }
    }
    public func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(1, forKey: .schemaVersion)
        try c.encode(commandId, forKey: .commandId)
        try c.encodeIfPresent(expectedVersion, forKey: .expectedVersion)
        switch payload {
        case .createProject(let value):
            try c.encode("project.create", forKey: .type)
            try c.encode(value, forKey: .payload)
        case .createRun(let value):
            try c.encode("run.create", forKey: .type)
            try c.encode(value.projectId, forKey: .projectId)
            try c.encode(Goal(goal: value.goal), forKey: .payload)
        case .changeRunStatus(let value):
            try c.encode("run.status.change", forKey: .type)
            try c.encode(value, forKey: .payload)
        case .addSpecificationRevision(let value):
            try c.encode("specification.revision.create", forKey: .type)
            try c.encode(value, forKey: .payload)
        case .createTask(let value):
            try c.encode("task.create", forKey: .type)
            try c.encode(value, forKey: .payload)
        }
    }
}
