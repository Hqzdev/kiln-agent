import BlotAPI
import SwiftUI

struct SkillEditorView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let item: WorkspaceRow?
    @State private var name: String
    @State private var instruction: String
    @State private var project: String
    @State private var roles: Set<String>
    @State private var availableRoles: [String] = []
    @State private var enabled: Bool
    @State private var error: String?
    private var key: String { "skill.editor:" + (item?.id.uuidString ?? "new") }
    init(item: WorkspaceRow? = nil) {
        self.item = item
        _name = State(initialValue: item?.data.text("name") ?? "")
        _instruction = State(initialValue: item?.data.text("instruction") ?? "")
        _project = State(initialValue: item?.projectId?.uuidString ?? "")
        _roles = State(initialValue: Set(item?.data.strings("roles") ?? []))
        _enabled = State(initialValue: item?.data.flag("enabled") ?? true)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item == nil ? "Новый навык" : "Изменить навык").font(KFont.ui(20, .semibold))
            Group {
                TextField("Название", text: $name)
                Picker("Область", selection: $project) {
                    Text("Все проекты аккаунта").tag("")
                    ForEach(app.projects) { Text($0.name).tag($0.id) }
                }.disabled(item != nil)
                Text("Роли специалистов")
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 160))], alignment: .leading) {
                        ForEach(availableRoles, id: \.self) { role in
                            Toggle(
                                role,
                                isOn: Binding(
                                    get: { roles.contains(role) },
                                    set: { if $0 { roles.insert(role) } else { roles.remove(role) } })
                            ).toggleStyle(.checkbox)
                        }
                    }
                }.frame(height: 90)
                TextEditor(text: $instruction).font(KFont.mono(12)).frame(height: 240).padding(8).kCard(
                    fill: K.surface)
                Toggle("Включён для новых сессий", isOn: $enabled)
            }.disabled(app.workspace.commands.pending[key] != nil)
            if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
            HStack {
                Spacer()
                Button("Отмена") { dismiss() }
                Button(
                    app.workspace.commands.pending[key] == nil ? "Сохранить" : "Повторить исходное сохранение"
                ) { save() }
                .disabled(
                    name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || instruction.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || roles.isEmpty || app.workspace.commands.active.contains(key)
                )
                .keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 620).background(K.bg).foregroundStyle(K.text)
            .task {
                do {
                    let rows = try await BackendRuntime.shared.client.get("v2/roles", as: [BackendJSON].self)
                    availableRoles = rows.map { $0.text("role") }.sorted()
                } catch { self.error = error.localizedDescription }
            }
    }
    private func save() {
        let data = BackendJSON.object([
            "name": .string(name), "instruction": .string(instruction),
            "roles": .array(roles.sorted().map(BackendJSON.string)), "enabled": .bool(enabled),
        ])
        let payload = BackendJSON.object([
            "id": item.map { .string($0.id.uuidString) } ?? .null, "data": data,
        ])
        Task {
            do {
                let receipt = try await app.workspace.send(
                    "skill.save", payload: payload, row: item, projectID: UUID(uuidString: project), key: key)
                app.skills.selectedID = receipt.operationId
                dismiss()
            } catch { self.error = error.localizedDescription }
        }
    }
}
