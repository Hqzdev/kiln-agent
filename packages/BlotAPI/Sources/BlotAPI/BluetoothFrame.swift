import Foundation

/// BLE переносит фрагменты TLS-потоков. Пароли и команды не разбираются мостом.
public struct BluetoothFrame: Equatable, Sendable {
    public enum Kind: UInt8, Sendable { case open = 1, data = 2, close = 3 }
    public let kind: Kind
    public let channel: UInt32
    public let sequence: UInt32
    public let payload: Data
    public static let headerSize = 12

    public init(kind: Kind, channel: UInt32, sequence: UInt32, payload: Data = Data()) {
        self.kind = kind; self.channel = channel; self.sequence = sequence; self.payload = payload
    }
    public func encode() throws -> Data {
        guard payload.count <= 1024 else { throw URLError(.dataLengthExceedsMaximum) }
        var data = Data([1, kind.rawValue])
        for number in [channel, sequence] { data.append(contentsOf: [UInt8(number >> 24), UInt8((number >> 16) & 255), UInt8((number >> 8) & 255), UInt8(number & 255)]) }
        data.append(contentsOf: [UInt8(payload.count >> 8), UInt8(payload.count & 255)])
        data.append(payload)
        return data
    }
    public init(data: Data) throws {
        let bytes = Array(data)
        guard bytes.count >= Self.headerSize, bytes[0] == 1, let kind = Kind(rawValue: bytes[1]) else { throw URLError(.cannotParseResponse) }
        let length = Int(bytes[10]) * 256 + Int(bytes[11])
        guard length <= 1024, length + Self.headerSize == bytes.count else { throw URLError(.cannotParseResponse) }
        func number(_ offset: Int) -> UInt32 { bytes[offset..<(offset + 4)].reduce(UInt32(0)) { ($0 << 8) | UInt32($1) } }
        self.init(kind: kind, channel: number(2), sequence: number(6), payload: Data(bytes.dropFirst(Self.headerSize)))
    }
}

public enum BlotBluetoothIdentifiers {
    public static let service = "BAAB1000-8473-430C-8E14-E0F18CC54250"
    public static let incoming = "BAAB1001-8473-430C-8E14-E0F18CC54250"
    public static let outgoing = "BAAB1002-8473-430C-8E14-E0F18CC54250"
}
