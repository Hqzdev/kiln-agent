import BlotAPI
import SwiftUI

struct PermissionsSettingsView: View {
    @Environment(AppState.self) private var app
    @Bindable var settings: SettingsState
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(
                "Разрешение связано с точным действием, исходной версией, сроком и одним использованием. Агент не может выдать его себе."
            )
            .font(KFont.body()).foregroundStyle(K.text2)
            let actions = app.workspace.rows("PREPARED_ACTION").filter {
                ["PREPARED", "EXECUTING"].contains($0.data.text("status"))
            }
            if actions.isEmpty { Text("Нет действий, ожидающих разрешения.").foregroundStyle(K.text3) }
            ForEach(actions, id: \.id) { PreparedActionView(action: $0) }
        }
    }
}
