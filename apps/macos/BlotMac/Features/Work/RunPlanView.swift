import BlotAPI
import SwiftUI

struct RunPlanView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    var body: some View {
        if let plan = app.workspace.find("PLAN", run.data.uuid("planId")) {
            SettingsGroup(title: "Требования · версия \(run.data.integer("requirementsVersion"))") {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(plan.data.items("requirements").enumerated()), id: \.offset) { entry in
                        Text(entry.element.text("key") + ": " + entry.element.text("content")).textSelection(
                            .enabled)
                    }
                }.padding(16)
            }
            SettingsGroup(title: "Предложенный план") {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(plan.data.items("steps").enumerated()), id: \.offset) { entry in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(entry.element.text("key") + " · " + entry.element.text("title")).font(
                                KFont.body(.semibold))
                            Text(
                                entry.element.text("role") + " · "
                                    + entry.element.strings("paths").joined(separator: ", ")
                            ).foregroundStyle(K.text2)
                            ForEach(entry.element.strings("criteria"), id: \.self) { Text("• " + $0) }
                            if !entry.element.strings("dependencies").isEmpty {
                                Text(
                                    "Зависимости: "
                                        + entry.element.strings("dependencies").joined(separator: ", "))
                            }
                        }
                    }
                    DisclosureGroup("Покрытие требований") {
                        Text(plan.data.value("coverage").formatted).font(KFont.mono(11)).textSelection(
                            .enabled)
                    }
                    if run.data.text("status") == "AWAITING_PLAN" {
                        WorkspaceActionButton(
                            title: "Принять этот план и начать работу", command: "run.plan.approve", row: run)
                    }
                }.padding(16)
            }
        } else {
            Text("План ещё не подготовлен.").foregroundStyle(K.text2)
        }
    }
}

struct RunTasksView: View {
    @Environment(AppState.self) private var app
    let run: WorkspaceRow
    @Binding var evidence: WorkspaceEvidence?
    var body: some View {
        SettingsGroup(title: "Задачи и зависимости") {
            ForEach(app.workspace.rows("TASK", parentID: run.id), id: \.id) { task in
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Button(task.data.text("title")) {
                            evidence = WorkspaceEvidence(kind: "TASK", id: task.id)
                        }.buttonStyle(.plain)
                        Spacer()
                        Badge(text: task.data.text("status"))
                        if ["FAILED", "INTERRUPTED"].contains(task.data.text("status")) {
                            WorkspaceActionButton(title: "Повторить", command: "task.retry", row: task)
                        }
                    }
                    Text(
                        task.data.text("role")
                            + " · версия требований \(task.data.integer("requirementsVersion"))"
                    ).foregroundStyle(K.text2)
                    ForEach(task.data.strings("criteria"), id: \.self) { Text("• " + $0) }
                    ForEach(task.data.strings("dependencies"), id: \.self) { id in
                        if let dependency = app.workspace.find("TASK", id) {
                            Text(
                                "Зависит от: " + dependency.data.text("title") + " · "
                                    + dependency.data.text("status")
                            ).font(KFont.caption())
                        }
                    }
                }.font(KFont.body()).padding(14)
            }
        }
    }
}
