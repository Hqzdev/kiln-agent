import BlotAPI
import AppKit
import SwiftUI

struct ShellToolbar: View {
    @Environment(AppState.self) private var app
    @State private var windowAnchor = KMenuAnchor()
    var body: some View {
        HStack(spacing: 8) {
            HStack(spacing: 4) {
                Color.clear.frame(width: 88)
                IconButton(icon: "chevron-left", size: 28, iconSize: 14, help: "Back") { app.navigateHistory(-1) }
                    .disabled(!app.shell.history.canGoBack)
                IconButton(icon: "chevron-right", size: 28, iconSize: 14, help: "Forward") { app.navigateHistory(1) }
                    .disabled(!app.shell.history.canGoForward)
                if (app.activeTool == nil && !app.profileVisible) || app.showingSettings {
                    IconButton(icon: "sidebar.left", size: 28, iconSize: 14, help: "Toggle sidebar · ⌃⌘S") { app.sidebarVisible.toggle() }
                }
                Spacer(minLength: 0)
            }.frame(width: navigationWidth)
            if !isHome && !isProfile { KIcon(app.activeTool?.icon ?? "folder", size: 14, color: K.text3) }
            Text(isHome || isProfile ? "" : app.shellTitle).font(KFont.body(.medium)).foregroundStyle(K.text).lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading).padding(.leading, 5)
            if app.activeTool == nil, !app.profileVisible, app.product == .code, let task = app.currentTask, !app.showingSettings {
                Text(app.workspace.find("RUN", task.id)?.data.text("status") ?? "")
                    .font(KFont.caption()).foregroundStyle(task.isRunning ? K.success : K.text3)
            }
            if app.isMotes && app.shellHasConversation && !app.showingSettings {
                Text(app.workspace.find("RUN", app.selectedRunID)?.data.text("status") ?? "").font(KFont.caption()).foregroundStyle(K.text3)
                IconButton(icon: ["PAUSED", "WAITING", "INTERRUPTED"].contains(runStatus) ? "play" : "pause", size: 22,
                           iconSize: 12, help: "Pause / Resume") { app.pauseOrResumeRun() }
                    .disabled(!["RUNNING", "PLANNING", "PAUSED", "WAITING", "INTERRUPTED"].contains(runStatus))
                IconButton(icon: "stop", size: 22, iconSize: 12, help: "Stop run") { app.stopCurrentWorkRun() }
                    .disabled(runStatus.isEmpty || ["COMPLETED", "CANCELLED", "FAILED"].contains(runStatus))
            }
            if let conversation = app.currentConversation { ConversationToolbarMenu(item: conversation) }
            if !isProfile {
                IconButton(icon: "list-filter", size: 28, iconSize: 17, help: "Toggle project context") {
                    app.toggleShellPanel()
                }.kHover(radius: K.rMd, active: app.shellPanelVisible)
                    .disabled(app.showingSettings || !app.shellSupportsProjectPanel)
                VDivider().frame(height: 18).padding(.horizontal, 3)
                IconButton(icon: "maximize-2", size: 28, iconSize: 15, help: "Toggle full screen") {
                    windowAnchor.view?.window?.toggleFullScreen(nil)
                }.background(KMenuAnchorView(anchor: windowAnchor))
                Button { app.sidebarVisible.toggle() } label: {
                    Text("\(visiblePanels)").font(KFont.ui(10, .medium)).foregroundStyle(K.text2)
                        .frame(width: 14, height: 14)
                        .overlay(RoundedRectangle(cornerRadius: 3).strokeBorder(K.text3, lineWidth: 1.2))
                        .frame(width: 28, height: 28).kHover(radius: K.rMd)
                }.buttonStyle(KIconButtonStyle()).kFocusRing()
                    .accessibilityLabel("Toggle sidebar · \(visiblePanels) panels visible").help("Toggle sidebar · ⌃⌘S")
            }
        }
        .padding(.trailing, 8).frame(height: K.shellToolbarHeight).background(K.bgChrome)
        .onExitCommand { app.handleEscape() }
    }
    private var runStatus: String { app.workspace.find("RUN", app.selectedRunID)?.data.text("status") ?? "" }
    private var visiblePanels: Int { (app.shellSidebarVisible ? 1 : 0) + (app.shellPanelVisible ? 1 : 0) }
    private var navigationWidth: Double {
        max(184, app.shellSidebarVisible ? app.shell.sidebarWidth + K.railWidth - 8 : 184)
    }
    private var isHome: Bool { app.activeTool == nil && !app.profileVisible && !app.showingSettings && app.product == .code && app.codeRoute == .home }
    private var isProfile: Bool { app.profileVisible && !app.showingSettings }
}
