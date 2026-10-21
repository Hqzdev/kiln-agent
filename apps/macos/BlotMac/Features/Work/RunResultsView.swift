import BlotAPI
import SwiftUI

struct RunResultsView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    @Binding var evidence: WorkspaceEvidence?
    private var sessions: Set<UUID> { Set(app.workspace.rows("AGENT_SESSION", parentID: run.id).map(\.id)) }
    private var tasks: [WorkspaceRow] { app.workspace.rows("TASK", parentID: run.id) }
    var body: some View {
        SettingsGroup(title: "Артефакты и независимое ревью") {
            ForEach(tasks, id: \.id) { task in
                VStack(alignment: .leading, spacing: 8) {
                    Text(task.data.text("title")).font(KFont.body(.medium))
                    if let id = task.data.uuid("artifactId") { ArtifactLink(id: id) }
                    ForEach(app.workspace.rows("REVIEW", parentID: task.id), id: \.id) { review in
                        Button(review.data.text("decision") + " · " + String(review.id.uuidString.prefix(8)))
                        { evidence = WorkspaceEvidence(kind: "REVIEW", id: review.id) }
                        Text("Проверен SHA-256: " + review.data.text("artifactHash")).font(KFont.mono(10))
                            .textSelection(.enabled)
                        ForEach(review.data.strings("findings"), id: \.self) { Text("• " + $0) }
                    }
                }.padding(14)
            }
        }
        SettingsGroup(title: "Фактические операции инструментов") {
            ForEach(
                app.workspace.rows("TOOL_OPERATION", projectID: run.projectId).filter {
                    $0.data.uuid("sessionId").map(sessions.contains) == true
                }, id: \.id
            ) { operation in
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Button(operation.data.text("name")) {
                            evidence = WorkspaceEvidence(kind: "TOOL_OPERATION", id: operation.id)
                        }
                        Spacer()
                        Badge(text: operation.data.text("status"))
                    }
                    if !operation.data.text("error").isEmpty {
                        Text(operation.data.text("error")).foregroundStyle(K.warning)
                    }
                    DisclosureGroup("Результат") {
                        Text(operation.data.value("result").formatted).font(KFont.mono(11)).textSelection(
                            .enabled)
                    }
                    if operation.data.text("status") == "UNKNOWN" {
                        WorkspaceActionButton(
                            title: "Сверить фактический исход",
                            command: operation.data.text("name").hasPrefix("git.")
                                ? "git.reconcile" : "tool.reconcile", row: operation)
                    }
                }.padding(14)
            }
        }
        ForEach(app.workspace.rows("BUDGET", parentID: run.id), id: \.id) { budget in
            RunBudgetView(budget: budget)
        }
        if ["READY_FOR_ACCEPTANCE", "COMPLETED"].contains(run.data.text("status")) { RunGitView(run: run) }
        let queue = app.workspace.rows("MODEL_REQUEST", projectID: run.projectId).filter {
            $0.data.uuid("runId") == run.id
        }
        SettingsGroup(title: "Запросы модели") {
            ForEach(queue.reversed(), id: \.id) { request in
                Button(
                    request.data.text("purpose") + " · " + request.data.text("status") + " · "
                        + request.data.text("model")
                ) {
                    evidence = WorkspaceEvidence(kind: "MODEL_REQUEST", id: request.id)
                }.buttonStyle(.plain).padding(12)
            }
        }
    }
}

private struct RunBudgetView: View {
    @Environment(AppState.self) private var app
    let budget: WorkspaceRow
    @State private var limit = ""
    var body: some View {
        SettingsGroup(title: "Бюджет запуска") {
            VStack(alignment: .leading, spacing: 10) {
                Text(
                    "Потрачено \(budget.data.integer("spent")), зарезервировано \(budget.data.integer("reserved")), лимит \(budget.data.integer("limit"))"
                )
                if budget.data.flag("usageUnknown") {
                    Text("Часть расхода неизвестна и учтена консервативно.").foregroundStyle(K.warning)
                }
                HStack {
                    TextField("Новый общий лимит", text: $limit)
                    WorkspaceActionButton(
                        title: "Увеличить", command: "budget.increase", row: budget,
                        payload: .object([
                            "id": .string(budget.id.uuidString), "limit": .integer(Int64(limit) ?? 0),
                        ])
                    )
                    .disabled((Int64(limit) ?? 0) <= budget.data.integer("limit"))
                }
            }.padding(16)
        }
    }
}

private struct RunGitView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    @State private var message = ""
    @State private var remote = "origin"
    @State private var refspec = ""
    var body: some View {
        SettingsGroup(title: "Commit и push") {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    "Каждая операция сначала подготавливается. Затем отдельно просмотрите точные параметры, выдайте разрешение и выполните её."
                )
                .font(KFont.caption()).foregroundStyle(K.text2)
                TextField("Сообщение commit", text: $message)
                Button("Подготовить commit") {
                    prepare("git.prepare_commit", arguments: ["message": .string(message)])
                }
                .disabled(
                    message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        || !app.workspace.commands.active.isEmpty)
                Divider()
                TextField("Remote", text: $remote)
                TextField("Полный refspec: refs/heads/codex/…:refs/heads/codex/…", text: $refspec)
                Button("Подготовить отдельный push") {
                    prepare(
                        "git.prepare_push",
                        arguments: ["remote": .string(remote), "refspec": .string(refspec)])
                }
                .disabled(remote.isEmpty || refspec.isEmpty || !app.workspace.commands.active.isEmpty)
                Text("Защиту основной ветки и соответствие принятому результату проверяет сервер.").font(
                    KFont.caption()
                ).foregroundStyle(K.text2)
            }.padding(16)
        }.onAppear { suggestRefspec() }
    }
    private func suggestRefspec() {
        guard refspec.isEmpty else { return }
        let marker = app.workspace.rows("CHECKPOINT", parentID: run.id).first {
            $0.data.text("phase") == "integration"
                && $0.data.integer("revision") == run.data.integer("requirementsVersion")
        }
        if let task = app.workspace.find("TASK", marker?.data.uuid("taskId")),
            let author = task.data.uuid("authorSessionId")
        {
            let ref = "refs/heads/codex/blot-" + author.uuidString.lowercased()
            refspec = ref + ":" + ref
        }
    }
    private func prepare(_ type: String, arguments: [String: BackendJSON]) {
        Task {
            try? await app.workspace.send(
                type,
                payload: .object(["runId": .string(run.id.uuidString), "arguments": .object(arguments)]),
                row: run)
        }
    }
}
