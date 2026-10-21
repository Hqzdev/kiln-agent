import SwiftUI

struct Sidebar: View {
    @Environment(AppState.self) private var app
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 6) {
                if app.shellSection != .scheduled && app.shellSection != .skills {
                    ProductModePicker(title: app.shellSection == .chats ? "Blot \(app.product.rawValue)" : app.shellSection.rawValue)
                        .layoutPriority(1)
                } else {
                    Text(app.shellSection.rawValue).font(KFont.sidebarTitle()).foregroundStyle(K.text)
                        .lineLimit(1).layoutPriority(1)
                }
                Spacer(minLength: 0)
                if app.shellSection == .chats || app.shellSection == .motes {
                    IconButton(icon: "bell", size: 28, iconSize: 16, help: "Notifications") {
                        app.settings.section = .notifications; app.showingSettings = true
                    }
                    IconButton(icon: "magnifyingglass", size: 28, iconSize: 16, help: "Search · ⌘K") { app.openCommandPalette() }
                }
            }.padding(.horizontal, 16).frame(height: K.headerHeight)
            switch app.shellSection {
            case .scheduled: AutomationsSidebar()
            case .skills: SkillsSidebar()
            case .blot:
                VStack(alignment: .leading, spacing: 8) {
                    Text("Blot").font(KFont.body(.medium)).foregroundStyle(K.text)
                    Text("Your main agent. Work for conversations; Code for development with Motes.")
                        .font(KFont.body()).foregroundStyle(K.text2)
                    row("New " + (app.product == .work ? "chat" : "task"), icon: "plus") { app.openNewItem() }
                }.padding(16)
                Spacer()
            case .chats, .motes: conversationsList
            }
        }.background(K.bgSidebar).kBorder(.trailing)
    }
    private var conversationsList: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: K.sidebarRowSpacing) {
                row(app.isMotes ? "New run" : app.product == .work ? "New chat" : "New task",
                    icon: "plus", meta: "⌘N") { app.openNewItem() }
                if !pinned.isEmpty {
                    Button { app.shell.pinsExpanded.toggle() } label: {
                        HStack(spacing: 4) {
                            Text("Pinned").font(KFont.caption()).foregroundStyle(K.text3)
                            KIcon(app.shell.pinsExpanded ? "chevron-down" : "chevron-right", size: 10, color: K.text3)
                        }.padding(.horizontal, 10).padding(.top, 18).padding(.bottom, 6)
                    }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).help("Right-click a conversation to pin it")
                    if app.shell.pinsExpanded {
                        ForEach(pinned) { item in conversationRow(item) }
                    }
                }
                if app.isMotes { workProjects }
                else if app.product == .code { codeProjects }
                else { workChatProjects }
                section("Recents")
                ForEach(recents) { item in conversationRow(item) }
                if !archived.isEmpty {
                    Button { app.shell.archiveExpanded.toggle() } label: {
                        HStack(spacing: 4) {
                            Text("Archived").font(KFont.caption()).foregroundStyle(K.text3)
                            KIcon(app.shell.archiveExpanded ? "chevron-down" : "chevron-right", size: 10, color: K.text3)
                        }.padding(.horizontal, 10).padding(.top, 18).padding(.bottom, 6)
                    }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
                    .accessibilityValue(app.shell.archiveExpanded ? "Expanded" : "Collapsed")
                    if app.shell.archiveExpanded {
                        ForEach(archived) { item in conversationRow(item) }
                    }
                }
            }.padding(.horizontal, 6).padding(.bottom, 16)
        }.scrollIndicators(.never)
    }
    private var allConversations: [SidebarConversation] {
        if app.product == .work {
            return app.workChat.sessions.map {
                SidebarConversation(id: "chat:" + $0.id, title: $0.title, project: $0.projectID ?? "", taskID: $0.id,
                             running: false, kind: .chat)
            }
        }
        if !app.isMotes {
            return app.projects.flatMap { project in project.tasks.map {
                SidebarConversation(id: "code:" + project.id + ":" + $0.id, title: $0.title, project: project.id,
                             taskID: $0.id, running: $0.isRunning, kind: .task)
            }}
        }
        return app.workProjects.flatMap { project in project.runs.map {
            SidebarConversation(id: "motes:" + $0.id, title: $0.title, project: project.id, taskID: $0.id,
                         running: $0.running, kind: .team)
        }}
    }
    private var conversations: [SidebarConversation] { allConversations.filter { !app.shell.archived.contains($0.id) } }
    private var archived: [SidebarConversation] { allConversations.filter { app.shell.archived.contains($0.id) } }
    private var pinned: [SidebarConversation] { conversations.filter { app.shell.pins.contains($0.id) } }
    private var recents: [SidebarConversation] {
        let historyIDs = app.shell.history.entries.reversed().compactMap { destination -> String? in
            if !app.isMotes, app.product == .code, destination.product == .code, case let .task(project, task) = destination.code {
                return "code:" + project + ":" + task
            }
            if app.isMotes, destination.product == .code, destination.code == .motes,
               case let .chat(run) = destination.team { return "motes:" + run }
            if app.product == .work, destination.product == .work,
               case let .chat(id) = destination.work { return "chat:" + id }
            return nil
        }
        var seen: Set<String> = []
        return (historyIDs.compactMap { id in conversations.first { $0.id == id } } + conversations)
            .filter { seen.insert($0.id).inserted }
    }
    @ViewBuilder private var codeProjects: some View {
        ForEach(app.projects) { project in
            row(project.name, icon: "folder", active: app.codeRoute == .home && app.newTask.projectID == project.id) {
                app.toggleProject(project.id)
                if app.codeRoute == .home { app.newTask.projectID = project.id }
            }
            if app.expandedProjectID == project.id {
                ForEach(conversations.filter { $0.project == project.id }.prefix(app.showAllTasks ? 1000 : 3)) { item in
                    conversationRow(item, indented: true)
                }
                if conversations.filter({ $0.project == project.id }).count > 3 {
                    row(app.showAllTasks ? "Show less" : "Show more", indented: true) { app.showAllTasks.toggle() }
                }
            }
        }
    }
    @ViewBuilder private var workProjects: some View {
        ForEach(app.workProjects) { project in
            row(project.name, icon: "folder") { app.newRun.projectID = project.id; app.openNewRun() }
            ForEach(conversations.filter { $0.project == project.id }) { item in conversationRow(item, indented: true) }
        }
    }

    @ViewBuilder private var workChatProjects: some View {
        ForEach(app.workChat.projects) { project in
            row(project.name, icon: "folder", active: app.workRoute == .home && app.workChat.selectedProjectID == project.id) {
                app.openWorkChatProject(project.id)
            }
            if app.workChat.expandedProjectID == project.id {
                ForEach(conversations.filter { $0.project == project.id }) { item in
                    conversationRow(item, indented: true)
                }
            }
        }
    }
    private func conversationRow(_ item: SidebarConversation, indented: Bool = false) -> some View {
        ConversationRow(item: item, selected: isSelected(item), indented: indented) {
            switch item.kind {
            case .task: app.openTask(projectID: item.project, taskID: item.taskID)
            case .team: app.openWorkRun(item.taskID)
            case .chat: app.openWorkChat(item.taskID)
            }
        }
    }
    private func isSelected(_ item: SidebarConversation) -> Bool {
        switch item.kind {
        case .task: app.codeRoute == .task(projectID: item.project, taskID: item.taskID)
        case .team: app.teamRoute == .chat(runID: item.taskID)
        case .chat: app.workRoute == .chat(id: item.taskID)
        }
    }
    private func section(_ title: String) -> some View {
        Text(title).font(KFont.caption()).foregroundStyle(K.text3)
            .padding(.horizontal, 10).padding(.top, 18).padding(.bottom, 6)
    }
    private func row(_ title: String, icon: String? = nil, meta: String? = nil,
                     active: Bool = false, indented: Bool = false, running: Bool = false,
                     action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon { KIcon(icon, size: 15, color: K.text2) }
                Text(title).font(KFont.body()).foregroundStyle(active ? K.text : K.text2)
                    .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                if running { StatusDot(color: K.success, size: 4) }
                if let meta { Text(meta).font(KFont.caption()).foregroundStyle(K.text3) }
            }
            .padding(.leading, indented ? 32 : 10).padding(.trailing, 6).frame(height: K.sidebarRowHeight)
            .kHover(radius: 6, active: active)
        }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
            .accessibilityAddTraits(active ? .isSelected : [])
    }
}
