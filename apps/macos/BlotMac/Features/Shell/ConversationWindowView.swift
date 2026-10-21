import Foundation
import SwiftUI

struct ConversationWindowRequest: Codable, Hashable {
    let id: String
    let title: String
    let transcript: String
    var chatID: String?
}

struct ConversationWindowView: View {
    @Environment(AppState.self) private var app
    let request: ConversationWindowRequest
    private var exportedText: String {
        if let id = request.chatID, let session = app.workChat.session(id) {
            return app.transcript(for: SidebarConversation(id: "chat:" + id, title: session.title,
                project: session.projectID ?? "", taskID: id, running: false, kind: .chat))
        }
        return request.transcript
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(request.title).font(KFont.ui(20, .semibold)).foregroundStyle(K.text).lineLimit(2)
                Spacer()
                CopyButton(text: exportedText, title: "Copy conversation")
            }
            if let id = request.chatID, let session = app.workChat.session(id) {
                SideChatContent(session: session)
            } else {
                Text("Conversation snapshot · read-only").font(KFont.caption()).foregroundStyle(K.text3)
                ScrollView {
                    Text(request.transcript).font(KFont.body()).foregroundStyle(K.text)
                        .textSelection(.enabled).frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }.padding(24).frame(minWidth: 560, minHeight: 480).background(K.bg)
            .preferredColorScheme(app.theme.colorScheme)
            .navigationTitle(request.title)
    }
}

private struct SideChatContent: View {
    @Bindable var session: WorkChatSession

    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(session.messages) { message in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(message.fromUser ? "You" : "Blot").font(KFont.caption()).foregroundStyle(K.text3)
                            Text(message.text).font(KFont.body()).foregroundStyle(K.text).textSelection(.enabled)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }.defaultScrollAnchor(.bottom)
            Composer(text: $session.draft, placeholder: "Message in side chat", approvalModes: [],
                     status: "Local conversation · AI is not connected") {
                let text = session.draft.trimmingCharacters(in: .whitespacesAndNewlines)
                if !text.isEmpty { session.send(text) }
            }
        }
    }
}
