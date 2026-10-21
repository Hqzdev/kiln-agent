import BlotAPI
import SwiftUI

struct RunCreationView: View {
    @Environment(AppState.self) private var app
    let team: Bool
    @State private var budget = "100000"
    @State private var error: String?
    private var project: Binding<String> {
        Binding(
            get: { team ? app.newRun.projectID : app.newTask.projectID },
            set: { if team { app.newRun.projectID = $0 } else { app.newTask.projectID = $0 } })
    }
    private var goal: Binding<String> {
        Binding(
            get: { team ? app.newRun.goal : app.newTask.draft },
            set: { if team { app.newRun.goal = $0 } else { app.newTask.draft = $0 } })
    }
    private var key: String { team ? "create-team-run" : "create-code-run" }
    var body: some View {
        PageContent {
            VStack(alignment: .leading, spacing: 20) {
                PrimaryBlot(context: team ? .newRun : .home)
                Text(team ? "Что поручить команде?" : "Что нужно сделать в проекте?").font(KFont.pageTitle())
                Text(
                    "Сначала Blot подготовит план. После вашего принятия начнётся работа специалистов и независимое ревью."
                )
                .font(KFont.body()).foregroundStyle(K.text2)
                if app.projects.isEmpty {
                    Text("Сначала подключите Git-репозиторий на этом Mac.")
                    Button("Добавить репозиторий…") {
                        app.settings.section = .git
                        app.showingSettings = true
                    }
                } else {
                    Picker("Проект", selection: project) {
                        Text("Выберите проект").tag("")
                        ForEach(app.projects) { Text($0.name).tag($0.id) }
                    }
                    TextEditor(text: goal).font(KFont.body()).frame(minHeight: 140)
                        .padding(10).kCard(fill: K.surface).accessibilityLabel("Задание для агента")
                    TextField("Бюджет токенов", text: $budget)
                    Text(
                        "Команды выполняются в подготовленной VM. Изменения файлов, commit и push требуют отдельных разрешений."
                    )
                    .font(KFont.caption()).foregroundStyle(K.text2)
                    if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
                    KButton(title: "Подготовить план", icon: "play", kind: .primary) { create() }
                        .disabled(
                            goal.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                || UUID(uuidString: project.wrappedValue) == nil
                                || (Int64(budget) ?? 0) < 8192 || app.workspace.commands.pending[key] != nil)
                }
            }.disabled(app.workspace.commands.active.contains(key))
        }
        .onAppear { selectProject() }
        .onChange(of: app.projects.map(\.id)) { _, _ in selectProject() }
    }
    private func selectProject() {
        if !app.projects.contains(where: { $0.id == project.wrappedValue }) {
            project.wrappedValue = app.projects.first?.id ?? ""
        }
    }
    private func create() {
        guard let projectID = UUID(uuidString: project.wrappedValue), let tokens = Int64(budget) else {
            return
        }
        let content = goal.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines)
        error = nil
        Task {
            do {
                let receipt = try await app.workspace.send(
                    "run.create",
                    payload: .object(["goal": .string(content), "tokenBudget": .integer(tokens)]),
                    projectID: projectID, key: key)
                goal.wrappedValue = ""
                if team {
                    app.openWorkRun(receipt.operationId.uuidString)
                } else {
                    app.openTask(projectID: projectID.uuidString, taskID: receipt.operationId.uuidString)
                }
            } catch { self.error = error.localizedDescription }
        }
    }
}
