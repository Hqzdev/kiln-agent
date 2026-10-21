import SwiftUI
import BlotAPI

/// Большой diff читается страницами; исходный артефакт остаётся неизменяемым на Mac.
struct PhoneArtifactView: View {
    let client: BackendClient
    let id: UUID
    @State private var offset = 0
    @State private var content = ""
    @State private var hasMore = false
    @State private var error: String?
    private let pageSize = 262_144
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Button("Previous") { offset = max(0, offset - pageSize) }.disabled(offset == 0)
                    Text("Page \(offset / pageSize + 1)").font(.caption)
                    Button("Next") { offset += pageSize }.disabled(!hasMore)
                }
                if let error { Text(error).foregroundStyle(.red) }
                Text(content).font(.caption.monospaced()).textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }.padding()
        }.navigationTitle("Accepted changes")
        .task(id: offset) {
            do {
                let bytes = try await client.bytes("v2/artifacts/\(id.uuidString)/content?offset=\(offset)&length=\(pageSize)")
                content = String(decoding: bytes, as: UTF8.self); hasMore = bytes.count == pageSize; error = nil
            } catch { self.error = error.localizedDescription }
        }
    }
}
