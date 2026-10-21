import SwiftUI
import BlotAPI

struct ModelsSettingsView: View {
    @Bindable var settings: SettingsState
    @State private var key = ""
    @State private var models: [String] = []
    @State private var contextTokens = "32768"
    @State private var outputTokens = "4096"
    @State private var budget = "1000000"
    @State private var version: Int64?
    @State private var error: String?
    @State private var busy = false
    @State private var usage = "No usage recorded"
    private nonisolated struct Options: Codable, Sendable {
        let model: String
        let contextTokens: Int
        let outputTokens: Int
        let runTokenBudget: Int64
    }
    private nonisolated struct Budget: Codable, Sendable { let limit: Int64; let reserved: Int64; let spent: Int64; let usageUnknown: Bool }
    var body: some View {
        SettingsGroup(title: "GigaChat") {
            VStack(alignment: .leading, spacing: 12) {
                SecureField("Personal API key", text: $key).textFieldStyle(.roundedBorder)
                Button("Save key and load models") { saveKey() }.disabled(busy || key.isEmpty)
                Button("Reload models") { Task { await loadModels() } }.disabled(busy)
                Picker("Model", selection: $settings.model) {
                    ForEach(models, id: \.self) { Text($0).tag($0) }
                }
                TextField("Verified context limit", text: $contextTokens)
                TextField("Maximum response tokens", text: $outputTokens)
                TextField("Run token budget", text: $budget)
                Text("Use the context limit documented for the selected model. A personal API key has one generation queue.")
                    .font(KFont.body()).foregroundStyle(K.text2)
                Button("Save model settings") { saveOptions() }.disabled(busy || settings.model.isEmpty)
                if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
            }.padding(16)
        }
        ProviderCertificateSettingsView()
        SettingsGroup(title: "Usage") {
            SettingsRow(title: "Recorded by backend", detail: usage) { Button("Refresh") { Task { await load() } } }
        }
        .task { await load() }
    }
    private func saveKey() {
        busy = true; error = nil
        Task {
            do {
                let client = BackendRuntime.shared.client
                try await client.put("v2/provider/key", body: ["key": key])
                key = ""
                models = try await client.get("v2/provider/models", as: [String].self)
                if !models.contains(settings.model) { settings.model = models.first ?? "" }
            } catch { self.error = error.localizedDescription }
            busy = false
        }
    }
    private func loadModels() async {
        busy = true; error = nil
        defer { busy = false }
        do { models = try await BackendRuntime.shared.client.get("v2/provider/models", as: [String].self) }
        catch { self.error = error.localizedDescription }
    }
    private func saveOptions() {
        guard let context = Int(contextTokens), let output = Int(outputTokens), let tokens = Int64(budget) else {
            error = "Enter numeric token limits"; return
        }
        busy = true; error = nil
        Task {
            do {
                let result = try await BackendRuntime.shared.client.command("provider.settings", payload: Options(model: settings.model, contextTokens: context, outputTokens: output, runTokenBudget: tokens), expectedVersion: version)
                version = try result.result.decode(BackendEntity<Options>.self).version
            } catch { self.error = error.localizedDescription }
            busy = false
        }
    }
    private func load() async {
        do {
            let client = BackendRuntime.shared.client
            let saved = try await client.get("v2/records/PROVIDER_SETTINGS", as: [BackendEntity<Options>].self)
            if let row = saved.first { settings.model = row.data.model; version = row.version; contextTokens = String(row.data.contextTokens); outputTokens = String(row.data.outputTokens); budget = String(row.data.runTokenBudget); models = [row.data.model] }
            let budgets = try await client.get("v2/records/BUDGET", as: [BackendEntity<Budget>].self)
            if let total = budgets.first(where: { $0.parentId == nil }) { usage = "Spent: \(total.data.spent) · reserved: \(total.data.reserved) · limit: \(total.data.limit)" + (total.data.usageUnknown ? " · some usage is unknown" : "") }
        } catch { self.error = error.localizedDescription }
    }
}

struct APIKeyPreviewSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var settings = SettingsState()
    var body: some View {
        ScrollView { VStack(spacing: 16) { ModelsSettingsView(settings: settings); Button("Done") { dismiss() } }.padding(24) }
            .frame(width: 520, height: 640).background(K.bg)
    }
}
struct UsagePreviewView: View {
    var body: some View { APIKeyPreviewSheet() }
}
