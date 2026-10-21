import BlotAPI
import SwiftUI

struct AutomationsView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        CatalogDetail {
            if let row = app.workspace.find("AUTOMATION", app.automations.selectedID) {
                AutomationDetailView(item: row).id(row.id)
            } else {
                CatalogEmptyView(
                    title: "Локальные расписания",
                    detail: "Создайте расписание. Оно действует, пока приложение и Mac работают.")
            }
        }
    }
}
