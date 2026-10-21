import AppKit
import SwiftUI

struct ProfileSheetView: View {
    @Environment(AppState.self) private var app
    @Environment(\.dismiss) private var dismiss
    let sheet: ProfileSheet
    @State private var invitation = "Try Blot with me — a workspace for building with AI, reviewing changes and working with a team of agents."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Text(title).font(KFont.ui(20, .semibold)).foregroundStyle(K.text)
                Spacer()
                IconButton(icon: "xmark", help: "Close") { dismiss() }
            }
            switch sheet {
            case .invitation: invite
            case .guide: guide
            case .about: about
            }
            HStack {
                Spacer()
                KButton(title: "Done") { dismiss() }.keyboardShortcut(.cancelAction)
            }
        }
        .padding(24).frame(width: 440).background(K.bg)
        .preferredColorScheme(app.theme.colorScheme)
        .onExitCommand { dismiss() }
    }

    private var title: String {
        switch sheet {
        case .invitation: "Invite a friend"
        case .guide: "Getting started"
        case .about: "About Blot"
        }
    }

    private var invite: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Copy a message to share Blot with a friend.").font(KFont.body()).foregroundStyle(K.text2)
            TextEditor(text: $invitation).font(KFont.body()).foregroundStyle(K.text)
                .scrollContentBackground(.hidden).frame(height: 110).padding(10).kCard()
                .kFocusRing()
                .accessibilityLabel("Invitation message")
            CopyButton(text: invitation, title: "Copy invitation", kind: .primary)
        }
    }

    private var guide: some View {
        VStack(alignment: .leading, spacing: 16) {
            guideSection("Start a task", "Choose a project in Code, write your request and send it. ⌘N opens a new task.")
            guideSection("Work with a team", "Open Motes in Code and create a run. Choose roles, then follow the team in Chat or Graph.")
            guideSection("Review the result", "Open Review to inspect Changes, Terminal and Preview. Keep the conversation open for follow-up changes.")
            guideSection("Find your way", "⌘K searches tasks, files and actions. Esc closes menus or stops the active task.")
        }
    }

    private var about: some View {
        VStack(alignment: .leading, spacing: 12) {
            BlotView(size: 76, behavior: .subtle)
            Text("Blot").font(KFont.pageTitle()).foregroundStyle(K.text)
            Text("Version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")")
                .font(KFont.body()).foregroundStyle(K.text3)
            Text("A workspace for tasks, agent teams and reviewing changes.").font(KFont.body()).foregroundStyle(K.text2)
        }
    }

    private func guideSection(_ heading: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(heading).font(KFont.body(.semibold)).foregroundStyle(K.text)
            Text(text).font(KFont.body()).foregroundStyle(K.text2).fixedSize(horizontal: false, vertical: true)
        }
    }
}
