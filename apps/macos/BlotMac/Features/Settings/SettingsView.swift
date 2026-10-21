import SwiftUI

struct SettingsSidebar: View {
    @Environment(AppState.self) private var app
    var body: some View {
        @Bindable var settings = app.settings
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    Text("Settings")
                        .font(KFont.sidebarTitle())
                        .foregroundStyle(K.text)
                    Spacer()
                    Button {
                        app.showingSettings = false
                    } label: {
                        HStack(spacing: 5) {
                            KIcon("chevron-left", size: 14, color: K.text2)
                        }
                    }
                    .buttonStyle(KButtonStyle(kind: .ghost, height: 28))
                    .help("Вернуться к задачам")
                }
                .padding(.leading, 18).padding(.trailing, 8)
                .frame(height: K.headerHeight)
                HStack(spacing: 8) {
                    KIcon("search", size: 14, color: K.text3)
                    TextField("Search settings", text: $settings.search)
                        .textFieldStyle(.plain).font(KFont.body())
                }
                .padding(8).background(K.surface2, in: RoundedRectangle(cornerRadius: 6))
                .padding(.horizontal, 12).padding(.bottom, 4)
                ScrollView {
                    VStack(spacing: K.sidebarRowSpacing) {
                        ForEach(["Personal", "Agent", "Integrations"], id: \.self) { group in
                            let sections = SettingsSection.allCases.filter {
                                $0.group == group && (settings.search.isEmpty ||
                                    $0.rawValue.localizedCaseInsensitiveContains(settings.search))
                            }
                            if !sections.isEmpty {
                                SectionLabel(title: group, actionIcon: nil)
                                ForEach(sections) { section in
                                    SidebarItem(icon: section.icon, label: section.rawValue,
                                                active: settings.section == section) {
                                        settings.section = section
                                    }
                                }
                            }
                        }
                        if !settings.search.isEmpty && !SettingsSection.allCases.contains(where: {
                            $0.rawValue.localizedCaseInsensitiveContains(settings.search)
                        }) {
                            Text("No settings found").font(KFont.body()).foregroundStyle(K.text3).padding()
                        }
                    }.padding(.horizontal, 8)
                }.scrollIndicators(.never)
                Text("Настройки этого Mac")
                    .font(KFont.caption()).foregroundStyle(K.text3).padding(18)
            }
            .background(K.bgSidebar).kBorder(.trailing)
    }
}

struct SettingsView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        @Bindable var settings = app.settings
        PageContent {
            VStack(alignment: .leading, spacing: 32) {
                Text(settings.section.rawValue).font(KFont.pageTitle()).foregroundStyle(K.text)
                page
            }
        }
        .background(K.bg)
    }

    @ViewBuilder private var page: some View {
        switch app.settings.section {
        case .general: GeneralSettingsView(settings: app.settings)
        case .permissions: PermissionsSettingsView(settings: app.settings)
        case .models: ModelsSettingsView(settings: app.settings)
        case .appearance, .notifications, .shortcuts, .account, .billing:
            PersonalSettingsView(settings: app.settings)
        case .environments: VirtualMachineSettingsView()
        case .instructions, .skills:
            AgentSettingsView(settings: app.settings)
        case .git: ProjectAccessSettingsView()
        case .servers, .editors, .browser:
            IntegrationSettingsView(settings: app.settings)
        }
    }
}
