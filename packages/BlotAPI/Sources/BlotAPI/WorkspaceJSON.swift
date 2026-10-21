import Foundation

extension BackendJSON {
    public func value(_ field: String) -> BackendJSON {
        guard case .object(let values) = self else { return .null }
        return values[field] ?? .null
    }
    public func items(_ field: String) -> [BackendJSON] {
        if case .array(let values) = value(field) { return values }
        return []
    }
    public func strings(_ field: String) -> [String] {
        items(field).compactMap {
            if case .string(let text) = $0 { return text }
            return nil
        }
    }
    public func text(_ field: String) -> String {
        if case .string(let text) = value(field) { return text }
        return ""
    }
    public func flag(_ field: String) -> Bool {
        if case .bool(let flag) = value(field) { return flag }
        return false
    }
    public func integer(_ field: String) -> Int64 {
        if case .integer(let number) = value(field) { return number }
        return 0
    }
    public func uuid(_ field: String) -> UUID? { UUID(uuidString: text(field)) }
    public var formatted: String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(self) else { return "" }
        return String(decoding: data, as: UTF8.self)
    }
}
