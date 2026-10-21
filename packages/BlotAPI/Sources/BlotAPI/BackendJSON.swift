import Foundation

public enum BackendJSON: Codable, Equatable, Sendable {
    case string(String), integer(Int64), number(Double), bool(Bool), object([String: BackendJSON]), array([BackendJSON]), null
    public init(from decoder: any Decoder) throws {
        let value = try decoder.singleValueContainer()
        if value.decodeNil() { self = .null }
        else if let item = try? value.decode(Bool.self) { self = .bool(item) }
        else if let item = try? value.decode(Int64.self) { self = .integer(item) }
        else if let item = try? value.decode(Double.self) { self = .number(item) }
        else if let item = try? value.decode(String.self) { self = .string(item) }
        else if let item = try? value.decode([String: BackendJSON].self) { self = .object(item) }
        else { self = .array(try value.decode([BackendJSON].self)) }
    }
    public func encode(to encoder: any Encoder) throws {
        var value = encoder.singleValueContainer()
        switch self {
        case .string(let item): try value.encode(item)
        case .integer(let item): try value.encode(item)
        case .number(let item): try value.encode(item)
        case .bool(let item): try value.encode(item)
        case .object(let item): try value.encode(item)
        case .array(let item): try value.encode(item)
        case .null: try value.encodeNil()
        }
    }
    public func decode<T: Decodable>(_ type: T.Type) throws -> T {
        try JSONDecoder().decode(type, from: JSONEncoder().encode(self))
    }
}

public struct BackendEntity<Value: Codable & Sendable>: Codable, Sendable {
    public let id: UUID
    public let ownerId: UUID
    public let projectId: UUID?
    public let parentId: UUID?
    public let version: Int64
    public let createdAt: String
    public let updatedAt: String
    public let data: Value
}

public struct BackendReceipt: Codable, Sendable {
    public let commandId: UUID
    public let decision: String
    public let operationId: UUID
    public let result: BackendJSON
}

public struct BackendEvent: Codable, Sendable {
    public let schemaVersion: Int
    public let seq: String
    public let eventId: UUID
    public let projectId: UUID?
    public let type: String
    public let occurredAt: String
    public let payload: BackendJSON
    public var sequence: Int64? { Int64(seq) }
}

public struct BackendFailure: Error, Codable, LocalizedError, Sendable {
    public let code: String
    public let message: String
    public let details: [String: String]?
    public var httpStatus: Int? = nil
    public var isDefiniteRejection: Bool {
        guard let httpStatus else { return false }
        return (400..<500).contains(httpStatus) && ![401, 408, 429].contains(httpStatus) && code != "schema_incompatible"
    }
    public var errorDescription: String? { message }
}

public struct BackendSnapshot: Codable, Sendable {
    public let schemaVersion: Int
    public let watermark: String
    public var records: [String: [BackendEntity<BackendJSON>]]
    public let nextCursors: [String: String]?
}

public struct BackendRejectedCommand: Codable, Sendable {
    public let command: BackendJSON
    public let error: BackendFailure
}
