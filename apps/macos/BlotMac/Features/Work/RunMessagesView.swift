import BlotAPI
import SwiftUI

struct RunMessagesView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    @State private var channel = ""
    @State private var evidence: WorkspaceEvidence?
    private var sessions: [WorkspaceRow] { app.workspace.rows("AGENT_SESSION", parentID: run.id) }
    private var conversations: [WorkspaceRow] {
        app.workspace.rows("CONVERSATION", projectID: run.projectId).filter {
            $0.data.uuid("runId") == run.id
        }
    }
    private var messages: [WorkspaceRow] {
        let ids = Set(conversations.map(\.id))
        return app.workspace.rows("MESSAGE", projectID: run.projectId).filter {
            $0.parentId.map(ids.contains) == true && (channel.isEmpty || $0.parentId?.uuidString == channel)
        }.sorted {
            if $0.parentId == $1.parentId { return $0.data.integer("ordinal") < $1.data.integer("ordinal") }
            return ($0.createdAt, $0.id.uuidString) < ($1.createdAt, $1.id.uuidString)
        }
    }
    var body: some View {
        SettingsGroup(title: "Специалисты и Motes") {
            ForEach(sessions, id: \.id) { session in
                HStack(alignment: .top, spacing: 10) {
                    FaceAvatar(role: .backendRole(session.data.text("role")), size: 28)
                    VStack(alignment: .leading, spacing: 4) {
                        Button(session.data.text("role") + " · " + String(session.id.uuidString.prefix(8))) {
                            evidence = WorkspaceEvidence(kind: "AGENT_SESSION", id: session.id)
                        }.buttonStyle(.plain)
                        Text(session.data.text("status") + " · " + session.data.text("waitingReason")).font(
                            KFont.caption()
                        ).foregroundStyle(K.text2)
                        if session.data.integer("depth") > 0 {
                            Text("Mote · родитель " + session.data.text("parentSessionId")).font(
                                KFont.caption())
                        }
                    }
                    Spacer()
                    Button("Канал") { channel = session.data.text("conversationId") }
                }.padding(12)
            }
            if sessions.isEmpty { Text("Назначения появятся после принятия плана.").padding(16) }
        }
        Picker("Канал", selection: $channel) {
            Text("Все каналы").tag("")
            ForEach(conversations, id: \.id) { conversation in
                Text(conversation.data.text("title") + " · " + String(conversation.id.uuidString.prefix(8)))
                    .tag(conversation.id.uuidString)
            }
        }
        ForEach(messages, id: \.id) { message in
            VStack(alignment: .leading, spacing: 8) {
                Text(author(message)).font(KFont.body(.medium)).foregroundStyle(K.text2)
                if message.data.text("role") == "tool" || message.data.value("functionCall") != .null {
                    DisclosureGroup(
                        message.data.text("role") == "tool"
                            ? "Результат инструмента · " + message.data.text("functionName")
                            : "Запрос инструмента"
                    ) {
                        Text(message.data.text("content")).font(KFont.mono(11)).textSelection(.enabled)
                        if message.data.value("functionCall") != .null {
                            Text(message.data.value("functionCall").formatted).font(KFont.mono(11))
                                .textSelection(.enabled)
                        }
                    }
                } else {
                    Text(message.data.text("content")).font(KFont.body()).textSelection(.enabled)
                }
                if let generation = app.workspace.find("GENERATION", message.data.uuid("generationId")) {
                    Text(generation.data.text("status") + " " + generation.data.text("error")).font(
                        KFont.caption()
                    ).foregroundStyle(K.text3)
                }
            }.frame(maxWidth: .infinity, alignment: .leading).padding(14).kCard(fill: K.surface)
        }
        SettingsGroup(title: "Сообщения между агентами") {
            let ids = Set(sessions.map(\.id))
            ForEach(
                app.workspace.rows("INBOX", projectID: run.projectId).filter {
                    $0.data.uuid("recipientSessionId").map(ids.contains) == true
                }, id: \.id
            ) { message in
                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        role(message.data.uuid("senderSessionId")) + " → "
                            + role(message.data.uuid("recipientSessionId"))
                    ).font(KFont.body(.medium))
                    Text(message.data.text("content")).textSelection(.enabled)
                    Button(
                        message.data.flag("processed")
                            ? "Обработано · источник" : "Ожидает обработки · источник"
                    ) { evidence = WorkspaceEvidence(kind: "INBOX", id: message.id) }
                }.padding(14)
            }
        }
        .sheet(item: $evidence) { WorkspaceEvidenceView(evidence: $0) }
    }
    private func role(_ id: UUID?) -> String {
        app.workspace.find("AGENT_SESSION", id)?.data.text("role") ?? "Пользователь"
    }
    private func author(_ message: WorkspaceRow) -> String {
        if let session = sessions.first(where: { $0.data.uuid("conversationId") == message.parentId }) {
            return session.data.text("role") + " · " + message.data.text("role")
        }
        return "Планирование · " + message.data.text("role")
    }
}
