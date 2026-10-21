import Foundation
public struct PairingDescriptor: Codable, Sendable {
    public let schemaVersion: Int
    public let installationId: String
    public let address: URL
    public let fingerprint: String
    public let bluetoothName: String
    public let id: UUID
    public let secret: String
    public let expiresAt: String
    public init(installationId: String, address: URL, fingerprint: String, bluetoothName: String, id: UUID, secret: String, expiresAt: String) {
        schemaVersion = 2; self.installationId = installationId; self.address = address; self.fingerprint = fingerprint
        self.bluetoothName = bluetoothName; self.id = id; self.secret = secret; self.expiresAt = expiresAt
    }
}
