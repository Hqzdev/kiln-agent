import Foundation
import Testing
import BlotDomain
@testable import BlotAPI

@Test func sharedEventFixture() throws {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    let data = try Data(contentsOf: root.appendingPathComponent("fixtures/contracts/project-event.json"))
    let event = try WireJSON.decoder().decode(ProjectEvent.self, from: data)
    #expect(event.type == "task.ready")
    #expect(event.seq == "418")
    #expect(try WireJSON.decoder().decode(ProjectEvent.self, from: WireJSON.encoder().encode(event)) == event)
}
@Test func statusCommandsRoundTrip() throws {
    let command = ChangeRunStatus(runId: UUID(), expectedVersion: 3, status: .cancelled)
    #expect(try WireJSON.decoder().decode(ChangeRunStatus.self, from: WireJSON.encoder().encode(command)) == command)
    #expect(throws: DecodingError.self) { try WireJSON.decoder().decode(RunStatus.self, from: Data("\"UNKNOWN\"".utf8)) }
}

@Test func timestampsAlwaysIncludeUTC() throws {
    let encoded = try WireJSON.encoder().encode(Date(timeIntervalSince1970: 0))
    #expect(String(decoding: encoded, as: UTF8.self).contains("Z"))
    #expect(try WireJSON.decoder().decode(Date.self, from: encoded) == Date(timeIntervalSince1970: 0))
    #expect(try WireJSON.decoder().decode(Date.self, from: Data("\"1970-01-01T00:00:00Z\"".utf8)) == Date(timeIntervalSince1970: 0))
}

private func fixture(_ name: String) throws -> Data {
    let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent().deletingLastPathComponent()
    return try Data(contentsOf: root.appendingPathComponent("fixtures/contracts/\(name).json"))
}
@Test func everyCommandFixtureRoundTrips() throws {
    for name in ["command-project-create", "command-create-run", "command-run-status", "command-specification-create", "command-task-create"] {
        let command = try WireJSON.decoder().decode(Command.self, from: fixture(name))
        #expect(try WireJSON.decoder().decode(Command.self, from: WireJSON.encoder().encode(command)) == command)
    }
    let unknown = Data("{\"schemaVersion\":2,\"commandId\":\"00000000-0000-0000-0000-000000000000\",\"type\":\"run.create\",\"payload\":{}}".utf8)
    #expect(throws: DecodingError.self) { try WireJSON.decoder().decode(Command.self, from: unknown) }
}
@Test func sharedDomainFixtures() throws {
    let decoder = WireJSON.decoder()
    let project = try decoder.decode(Project.self, from: fixture("domain-project"))
    #expect(project.name == "Blot")
    let run = try decoder.decode(Run.self, from: fixture("domain-run"))
    #expect(run.status == .draft)
    let revision = try decoder.decode(SpecificationRevision.self, from: fixture("domain-specification"))
    #expect(revision.revision == 1)
    let task = try decoder.decode(Task.self, from: fixture("domain-task"))
    #expect(task.dependencyIds.isEmpty)
    #expect(try decoder.decode(APIError.self, from: fixture("api-error")).code == "not_found")
}

@Test func allSupportedEventsAndProjectScope() throws {
    for type in ["project.created", "run.created", "run.status_changed", "specification.revision_created", "task.created"] {
        let name = "event-" + type.replacingOccurrences(of: ".", with: "-")
        let event = try WireJSON.decoder().decode(ProjectEvent.self, from: fixture(name))
        #expect(event.type == type)
        #expect(try WireJSON.decoder().decode(ProjectEvent.self, from: WireJSON.encoder().encode(event)) == event)
        if type == "project.created" { #expect(event.runId == nil) }
    }
}

@Test func incompatibleEventVersionIsRejected() throws {
    var object = try JSONSerialization.jsonObject(with: fixture("project-event")) as! [String: Any]
    object["schemaVersion"] = 2
    let data = try JSONSerialization.data(withJSONObject: object)
    #expect(throws: DecodingError.self) { try WireJSON.decoder().decode(ProjectEvent.self, from: data) }
}

private func normalizedJSON(_ value: Any) -> Any {
    if let string = value as? String, UUID(uuidString: string) != nil { return string.lowercased() }
    if let dictionary = value as? [String: Any] { return dictionary.mapValues(normalizedJSON) }
    if let array = value as? [Any] { return array.map(normalizedJSON) }
    return value
}
@Test func commandEncodingMatchesGoldenStructure() throws {
    for name in ["command-project-create", "command-create-run", "command-run-status", "command-specification-create", "command-task-create"] {
        let data = try fixture(name)
        let command = try WireJSON.decoder().decode(Command.self, from: data)
        let expected = normalizedJSON(try JSONSerialization.jsonObject(with: data)) as! NSDictionary
        let actual = normalizedJSON(try JSONSerialization.jsonObject(with: WireJSON.encoder().encode(command))) as! NSDictionary
        #expect(actual == expected)
    }
    let event = try WireJSON.decoder().decode(ProjectEvent.self, from: fixture("event-project-created"))
    let encoded = try JSONSerialization.jsonObject(with: WireJSON.encoder().encode(event)) as! [String: Any]
    #expect(encoded["runId"] is NSNull)
}
