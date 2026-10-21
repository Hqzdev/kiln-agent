import SwiftUI
import BlotAPI

struct PhoneChatView: View {
    let client: BackendClient
    let conversation: UUID
    @State private var messages: [BackendEntity<Message>] = []
    @State private var text = ""
    @State private var error: String?
    @State private var pending: UUID?
    @State private var pendingContent: String?
    @State private var sending = false
    nonisolated private struct Message: Codable, Sendable { let role: String; let content: String; let ordinal: Int64 }
    nonisolated private struct Send: Encodable, Sendable { let conversationId: UUID; let content: String }
    var body: some View {
        VStack {
            List(messages.sorted { $0.data.ordinal < $1.data.ordinal }, id: \.id) { row in
                VStack(alignment: .leading) { Text(row.data.role).font(.caption).foregroundStyle(.secondary); Text(row.data.content).textSelection(.enabled) }
            }
            if let error { Text(error).font(.caption).foregroundStyle(.red) }
            HStack { TextField("Message", text: $text, axis: .vertical); Button("Send") { send() }.disabled(text.isEmpty || sending) }.padding()
        }.navigationTitle("Conversation")
        .task(id: client.baseURL) { while !Task.isCancelled { await refresh(); try? await Task.sleep(for: .seconds(1)) } }
    }
    private func refresh() async { do { messages = try await client.records("MESSAGE", parentId: conversation, as: Message.self) } catch { self.error = error.localizedDescription } }
    private func send() {
        guard !sending else { return }
        let id = pending ?? UUID(); pending = id
        let content = pendingContent ?? text; pendingContent = content; sending = true
        Task {
            defer { sending = false }
            do {
                _ = try await client.command("conversation.send_message", payload: Send(conversationId: conversation, content: content), commandId: id)
                pending = nil; pendingContent = nil; text = ""; error = nil; await refresh()
            } catch let failure as BackendFailure {
                if failure.isDefiniteRejection { pending = nil; pendingContent = nil }
                error = failure.localizedDescription
            } catch { self.error = error.localizedDescription }
        }
    }
}
