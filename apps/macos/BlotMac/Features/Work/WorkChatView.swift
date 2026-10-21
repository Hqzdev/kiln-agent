import SwiftUI

struct WorkChatView: View {
    @Environment(AppState.self) private var app

    var body: some View {
        @Bindable var app = app
        VStack(spacing: 0) {
            if let chat = app.currentWorkChat {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if let assistant = chat.assistant {
                            VStack(alignment: .leading, spacing: 12) {
                                Text(assistant.name).font(KFont.pageTitle()).foregroundStyle(K.text)
                                DisclosureGroup("Instructions") {
                                    Text(assistant.instructions).font(KFont.body()).foregroundStyle(K.text2)
                                        .frame(maxWidth: .infinity, alignment: .leading).textSelection(.enabled)
                                }.font(KFont.body()).foregroundStyle(K.text2)
                            }
                        }
                        if let error = chat.error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
                        if chat.isSending {
                            HStack { ProgressView("Blot is working…"); Button("Stop") { chat.cancel() } }
                        }
                        if chat.canRetry && !chat.isSending { Button("Continue interrupted response") { chat.retry() } }
                        ForEach(chat.messages) { message in
                            if message.fromUser { ThreadBlockView(block: .user(message.text), actions: ThreadActions()) }
                            else {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(chat.assistant?.name ?? "Blot").font(KFont.body(.medium)).foregroundStyle(K.text3)
                                    Text(message.text).font(KFont.body()).foregroundStyle(K.text)
                                        .textSelection(.enabled)
                                }
                            }
                        }
                    }.frame(maxWidth: K.contentWidth).padding(24).frame(maxWidth: .infinity)
                }.defaultScrollAnchor(.bottom)
            } else {
                VStack(spacing: 20) {
                    PrimaryBlot(context: .workHome)
                    Text("How can I help?").font(KFont.pageTitle(.regular)).foregroundStyle(K.text)
                    if let project = app.workChat.selectedProject {
                        Text("New chat in \(project.name)").font(KFont.body()).foregroundStyle(K.text2)
                    }
                }.frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            Composer(text: $app.workChatDraft, placeholder: "Message Blot",
                     petContext: app.currentWorkChat == nil ? nil : app.activeBlotContext,
                     approvalModes: [], status: "Work · saved on this Mac", onSend: { app.sendWorkChatMessage() })
                .composerPlacement(hasPet: app.currentWorkChat != nil)
        }.id(app.currentWorkChat?.id ?? "new-work-chat")
    }
}
