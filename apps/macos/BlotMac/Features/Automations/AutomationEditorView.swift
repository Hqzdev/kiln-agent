import BlotAPI
import SwiftUI

struct AutomationEditorView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let item: WorkspaceRow?
    @State private var name: String
    @State private var goal: String
    @State private var project: String
    @State private var timezone: String
    @State private var time: String
    @State private var weekdays: Set<Int>
    @State private var budget: String
    @State private var enabled: Bool
    @State private var error: String?
    private var key: String { "automation.editor:" + (item?.id.uuidString ?? "new") }
    init(
        item: WorkspaceRow? = nil, initialTitle: String = "", initialInstructions: String = "",
        initialProject: String = ""
    ) {
        self.item = item
        _name = State(initialValue: item?.data.text("name") ?? initialTitle)
        _goal = State(initialValue: item?.data.text("goal") ?? initialInstructions)
        _project = State(initialValue: item?.projectId?.uuidString ?? initialProject)
        _timezone = State(initialValue: item?.data.text("timezone") ?? TimeZone.current.identifier)
        _time = State(initialValue: item?.data.text("localTime") ?? "09:00")
        _weekdays = State(
            initialValue: item.map {
                Set(
                    $0.data.items("weekdays").compactMap {
                        if case .integer(let day) = $0 { return Int(day) }
                        return nil
                    })
            } ?? Set(1...5))
        _budget = State(initialValue: item.map { String($0.data.integer("tokenBudget")) } ?? "100000")
        _enabled = State(initialValue: item?.data.flag("enabled") ?? true)
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(item == nil ? "Новое расписание" : "Изменить расписание").font(KFont.ui(20, .semibold))
            Group {
                TextField("Название", text: $name)
                Picker("Проект", selection: $project) {
                    Text("Выберите проект").tag("")
                    ForEach(app.projects) { Text($0.name).tag($0.id) }
                }.disabled(item != nil)
                HStack {
                    TextField("Время HH:mm", text: $time)
                    TextField("Часовой пояс", text: $timezone)
                }
                HStack {
                    ForEach(Array(["Пн", "Вт", "Ср", "Чт", "Пт", "Сб", "Вс"].enumerated()), id: \.offset) {
                        day in
                        Toggle(
                            day.element,
                            isOn: Binding(
                                get: { weekdays.contains(day.offset + 1) },
                                set: {
                                    if $0 {
                                        weekdays.insert(day.offset + 1)
                                    } else {
                                        weekdays.remove(day.offset + 1)
                                    }
                                })
                        ).toggleStyle(.checkbox)
                    }
                }
                TextField("Бюджет токенов на запуск", text: $budget)
                TextEditor(text: $goal).font(KFont.body()).frame(height: 180).padding(8).kCard(
                    fill: K.surface)
                Toggle("Расписание включено", isOn: $enabled)
            }.disabled(app.workspace.commands.pending[key] != nil)
            if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
            HStack {
                Spacer()
                Button("Отмена") { dismiss() }
                Button(
                    app.workspace.commands.pending[key] == nil ? "Сохранить" : "Повторить исходное сохранение"
                ) { save() }
                .disabled(!valid || app.workspace.commands.active.contains(key)).keyboardShortcut(
                    .defaultAction)
            }
        }.padding(24).frame(width: 640).background(K.bg).foregroundStyle(K.text)
            .onAppear { if project.isEmpty { project = app.projects.first?.id ?? "" } }
    }
    private var valid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && !goal.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            && UUID(uuidString: project) != nil && !weekdays.isEmpty && (Int64(budget) ?? 0) >= 8192
            && TimeZone(identifier: timezone) != nil
            && time.range(of: "^([01][0-9]|2[0-3]):[0-5][0-9]$", options: .regularExpression) != nil
    }
    private func save() {
        let data = BackendJSON.object([
            "name": .string(name), "goal": .string(goal), "timezone": .string(timezone),
            "localTime": .string(time), "weekdays": .array(weekdays.sorted().map { .integer(Int64($0)) }),
            "enabled": .bool(enabled), "tokenBudget": .integer(Int64(budget) ?? 0),
        ])
        let payload = BackendJSON.object([
            "id": item.map { .string($0.id.uuidString) } ?? .null, "data": data,
        ])
        Task {
            do {
                let receipt = try await app.workspace.send(
                    "automation.save", payload: payload, row: item, projectID: UUID(uuidString: project),
                    key: key)
                app.automations.selectedID = receipt.operationId
                dismiss()
            } catch { self.error = error.localizedDescription }
        }
    }
}
