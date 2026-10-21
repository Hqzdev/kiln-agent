import Foundation
import Testing
@testable import BlotAPI

@Test func bluetoothFramesRejectTruncationAndPreserveStreams() throws {
    let frame = BluetoothFrame(kind: .data, channel: UInt32.max, sequence: 7182, payload: Data([0, 1, 2, 255]))
    let bytes = try frame.encode()
    #expect(try BluetoothFrame(data: bytes) == frame)
    #expect(throws: (any Error).self) { try BluetoothFrame(data: bytes.dropLast()) }
    var wrong = bytes; wrong[0] = 2
    #expect(throws: (any Error).self) { try BluetoothFrame(data: wrong) }
}

@Test func realV2HTTPResponseWhenProvided() throws {
    guard let path = ProcessInfo.processInfo.environment["BLOT_HTTP_FIXTURES"] else { return }
    let data = try Data(contentsOf: URL(fileURLWithPath: path).appendingPathComponent("workspace-conversation.json"))
    let entity = try JSONDecoder().decode(BackendEntity<BackendJSON>.self, from: data)
    #expect(entity.version == 0)
    #expect(entity.parentId == nil)
}

@Test func v2CommandCarriesStableIdentityAndLargeVersions() throws {
    let id = UUID()
    let command = CommandV2(commandId: id, type: "run.pause", projectId: nil, expectedVersion: 9_007_199_254_740_993, payload: ["id": UUID().uuidString])
    let data = try JSONEncoder().encode(command)
    let body = try JSONDecoder().decode([String: BackendJSON].self, from: data)
    #expect(body["schemaVersion"] == .integer(2))
    #expect(body["expectedVersion"] == .integer(9_007_199_254_740_993))
    #expect(body["commandId"] == .string(id.uuidString))
}
