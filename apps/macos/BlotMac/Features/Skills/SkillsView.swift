import BlotAPI
import SwiftUI

struct SkillsView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        CatalogDetail {
            if let row = app.workspace.find("SKILL", app.skills.selectedID) {
                SkillDetailView(item: row).id(row.id)
            } else {
                CatalogEmptyView(
                    title: "Навыки", detail: "Выберите навык слева или создайте инструкцию для специалистов.")
            }
        }
    }
}
