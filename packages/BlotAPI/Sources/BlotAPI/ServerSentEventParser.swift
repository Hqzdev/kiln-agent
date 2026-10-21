import Foundation

/// Разделяет SSE по пустой строке и сохраняет многострочное data, включая CRLF.
struct ServerSentEventParser {
    private var line = Data()
    private var data = ""
    private var previousWasCarriageReturn = false
    private let limit = 1_048_576

    mutating func append(_ byte: UInt8) throws -> String? {
        if byte == 10 && previousWasCarriageReturn {
            previousWasCarriageReturn = false
            return nil
        }
        previousWasCarriageReturn = byte == 13
        if byte == 10 || byte == 13 { return try finishLine() }
        line.append(byte)
        guard line.count <= limit else { throw URLError(.dataLengthExceedsMaximum) }
        return nil
    }

    private mutating func finishLine() throws -> String? {
        let text = String(decoding: line, as: UTF8.self)
        line.removeAll(keepingCapacity: true)
        if text.isEmpty {
            guard !data.isEmpty else { return nil }
            let result = data
            data = ""
            return result
        }
        guard text.hasPrefix("data:") else { return nil }
        var value = String(text.dropFirst(5))
        if value.hasPrefix(" ") { value.removeFirst() }
        if !data.isEmpty { data += "\n" }
        data += value
        guard data.utf8.count <= limit else { throw URLError(.dataLengthExceedsMaximum) }
        return nil
    }
}
