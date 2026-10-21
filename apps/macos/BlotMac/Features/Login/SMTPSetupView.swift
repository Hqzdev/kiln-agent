import SwiftUI
import BlotAPI

struct SMTPSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var host = ""
    @State private var port = "587"
    @State private var username = ""
    @State private var password = ""
    @State private var from = ""
    @State private var error: String?
    @State private var busy = false
    private nonisolated struct Configuration: Encodable, Sendable { let host: String; let port: Int; let username: String; let password: String; let from: String }
    var body: some View {
        Form {
            Text("Email delivery for this Mac").font(.headline)
            Text("Blot sends verification and password reset codes through this SMTP account using STARTTLS.")
            TextField("SMTP host", text: $host)
            TextField("Port", text: $port)
            TextField("Username", text: $username)
            SecureField("SMTP password", text: $password)
            TextField("Sender email", text: $from)
            if let error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
            HStack { Button("Cancel") { dismiss() }; Spacer(); Button("Save") { save() }.disabled(busy) }
        }.padding(24).frame(width: 480)
    }
    private func save() {
        guard let port = Int(port) else { error = "Enter a valid port"; return }
        busy = true
        Task {
            do {
                try await BackendRuntime.shared.start()
                try await BackendRuntime.shared.client.put("v2/setup/smtp", body: Configuration(host: host, port: port, username: username, password: password, from: from))
                password = ""; dismiss()
            } catch { self.error = error.localizedDescription }
            busy = false
        }
    }
}
