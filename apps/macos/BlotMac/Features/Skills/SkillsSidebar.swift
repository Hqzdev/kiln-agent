import BlotAPI
import SwiftUI

struct SkillsSidebar: View {
    @Environment(AppState.self) private var app
    @State private var creating = false
    var body: some View {
        @Bindable var selection = app.skills
        VStack(spacing: 12) {
            KButton(title: "Создать навык", icon: "plus") { creating = true }.padding(.horizontal, 16)
            CatalogSearch(placeholder: "Поиск навыков", text: $selection.search)
            ScrollView {
                LazyVStack(spacing: 3) {
                    ForEach(
                        app.workspace.rows("SKILL").filter {
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
                                    (row.data.flag("enabled") ? "Включён" : "Выключен")
                                        + " · версия \(row.version)"
                                ).font(KFont.caption()).foregroundStyle(K.text2)
                            }.frame(maxWidth: .infinity, alignment: .leading).padding(12).kHover(
                                radius: K.rMd, active: selection.selectedID == row.id)
                        }.buttonStyle(.plain)
                    }
                }.padding(.horizontal, 8)
            }
        }.sheet(isPresented: $creating) { SkillEditorView() }
    }
}
