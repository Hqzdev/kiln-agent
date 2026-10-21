import SwiftUI

struct PersonalSettingsView: View {
    @Environment(AppState.self) private var app
    @Bindable var settings: SettingsState
    @State private var showUsage = false
    var body: some View {
        @Bindable var app = app
        switch settings.section {
        case .appearance:
            SettingsGroup(title: "Theme") {
                SettingsRow(title: "Appearance", detail: "Choose how Blot looks, or follow your Mac's appearance.") {
                    KSegmented(options: ThemePreference.allCases, selection: $app.theme, label: { $0.rawValue })
                }
            }
            SettingsGroup(title: "Interface") {
                SettingsRow(title: "Text size", detail: "Preferred text size for the interface preview.") {
                    SettingsChoice(value: $settings.fontSize, options: ["Small", "Default", "Large"])
                }
                HDivider()
                SettingsToggleRow(title: "Show agent avatars", detail: "Display role portraits alongside team messages.", value: $settings.showAvatars)
                HDivider()
                SettingsToggleRow(title: "Reduce motion", detail: "Prefer quieter transitions and fewer animated effects.", value: $settings.reduceMotion)
            }
        case .notifications:
            SettingsGroup(title: "Tasks") {
                SettingsRow(title: "Task finished", detail: "Choose when to show completion notifications.") {
                    SettingsChoice(value: $settings.completionNotice, options: ["When in background", "Always", "Never"])
                }
                HDivider()
                SettingsToggleRow(title: "Approval needed", detail: "Let me know when an agent is waiting for a decision.", value: $settings.approvalNotifications)
                HDivider()
                SettingsToggleRow(title: "Task failed", detail: "Show a notification when a task needs attention.", value: $settings.failureNotifications)
            }
            SettingsGroup(title: "Delivery") {
                SettingsToggleRow(title: "Play a sound", value: $settings.notificationSound)
                HDivider()
                SettingsToggleRow(title: "Show message previews", detail: "Include a short task summary in notifications.", value: $settings.notificationPreview)
            }
        case .shortcuts:
            SettingsGroup(title: "Navigation") {
                shortcut("New task / New run", "⌘ N")
                HDivider()
                shortcut("Search tasks, files and actions", "⌘ K")
                HDivider()
                shortcut("Stop active task / run; close an open menu", "Esc")
                HDivider()
                shortcut("Settings", "⌘ ,")
                HDivider()
                shortcut("Blot Code · Task", "⌘ 1")
                HDivider()
                shortcut("Motes · Team chat", "⌘ 2")
                HDivider()
                shortcut("Motes · Team graph", "⌘ 3")
                HDivider()
                shortcut("Show Pet", "⌥ Space")
                HDivider()
                shortcut("Show / hide sidebar", "⌃ ⌘ S")
            }
            Text("These shortcuts match the app menu.").font(KFont.body()).foregroundStyle(K.text3)
        case .account:
            SettingsGroup(title: "Profile") {
                SettingsRow(title: app.profileDetails.name, detail: app.currentUser?.email ?? "Preview account") {
                    InitialsAvatar(initials: app.profileDetails.initials, size: 36)
                }
                HDivider()
                SettingsRow(title: "Plan", detail: "Your personal Blot workspace.") { Badge(text: "Pro") }
            }
            SettingsGroup(title: "Session") {
                SettingsRow(title: "Signed in on this Mac", detail: "Account actions will be available when the account service is connected.") {
                    Badge(text: "Preview", fg: K.text3)
                }
            }
        case .billing:
            SettingsGroup(title: "Your plan") {
                SettingsRow(title: "Blot Pro", detail: "Personal workspace · preview subscription") { Badge(text: "Pro") }
            }
            SettingsGroup(title: "Usage") {
                SettingsRow(title: "Weekly allowance", detail: "\(settings.weeklyUsage.usedPercent)% used · \(settings.weeklyUsage.resetDescription)") {
                    ProgressView(value: settings.weeklyUsage.usedFraction).tint(K.inverse).frame(width: 140)
                }
                HDivider()
                SettingsRow(title: "This month", detail: "38 tasks · 4.1M input · 612K output tokens") {
                    KButton(title: "View details") { showUsage = true }
                }
            }
            SettingsGroup(title: "Billing") {
                SettingsRow(title: "Payment details", detail: "Subscription and payment information is sample data in this preview.") {
                    Badge(text: "Preview", fg: K.text3)
                }
            }.sheet(isPresented: $showUsage) { UsagePreviewView() }
        default: EmptyView()
        }
    }

    private func shortcut(_ title: String, _ keys: String) -> some View {
        SettingsRow(title: title) {
            Text(keys).font(KFont.mono(12)).foregroundStyle(K.text2)
                .padding(.horizontal, 10).padding(.vertical, 6).kCard(radius: 6, fill: K.surface2)
        }
    }
}
