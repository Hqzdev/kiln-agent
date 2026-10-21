import BlotAPI
import SwiftUI

struct AutomationsSidebar: View {
    @Environment(AppState.self) private var app
    @State private var creating = false
    var body: some View {
        @Bindable var selection = app.automations
        VStack(spacing: 12) {
            KButton(title: "Новое расписание", icon: "plus") { creating = true }.padding(.horizontal, 16)
            CatalogSearch(placeholder: "Поиск расписаний", text: $selection.search)
            ScrollView {
                LazyVStack(spacing: 3) {
                    ForEach(
                        app.workspace.rows("AUTOMATION").filter {
                            selection.search.isEmpty
                                || $0.data.text("name").localizedCaseInsensitiveContains(selection.search)
                        }, id: \.id
                    ) { row in
                        Button {
                            selection.selectedID = row.id
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(row.data.text("name")).font(KFont.body(.medium))
                                Text(
                                    (row.data.flag("enabled") ? "Активно" : "Пауза") + " · "
                                        + row.data.text("localTime")
                                ).font(KFont.caption()).foregroundStyle(K.text2)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(12).kHover(
                                radius: K.rMd, active: selection.selectedID == row.id)
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 8)
            }
        }.sheet(isPresented: $creating) { AutomationEditorView() }
    }
}
