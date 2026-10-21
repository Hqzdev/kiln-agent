import SwiftUI

struct GeneralSettingsView: View {
    @Bindable var settings: SettingsState
    @State private var changeFolder = false
    @State private var checked = false
    var body: some View {
        SettingsGroup(title: "Workspace") {
            SettingsRow(title: "Projects folder", detail: "New projects and tasks started outside a project are stored here.") {
                HStack(spacing: 10) {
                    Text(settings.projectsFolder).font(KFont.mono(11)).foregroundStyle(K.text2)
                    KButton(title: "Change") { changeFolder = true }
                }
            }
            HDivider()
            SettingsRow(title: "Open files in", detail: "Where files and folders open when you click a path.") {
                SettingsChoice(value: $settings.editor, options: ["VS Code", "Xcode", "Cursor", "System default"])
            }
            HDivider()
            SettingsRow(title: "Language", detail: "Language of the app interface. Blot answers in the language you write in.") {
                SettingsChoice(value: $settings.language, options: ["Auto detect", "English", "Русский"])
            }
        }
        SettingsGroup(title: "Behavior") {
            SettingsToggleRow(title: "Show in menu bar", detail: "Keep Blot in the menu bar while tasks run with the window closed.", value: $settings.menuBar)
            HDivider()
            SettingsToggleRow(title: "Prevent sleep while a task runs", detail: "Keep the Mac awake until Blot finishes or stops to ask you.", value: $settings.preventSleep)
            HDivider()
            SettingsRow(title: "Notify when a task finishes", detail: "Send a macOS notification when a task completes or needs approval.") {
                SettingsChoice(value: $settings.completionNotice, options: ["When in background", "Always", "Never"])
            }
            HDivider()
            SettingsToggleRow(title: "Confirm before quitting", detail: "Warn if quitting would stop tasks that are still running.", value: $settings.confirmQuit)
        }
        SettingsGroup(title: "Updates") {
            SettingsRow(title: "Release channel", detail: "Beta gets new agent features about two weeks earlier.") {
                SettingsChoice(value: $settings.releaseChannel, options: ["Stable", "Beta"])
            }
            HDivider()
            SettingsRow(title: "Blot 1.4.2", detail: checked ? "Preview · no update service connected" : "Up to date · checked 12 minutes ago") {
                KButton(title: "Check now") { checked = true }
            }
        }
        .sheet(isPresented: $changeFolder) {
            SettingsEditSheet(title: "Projects folder", label: "Folder path", initialValue: settings.projectsFolder) {
                settings.projectsFolder = $0
            }
        }
    }
}

struct SettingsEditSheet: View {
    @Environment(\.dismiss) private var dismiss
    let title: String
    let label: String
    @State private var value: String
    let save: (String) -> Void
    init(title: String, label: String, initialValue: String = "", save: @escaping (String) -> Void) {
        self.title = title
        self.label = label
        _value = State(initialValue: initialValue)
        self.save = save
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(title).font(KFont.ui(20, .semibold)).foregroundStyle(K.text)
            SettingsTextField(label: label, text: $value)
            Text("Saved for this preview session.").font(KFont.body()).foregroundStyle(K.text3)
            HStack {
                Spacer()
                KButton(title: "Cancel") { dismiss() }.keyboardShortcut(.cancelAction)
                KButton(title: "Save", kind: .primary) {
                    save(value.trimmingCharacters(in: .whitespacesAndNewlines)); dismiss()
                }
                .disabled(value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }.padding(24).frame(width: 440).background(K.bg)
    }
}
