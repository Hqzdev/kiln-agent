import SwiftUI

struct TeamChatView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        if let id = UUID(uuidString: app.selectedRunID) {
            RunWorkspaceView(runID: id).id(id)
        } else {
            CatalogEmptyView(
                title: "Выберите запуск", detail: "Создайте задание или откройте существующий запуск.")
        }
    }
}
