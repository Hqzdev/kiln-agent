import BlotAPI
import SwiftUI

struct WorkspaceEvidence: Identifiable {
    let kind: String
    let id: UUID
}

struct WorkspaceEvidenceView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let evidence: WorkspaceEvidence
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(evidence.kind).font(KFont.ui(20, .semibold))
                Spacer()
                Button("Закрыть") { dismiss() }
            }
            Text(evidence.id.uuidString).font(KFont.mono(11)).textSelection(.enabled)
            if let row = app.workspace.find(evidence.kind, evidence.id) {
                Text("Версия \(row.version) · " + row.updatedAt).font(KFont.caption()).foregroundStyle(
                    K.text2)
                ScrollView {
                    Text(row.data.formatted).font(KFont.mono(12)).textSelection(.enabled).frame(
                        maxWidth: .infinity, alignment: .leading)
                }
                if evidence.kind == "ARTIFACT" { ArtifactContentView(id: row.id) }
            } else {
                Text("Запись удалена или больше недоступна.")
            }
        }.padding(24).frame(minWidth: 580, idealWidth: 760, minHeight: 440).background(K.bg).foregroundStyle(
            K.text)
    }
}

struct ArtifactLink: View {
    let id: UUID
    @State private var showing = false
    var body: some View {
        Button("Открыть артефакт · " + String(id.uuidString.prefix(8))) { showing = true }
            .sheet(isPresented: $showing) {
                WorkspaceEvidenceView(evidence: WorkspaceEvidence(kind: "ARTIFACT", id: id))
            }
    }
}

private struct ArtifactContentView: View {
    let id: UUID
    @State private var bytes = Data()
    @State private var end = false
    @State private var busy = false
    @State private var error: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if !bytes.isEmpty {
                let text = String(decoding: bytes, as: UTF8.self)
                if text.hasPrefix("diff --git ") {
                    let lines = UnifiedDiffParser.parse(text)
                    DiffView(
                        file: ReviewFile(
                            path: id.uuidString + ".patch", added: lines.filter { $0.tone == .added }.count,
                            removed: lines.filter { $0.tone == .removed }.count, patch: text)
                    ).frame(minHeight: 220)
                } else {
                    ScrollView {
                        Text(text).font(KFont.mono(11)).textSelection(.enabled).frame(
                            maxWidth: .infinity, alignment: .leading)
                    }.frame(minHeight: 160)
                }
                Text("Прочитано \(bytes.count) байт" + (end ? " · полностью" : " · есть продолжение")).font(
                    KFont.caption()
                ).foregroundStyle(K.text2)
            }
            if let error { Text(error).foregroundStyle(K.warning) }
            if !end {
                Button(bytes.isEmpty ? "Прочитать содержимое" : "Прочитать следующие 64 KiB") { load() }
                    .disabled(busy)
            }
        }
    }
    private func load() {
        busy = true
        error = nil
        Task {
            defer { busy = false }
            do {
                let part = try await BackendRuntime.shared.client.bytes(
                    "v2/artifacts/\(id.uuidString)/content?offset=\(bytes.count)&length=65536")
                bytes.append(part)
                end = part.count < 65536
            } catch { self.error = error.localizedDescription }
        }
    }
}
