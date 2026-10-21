import SwiftUI

struct SitesLibraryView: View {
    @Environment(AppState.self) private var app
    @Environment(\.openURL) private var openURL
    @State private var adding = false
    var body: some View {
        PageContent {
            VStack(alignment: .leading, spacing: 0) {
                WorkspacePageHeader(title: "Sites", detail: "Keep useful websites close to your work.") {
                    KButton(title: "Add site", icon: "plus") { adding = true }
                }
                if app.workspaceLibrary.sites.isEmpty {
                    WorkspaceEmptyView(icon: WorkspaceTool.sites.icon, title: "No saved sites",
                                       detail: "Add a website to open it from your workspace.")
                } else {
                    ForEach(app.workspaceLibrary.sites) { site in
                        HStack(spacing: 12) {
                            KIcon("globe", size: 20, color: K.text2)
                            Button { openURL(site.url) } label: {
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(site.name).font(KFont.body(.medium)).foregroundStyle(K.text)
                                    Text(site.url.host ?? site.url.absoluteString).font(KFont.caption()).foregroundStyle(K.text2)
                                }.frame(maxWidth: .infinity, alignment: .leading).contentShape(Rectangle())
                            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
                            IconButton(icon: "square-arrow-out-up-right", help: "Open \(site.name)") { openURL(site.url) }
                            IconButton(icon: "trash-2", help: "Remove \(site.name)") { app.workspaceLibrary.removeSite(site.id) }
                        }.padding(.vertical, 14)
                        HDivider()
                    }
                }
            }
        }
        .sheet(isPresented: $adding) { SiteEditorView { app.workspaceLibrary.saveSite($0) } }
    }
}

private struct SiteEditorView: View {
    @Environment(\.dismiss) private var dismiss
    let save: (SavedSite) -> Void
    @State private var name = ""
    @State private var address = ""
    private var url: URL? {
        let value = address.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty,
              let url = URL(string: value.contains("://") ? value : "https://" + value),
              ["http", "https"].contains(url.scheme?.lowercased() ?? ""),
              let host = url.host, !host.isEmpty, url.user == nil, url.password == nil else { return nil }
        return url
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Add site").font(KFont.ui(20, .semibold))
            SettingsTextField(label: "Name", text: $name)
            SettingsTextField(label: "Website URL", text: $address, required: true,
                              error: !address.isEmpty && url == nil ? "Enter a valid http or https address without credentials." : nil)
            HStack {
                Spacer()
                KButton(title: "Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                KButton(title: "Add site", kind: .primary) {
                    guard let url else { return }
                    let title = name.trimmingCharacters(in: .whitespacesAndNewlines)
                    save(SavedSite(id: UUID(), name: title.isEmpty ? url.host ?? address : title, url: url))
                    dismiss()
                }.disabled(url == nil).keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 460).background(K.bg).foregroundStyle(K.text)
    }
}
