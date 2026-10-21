import BlotAPI
import SwiftUI

extension BackendEntity where Value == BackendJSON {
    var idPayload: BackendJSON { .object(["id": .string(id.uuidString)]) }
}

struct WorkspaceActionButton: View {
    @Environment(AppState.self) private var app
    let title: String
    let command: String
    let row: WorkspaceRow
    var payload: BackendJSON?
    var body: some View {
        Button(title) {
            Task { try? await app.workspace.send(command, payload: payload ?? row.idPayload, row: row) }
        }
        .disabled(app.workspace.commands.active.contains(command + ":" + row.id.uuidString))
    }
}

struct WorkspaceStatusView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        let workspace = app.workspace
        if let error = workspace.recoveryError ?? workspace.error ?? workspace.commands.error {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(error).textSelection(.enabled).foregroundStyle(K.warning)
                    Spacer()
                    Button("Обновить") { Task { await workspace.refresh() } }
                    if workspace.recoveryError != nil {
                        Button("Восстановить отправленные команды") {
                            Task { await app.recoverWorkspaceCommands() }
                        }
                    }
                }
                ForEach(
                    Array(workspace.commands.pending.values).sorted { $0.id.uuidString < $1.id.uuidString }
                ) { command in
                    HStack {
                        Text("Ожидает подтверждения: " + command.type).font(KFont.caption())
                        Button("Повторить исходную команду") {
                            Task {
                                let receipt = await workspace.commands.retry(command)
                                await workspace.refresh()
                                if let receipt { openResult(receipt, command: command) }
                            }
                        }
                        .disabled(workspace.commands.active.contains(command.key))
                    }
                }
            }.font(KFont.body()).padding(12).frame(maxWidth: .infinity, alignment: .leading).background(
                K.surface2)
        } else if workspace.loading || workspace.recoveringCommands {
            HStack {
                ProgressView().controlSize(.small)
                Text(
                    workspace.recoveringCommands
                        ? "Восстановление отправленных команд…" : "Загрузка данных сервера…")
            }
            .font(KFont.caption()).padding(10)
        }
    }

    private func openResult(_ receipt: BackendReceipt, command: WorkspaceCommands.Pending) {
        if command.type == "run.create" {
            if command.key == "create-team-run" {
                app.openWorkRun(receipt.operationId.uuidString)
            } else if let project = command.projectID {
                app.openTask(projectID: project.uuidString, taskID: receipt.operationId.uuidString)
            }
        } else if command.type == "automation.run_now" {
            app.openWorkRun(receipt.operationId.uuidString)
        } else if command.type == "skill.save" {
            app.skills.selectedID = receipt.operationId
        } else if command.type == "automation.save" {
            app.automations.selectedID = receipt.operationId
        }
    }
}
