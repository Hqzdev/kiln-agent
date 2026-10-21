import BlotAPI
import SwiftUI

struct AutomationDetailView: View {
    @Environment(AppState.self) private var app
    let item: WorkspaceRow
    @State private var editing = false
    @State private var deleting = false
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(item.data.text("name")).font(KFont.pageTitle())
                Spacer()
                Button("Изменить") { editing = true }
                Button("Удалить", role: .destructive) { deleting = true }
            }
            Badge(text: item.data.flag("enabled") ? "Активно" : "Пауза")
            Text(
                "Проект: "
                    + (app.workspace.find("PROJECT", item.projectId)?.data.text("name") ?? "Недоступен"))
            Text(item.data.text("localTime") + " · " + item.data.text("timezone"))
            Text(
                "Дни недели: "
                    + item.data.items("weekdays").map {
                        if case .integer(let day) = $0 { return String(day) }
                        return ""
                    }.joined(separator: ", "))
            if item.data.flag("enabled"), let next = WorkspaceDate.parse(item.data.text("nextAt")) {
                Text("Следующее срабатывание: " + next.formatted(date: .abbreviated, time: .shortened))
                Text("Время выше показано в часовом поясе этого Mac.").font(KFont.caption()).foregroundStyle(
                    K.text2)
            }
            Text("Бюджет каждого запуска: \(item.data.integer("tokenBudget")) токенов")
            Text(item.data.text("goal")).textSelection(.enabled)
            HStack {
                Button(item.data.flag("enabled") ? "Приостановить расписание" : "Включить расписание") {
                    toggle()
                }
                Button("Запустить сейчас") { runNow() }
            }.disabled(!app.workspace.commands.active.isEmpty)
            Text(
                "Запуск проходит обычное планирование и разрешения. После сна пропущенные срабатывания объединяются максимум в один запуск."
            ).font(KFont.caption()).foregroundStyle(K.text2)
            SettingsGroup(title: "Фактическая история запусков") {
                let history = app.workspace.rows("CHECKPOINT", parentID: item.id).filter {
                    $0.data.text("phase") == "automation_run"
                }
                if history.isEmpty { Text("Срабатываний ещё не было.").padding(16) }
                ForEach(history.reversed(), id: \.id) { marker in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(marker.data.text("startedAt")).font(KFont.caption())
                        if marker.data.flag("coalesced") { Text("Пропущенные срабатывания объединены") }
                        if let run = app.workspace.find("RUN", marker.data.uuid("runId")) {
                            Button(run.data.text("goal") + " · " + run.data.text("status")) {
                                app.openWorkRun(run.id.uuidString)
                            }
                        } else {
                            Text(
                                marker.data.text("error").isEmpty
                                    ? "Запуск больше недоступен" : marker.data.text("error")
                            ).foregroundStyle(K.warning)
                        }
                    }.padding(14)
                }
            }
        }
        .sheet(isPresented: $editing) { AutomationEditorView(item: item) }
        .confirmationDialog("Удалить расписание?", isPresented: $deleting) {
            Button("Удалить", role: .destructive) {
                Task {
                    try? await app.workspace.send("automation.delete", payload: item.idPayload, row: item)
                }
            }
        }
    }
    private func toggle() {
        guard case .object(var fields) = item.data else { return }
        fields["enabled"] = .bool(!item.data.flag("enabled"))
        let payload = BackendJSON.object(["id": .string(item.id.uuidString), "data": .object(fields)])
        Task {
            try? await app.workspace.send(
                "automation.save", payload: payload, row: item, key: "automation.toggle:" + item.id.uuidString
            )
        }
    }
    private func runNow() {
        Task {
            do {
                let receipt = try await app.workspace.send(
                    "automation.run_now", payload: item.idPayload, row: item)
                app.openWorkRun(receipt.operationId.uuidString)
            } catch { /* Панель команд показывает ошибку. */  }
        }
    }
}
