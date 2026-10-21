import SwiftUI

struct IntegrationSettingsView: View {
    @Bindable var settings: SettingsState
    @State private var addServer = false
    var body: some View {
        switch settings.section {
        case .servers:
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Configured servers").font(KFont.body(.medium)).foregroundStyle(K.text)
                    Spacer()
                    KButton(title: "Add server", icon: "plus") { addServer = true }
                }
                VStack(spacing: 0) {
                    ForEach(settings.servers, id: \.self) { server in
                        SettingsRow(title: server, detail: "Preview configuration · not connected") {
                            HStack(spacing: 12) {
                                KToggle(isOn: Binding(
                                    get: { settings.enabledServers.contains(server) },
                                    set: { enabled in
                                        if enabled { settings.enabledServers.insert(server) }
                                        else { settings.enabledServers.remove(server) }
                                    }
                                )).accessibilityLabel("Enable \(server)")
                                IconButton(icon: "trash-2", help: "Remove \(server)") {
                                    settings.servers.removeAll { $0 == server }
                                    settings.enabledServers.remove(server)
                                }
                            }
                        }
                        if server != settings.servers.last { HDivider() }
                    }
                    if settings.servers.isEmpty {
                        SettingsRow(title: "No MCP servers", detail: "Add a server to preview its configuration.") { KIcon("server") }
                    }
                }.kCard(radius: K.rMd)
            }
            .sheet(isPresented: $addServer) {
                SettingsEditSheet(title: "Add MCP server", label: "Server name") { name in
                    if !settings.servers.contains(name) { settings.servers.append(name) }
                }
            }
        case .git:
            SettingsGroup(title: "Git") {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Branch prefix").font(KFont.body(.medium)).foregroundStyle(K.text)
                    Text("Prefix for branches created by the agent.").font(KFont.body()).foregroundStyle(K.text2)
                    SettingsTextField(label: "Branch prefix", text: $settings.gitBranch)
                }.padding(16)
                HDivider()
                SettingsToggleRow(title: "Include untracked files", detail: "Show new files alongside existing changes in review.", value: $settings.includeUntracked)
                HDivider()
                SettingsToggleRow(title: "Confirm before committing", detail: "Ask before creating a commit from task changes.", value: $settings.confirmCommit)
            }
            SettingsGroup(title: "GitHub") {
                SettingsRow(title: "GitHub account", detail: "Connections will be available when integrations are enabled.") {
                    Badge(text: "Not connected", fg: K.text3)
                }
            }
        case .editors:
            SettingsGroup(title: "Files & folders") {
                SettingsRow(title: "Default editor", detail: "Open project files in your preferred editor.") {
                    SettingsChoice(value: $settings.editor, options: ["VS Code", "Xcode", "Cursor", "System default"])
                }
                HDivider()
                SettingsToggleRow(title: "Preview files in Blot", detail: "Show a file preview before opening it externally.", value: $settings.editorPreview)
            }
        case .browser:
            SettingsGroup(title: "Browser") {
                SettingsRow(title: "Open links in", detail: "Choose where task links open.") {
                    SettingsChoice(value: $settings.browser, options: ["System default", "Safari", "Chrome", "Blot browser"])
                }
                HDivider()
                SettingsToggleRow(title: "Show browser previews", detail: "Display web previews alongside task results.", value: $settings.browserPreview)
                HDivider()
                SettingsToggleRow(title: "Ask before browser actions", detail: "Request approval before submitting forms or changing external content.", value: $settings.askBrowserActions)
            }
        default: EmptyView()
        }
    }
}
