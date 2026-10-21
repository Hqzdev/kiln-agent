import SwiftUI
import AppKit
import UniformTypeIdentifiers
import BlotAPI

struct ProviderCertificateSettingsView: View {
    @State private var pending: String?
    @State private var certificates: [CertificateInfo] = []
    @State private var error: String?
    @State private var busy = false

    var body: some View {
        SettingsGroup(title: "GigaChat TLS certificate") {
            VStack(alignment: .leading, spacing: 12) {
                Link("Download CA from the provider’s instructions", destination: URL(string: "https://developers.sber.ru/docs/ru/gigachat/certificates")!)
                Text("Choose a PEM certificate and compare its SHA-256 fingerprint with your trusted source. Approval applies to GigaChat requests for this account.")
                    .font(KFont.body()).foregroundStyle(K.text2)
                Button("Choose CA certificate…") { choose() }.disabled(busy)
                ForEach(certificates, id: \.sha256) { item in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.subject)
                        Text("SHA-256: " + item.sha256).font(.caption.monospaced()).textSelection(.enabled)
                        Text("Valid until " + item.notAfter).font(KFont.caption()).foregroundStyle(K.text2)
                    }
                }
                if pending != nil { Button("Trust for GigaChat") { save() }.disabled(busy) }
                else if !certificates.isEmpty { Text("Configured for this account").foregroundStyle(K.success) }
                if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
            }.padding(16)
        }.task {
            do { certificates = try await BackendRuntime.shared.client.get("v2/provider/certificate", as: [CertificateInfo].self) }
            catch { self.error = error.localizedDescription }
        }
    }

    private func choose() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [UTType(filenameExtension: "pem") ?? .data, UTType(filenameExtension: "crt") ?? .data]
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let access = url.startAccessingSecurityScopedResource()
            defer { if access { url.stopAccessingSecurityScopedResource() } }
            let file = try FileHandle(forReadingFrom: url)
            defer { try? file.close() }
            let data = try file.read(upToCount: 65_537) ?? Data()
            guard data.count <= 65_536, let pem = String(data: data, encoding: .utf8) else { throw CocoaError(.fileReadCorruptFile) }
            busy = true; error = nil
            Task {
                defer { busy = false }
                do {
                    certificates = try await BackendRuntime.shared.client.post("v2/provider/certificate/inspect", body: ["pem": pem], as: [CertificateInfo].self)
                    pending = pem
                } catch { self.error = error.localizedDescription }
            }
        } catch { self.error = error.localizedDescription }
    }

    private func save() {
        guard let pending else { return }
        busy = true; error = nil
        Task {
            defer { busy = false }
            do { try await BackendRuntime.shared.client.put("v2/provider/certificate", body: ["pem": pending]); self.pending = nil }
            catch { self.error = error.localizedDescription }
        }
    }
    nonisolated private struct CertificateInfo: Codable, Sendable {
        let subject: String
        let issuer: String
        let sha256: String
        let notAfter: String
    }
}
