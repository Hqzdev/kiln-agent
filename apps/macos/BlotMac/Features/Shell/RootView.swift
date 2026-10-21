import BlotAPI
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var state
    @Namespace private var blotNamespace
    @Environment(\.accessibilityReduceMotion) private var systemReduceMotion
    @State private var loadingWorkspace = true
    private var reducedMotion: Bool { systemReduceMotion || state.settings.reduceMotion }
    var body: some View {
        Group {
            if state.isSignedIn { workspace.disabled(state.isSigningOut) }
            else { LoginView() }
        }
        .background(K.bg)
        .environment(\.blotNamespace, blotNamespace)
        .environment(\.blotReduceMotion, reducedMotion)
        .transaction { transaction in
            if reducedMotion { transaction.animation = nil; transaction.disablesAnimations = true }
        }
        .background(WindowChrome().frame(width: 0, height: 0))
        .onExitCommand { state.handleEscape() }
        .overlay { if state.isSignedIn && state.paletteVisible { CommandPaletteView() } }
        .onChange(of: state.paletteVisible) { _, visible in if visible { KMenuController.shared.close() } }
        .onAppear {
            state.shell.history.record(state.shellDestination)
        }
        .task(id: state.currentUser?.email) {
            loadingWorkspace = true
            await state.workspaceLibrary.restoreAccount(state.currentUser?.email)
            guard !Task.isCancelled else { return }
            withAnimation(reducedMotion ? nil : KMotion.loading) { loadingWorkspace = false }
        }
        .task(id: (state.currentUser?.accountID?.uuidString ?? "") + BackendRuntime.shared.client.baseURL.absoluteString) {
            guard let ownerID = state.currentUser?.accountID else { return }
            await state.workspace.observe(client: BackendRuntime.shared.client, ownerID: ownerID)
        }
        .onChange(of: state.shellDestination) { _, destination in state.shell.history.record(destination) }
        .onChange(of: state.shellProjectID) { _, _ in state.shell.previewSource = nil }
    }
    private var workspace: some View {
        VStack(spacing: 0) {
            ShellToolbar()
            if state.isSignedIn { WorkspaceStatusView() }
            HStack(spacing: 0) {
                NavigationRail().zIndex(1)
                if state.shellSidebarVisible {
                    Group {
                        if state.showingSettings { SettingsSidebar() }
                        else if loadingWorkspace { SidebarSkeleton() }
                        else { Sidebar() }
                    }.frame(width: state.shell.sidebarWidth)
                        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 12, bottomLeadingRadius: 12))
                        .overlay(alignment: .trailing) { SidebarResizeHandle().offset(x: 2) }
                        .transition(reducedMotion ? .identity : .move(edge: .leading).combined(with: .opacity))
                }
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Group {
                            if loadingWorkspace { ContentSkeleton() }
                            else { main }
                        }.frame(maxWidth: .infinity, maxHeight: .infinity)
                        if state.shellPanelVisible {
                            let expanded = state.shellRightExpanded
                            if expanded { VDivider() }
                            Group {
                                if loadingWorkspace { ContentSkeleton() }
                                else { ShellRightPane() }
                            }.frame(width: expanded ? min(640, geometry.size.width * 0.53) : K.projectPanelWidth)
                                .transition(reducedMotion ? .identity : .move(edge: .trailing).combined(with: .opacity))
                        }
                    }
                }.background(K.bg)
                    .clipShape(UnevenRoundedRectangle(topLeadingRadius: state.shellSidebarVisible ? 0 : 12,
                                                     bottomLeadingRadius: state.shellSidebarVisible ? 0 : 12,
                                                     bottomTrailingRadius: 12, topTrailingRadius: 12))
            }.padding(.trailing, K.shellInset).padding(.bottom, K.shellInset)
        }.background(K.bgChrome).ignoresSafeArea(.container, edges: .top)
            .animation(reducedMotion ? nil : KMotion.sidebar, value: state.shellSidebarVisible)
            .animation(reducedMotion ? nil : KMotion.sidebar, value: state.shellPanelVisible)
    }
    @ViewBuilder private var main: some View {
        if state.showingSettings { SettingsView() }
        else if state.profileVisible { ProfilePageView() }
        else if let tool = state.activeTool { WorkspaceToolsView(tool: tool) }
        else {
            switch state.product {
            case .code:
                switch state.codeRoute {
                case .home: HomeView()
                case .blot: BlotMotionPreview()
                case .motes:
                    switch state.teamRoute {
                    case .newRun: NewRunView()
                    case .chat: TeamChatView()
                    case .graph: TeamGraphView()
                    }
                case .automations: AutomationsView()
                case .skills: SkillsView()
                case let .task(projectID, taskID):
                    if let task = state.task(projectID: projectID, taskID: taskID) { TaskChatView(projectID: projectID, task: task) }
                    else { CatalogEmptyView(title: "Task not found", detail: "Choose another conversation in the sidebar.") }
                }
            case .work:
                switch state.workRoute {
                case .home, .chat: WorkChatView()
                case .automations: AutomationsView()
                case .skills: SkillsView()
                case .blot: BlotMotionPreview()
                }
            }
        }
    }
}
