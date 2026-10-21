import BlotAPI
import SwiftUI

struct AgentSettingsView: View {
    @Environment(AppState.self) private var app
    @Bindable var settings: SettingsState
    @State private var creating = false
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                "Инструкции сохраняются как версионированные навыки для выбранных ролей и проектов. Они применяются к новым сессиям и не расширяют права инструментов."
            )
            .font(KFont.body()).foregroundStyle(K.text2)
            Button("Создать инструкцию для агентов") { creating = true }
            Button("Открыть сохранённые навыки") {
                app.showingSettings = false
                app.product = .code
                app.codeRoute = .skills
            }
            Text("Сохранено навыков: \(app.workspace.rows("SKILL").count)").font(KFont.caption())
                .foregroundStyle(K.text3)
        }.sheet(isPresented: $creating) { SkillEditorView() }
    }
}
