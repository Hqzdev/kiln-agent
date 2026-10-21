import Foundation
import Testing

@testable import BlotAPI

@Test func ssePreservesBlankLinesCommentsAndFragmentedUTF8() throws {
    for ending in ["\n", "\r\n", "\r"] {
        var parser = ServerSentEventParser()
        var values: [String] = []
        let stream =
            ": heartbeat" + ending + ending + "event: project" + ending + "data: {\"text\":\"Привет\"}"
            + ending + ending
        for byte in stream.utf8 { if let value = try parser.append(byte) { values.append(value) } }
        #expect(values == ["{\"text\":\"Привет\"}"])
    }
}

@Test func sseDoesNotEmitIncompleteEventAndJoinsDataLines() throws {
    var parser = ServerSentEventParser()
    for byte in "data: {\n".utf8 { #expect(try parser.append(byte) == nil) }
    var values: [String] = []
    for byte in "data: \"seq\":\"1\"}\n\n".utf8 {
        if let value = try parser.append(byte) { values.append(value) }
    }
    #expect(values == ["{\n\"seq\":\"1\"}"])
}

@Test func sseRejectsOversizedLine() throws {
    var parser = ServerSentEventParser()
    for _ in 0..<1_048_576 { _ = try parser.append(65) }
    #expect(throws: (any Error).self) { try parser.append(65) }
}
