import BlotAPI
import SwiftUI

struct SkillDetailView: View {
    @Environment(AppState.self) private var app
    let item: WorkspaceRow
    @State private var editing = false
    @State private var deleting = false
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(item.data.text("name")).font(KFont.pageTitle())
                Badge(text: "v\(item.version)")
                Spacer()
                Button("Изменить") { editing = true }
                Button("Удалить", role: .destructive) { deleting = true }
            }
            Text(
                item.projectId.flatMap { app.workspace.find("PROJECT", $0)?.data.text("name") }
                    ?? "Все проекты аккаунта"
            ).foregroundStyle(K.text2)
            Text("Роли: " + item.data.strings("roles").joined(separator: ", "))
            Button(item.data.flag("enabled") ? "Выключить навык" : "Включить навык") {
                var fields: [String: BackendJSON] = [:]
                if case .object(let data) = item.data { fields = data }
                fields["enabled"] = .bool(!item.data.flag("enabled"))
                let payload = BackendJSON.object(["id": .string(item.id.uuidString), "data": .object(fields)])
                Task {
                    try? await app.workspace.send(
                        "skill.save", payload: payload, row: item, key: "skill.toggle:" + item.id.uuidString)
                }
            }.disabled(!app.workspace.commands.active.isEmpty)
            Text(
                "Навык задаёт инструкцию и не выдаёт права на инструменты. Изменения применятся к новым сессиям."
            ).font(KFont.caption()).foregroundStyle(K.text2)
            Text(item.data.text("instruction")).font(KFont.mono(12)).textSelection(.enabled)
        }
        .sheet(isPresented: $editing) { SkillEditorView(item: item) }
        .confirmationDialog("Удалить навык?", isPresented: $deleting) {
            Button("Удалить", role: .destructive) {
                Task { try? await app.workspace.send("skill.delete", payload: item.idPayload, row: item) }
            }
        }
    }
}
