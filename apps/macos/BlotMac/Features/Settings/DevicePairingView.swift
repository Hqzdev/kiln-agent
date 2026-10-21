import SwiftUI
import BlotAPI
import CoreImage.CIFilterBuiltins

struct DevicePairingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var descriptor: PairingDescriptor?
    @State private var requests: [PairRequest] = []
    @State private var error: String?
    nonisolated private struct Ticket: Decodable, Sendable { let id: UUID; let secret: String?; let expiresAt: String }
    nonisolated private struct PairRequest: Decodable, Sendable, Identifiable { let id: UUID; let version: Int64; let deviceName: String?; let platform: String?; let approved: Bool; let claimed: Bool }
    nonisolated private struct Id: Encodable, Sendable { let id: UUID }
    var body: some View {
        VStack(spacing: 16) {
            Text("Connect your iPhone").font(.title2)
            if let descriptor, let image = qr(descriptor) {
                Image(nsImage: image).interpolation(.none).resizable().frame(width: 260, height: 260)
                Text("Scan this code in Blot on your iPhone. Confirm the device below.").multilineTextAlignment(.center)
                Text(descriptor.address.absoluteString).font(.caption).textSelection(.enabled)
            }
            ForEach(requests.filter { !$0.approved && $0.deviceName != nil }) { request in
                HStack { Text(request.deviceName ?? "iPhone"); Spacer(); Button("Approve device") { approve(request) } }
            }
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack { Button("New code") { Task { await create() } }; Spacer(); Button("Done") { dismiss() } }
        }.padding(24).frame(width: 440)
        .task {
            await create()
            while !Task.isCancelled { await refresh(); try? await Task.sleep(for: .seconds(1)) }
        }
    }
    private func create() async {
        do {
            let runtime = BackendRuntime.shared
            runtime.enableBluetooth()
            guard let fingerprint = runtime.fingerprint, let installation = runtime.installationId else { throw URLError(.secureConnectionFailed) }
            let receipt = try await runtime.client.command("device.pair", payload: [String: String]())
            let created = try receipt.result.decode(Ticket.self)
            let ticket = try await runtime.client.get("v2/pairing/\(created.id.uuidString)/ticket", as: Ticket.self)
            guard let secret = ticket.secret else { throw URLError(.cannotParseResponse) }
            var address = URLComponents(url: runtime.client.baseURL, resolvingAgainstBaseURL: false)!
            address.host = Host.current().name ?? ProcessInfo.processInfo.hostName
            descriptor = PairingDescriptor(installationId: installation, address: address.url!, fingerprint: fingerprint, bluetoothName: runtime.bluetoothName, id: ticket.id, secret: secret, expiresAt: ticket.expiresAt)
            error = nil
        } catch { self.error = error.localizedDescription }
    }
    private func refresh() async {
        do { requests = try await BackendRuntime.shared.client.get("v2/devices/pairings", as: [PairRequest].self) }
        catch { self.error = error.localizedDescription }
    }
    private func approve(_ request: PairRequest) {
        Task { do { _ = try await BackendRuntime.shared.client.command("device.approve", payload: Id(id: request.id), expectedVersion: request.version); await refresh() } catch { self.error = error.localizedDescription } }
    }
    private func qr(_ value: PairingDescriptor) -> NSImage? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        let filter = CIFilter.qrCodeGenerator(); filter.message = data
        guard let image = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 8, y: 8)),
              let result = CIContext().createCGImage(image, from: image.extent) else { return nil }
        return NSImage(cgImage: result, size: NSSize(width: result.width, height: result.height))
    }
}
