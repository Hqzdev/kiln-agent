import BlotAPI
import SwiftUI

struct RunWorkspaceView: View {
    @Environment(AppState.self) private var app
    let runID: UUID
    @State private var tab = "Переписка"
    @State private var refinement = ""
    @State private var evidence: WorkspaceEvidence?
    private var run: WorkspaceRow? { app.workspace.find("RUN", runID) }
    var body: some View {
        if let run {
            VStack(spacing: 0) {
                header(run)
                Picker("Раздел запуска", selection: $tab) {
                    ForEach(["Переписка", "План и задачи", "Результаты и Git"], id: \.self) {
                        Text($0).tag($0)
                    }
                }.pickerStyle(.segmented).padding(16)
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 20) {
                        RunDecisionsView(run: run)
                        if tab == "Переписка" {
                            RunMessagesView(run: run)
                        } else if tab == "План и задачи" {
                            RunPlanView(run: run)
                            RunTasksView(run: run, evidence: $evidence)
                        } else {
                            RunResultsView(run: run, evidence: $evidence)
                        }
                    }.padding(20).frame(maxWidth: K.contentWidth).frame(maxWidth: .infinity)
                }
                if !["COMPLETED", "CANCELLED", "FAILED"].contains(run.data.text("status")) {
                    HStack(alignment: .top) {
                        TextField(
                            "Уточнить цель или ограничения — будет создана новая версия плана",
                            text: $refinement, axis: .vertical
                        ).lineLimit(2...5)
                        Button("Уточнить") {
                            Task {
                                do {
                                    _ = try await app.workspace.send(
                                        "run.steer",
                                        payload: .object([
                                            "id": .string(run.id.uuidString),
                                            "goal": .string(
                                                run.data.text("goal") + "\n\nУточнение пользователя:\n"
                                                    + refinement),
                                        ]), row: run)
                                    refinement = ""
                                } catch { /* Ошибка показана в общей панели команд. */  }
                            }
                        }.disabled(
                            refinement.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                || !app.workspace.commands.active.isEmpty)
                    }.padding(16).kBorder(.top)
                }
            }.onAppear { if app.reviewVisible { tab = "Результаты и Git" } }
                .onChange(of: app.reviewVisible) { _, visible in if visible { tab = "Результаты и Git" } }
                .sheet(item: $evidence) { WorkspaceEvidenceView(evidence: $0) }
        } else {
            CatalogEmptyView(
                title: app.workspace.loading ? "Загрузка запуска…" : "Запуск не найден",
                detail: "Выберите запуск в списке проектов.")
        }
    }
    private func header(_ run: WorkspaceRow) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(run.data.text("goal")).font(KFont.ui(20, .semibold)).textSelection(.enabled)
            HStack {
                Badge(text: run.data.text("status"))
                Text(run.data.text("waitingReason")).font(KFont.caption()).foregroundStyle(K.text2)
                Spacer()
                let status = run.data.text("status")
                if status == "AWAITING_PLAN" {
                    Button("Посмотреть план") { tab = "План и задачи" }
                }
                if ["PAUSED", "INTERRUPTED", "WAITING"].contains(status) {
                    WorkspaceActionButton(title: "Продолжить", command: "run.resume", row: run)
                } else if ["RUNNING", "PLANNING"].contains(status) {
                    WorkspaceActionButton(title: "Пауза", command: "run.pause", row: run)
                }
                if status == "READY_FOR_ACCEPTANCE" {
                    WorkspaceActionButton(title: "Принять результат", command: "run.accept", row: run)
                }
                if !["COMPLETED", "CANCELLED", "FAILED"].contains(status) {
                    WorkspaceActionButton(title: "Остановить", command: "run.stop", row: run)
                }
                Button("Граф") {
                    app.selectedRunID = run.id.uuidString
                    app.openGraph()
                }
            }
        }.padding(20).kBorder(.bottom)
    }
}
