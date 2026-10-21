import SwiftUI

struct WorkspaceToolsView: View {
    let tool: WorkspaceTool
    var body: some View {
        switch tool {
        case .projects: WorkspaceProjectsView(reviewing: false)
        case .images: ImageLibraryView()
        case .sites: SitesLibraryView()
        case .maps: WorkspaceMapsView()
        case .gpts: AssistantsLibraryView()
        case .codeReview: WorkspaceProjectsView(reviewing: true)
        case .security: WorkspaceSecurityView()
        }
    }
}

struct WorkspacePageHeader<Action: View>: View {
    let title: String
    let detail: String
    @ViewBuilder var action: () -> Action
    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text(title).font(KFont.pageTitle()).foregroundStyle(K.text)
                Text(detail).font(KFont.body()).foregroundStyle(K.text2)
            }
            Spacer()
            action()
        }.padding(.bottom, 24)
    }
}

struct WorkspaceEmptyView: View {
    let icon: String
    let title: String
    let detail: String
    var body: some View {
        VStack(spacing: 12) {
            KIcon(icon, size: 32, color: K.text3)
            Text(title).font(KFont.ui(18, .medium)).foregroundStyle(K.text)
            Text(detail).font(KFont.body()).foregroundStyle(K.text2).multilineTextAlignment(.center)
        }.frame(maxWidth: .infinity).padding(.vertical, 64)
    }
}

private struct WorkspaceProjectsView: View {
    @Environment(AppState.self) private var app
    let reviewing: Bool
    var body: some View {
        PageContent {
            VStack(alignment: .leading, spacing: 16) {
                WorkspacePageHeader(title: reviewing ? "Code Review" : "Projects",
                                    detail: reviewing ? "Review changes from your project conversations." : "Your projects and conversations.") {
                    EmptyView()
                }
                ForEach(app.projects) { project in
                    let tasks = project.tasks.filter { !reviewing || !$0.changedFiles.isEmpty }
                    if !reviewing || !tasks.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 8) {
                                KIcon("folder", size: 16, color: K.text2)
                                Text(project.name).font(KFont.ui(16, .medium)).foregroundStyle(K.text)
                                Spacer()
                                if !reviewing {
                                    KButton(title: "New task", icon: "plus", kind: .ghost) {
                                        app.newTask.projectID = project.id
                                        app.openHome()
                                    }
                                }
                            }.padding(.bottom, 8)
                            ForEach(tasks) { task in
                                Button {
                                    app.openTask(projectID: project.id, taskID: task.id)
                                    if reviewing { app.openReview(projectID: project.id, task: task) }
                                } label: {
                                    HStack {
                                        Text(task.title).font(KFont.body()).foregroundStyle(K.text)
                                        Spacer()
                                        if reviewing {
                                            Text("\(task.changedFiles.count) files").font(KFont.caption()).foregroundStyle(K.text3)
                                        }
                                        KIcon("chevron-right", size: 12, color: K.text3)
                                    }.padding(10).contentShape(Rectangle()).kHover(radius: K.rMd)
                                }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
                            }
                        }.padding(.bottom, 16)
                    }
                }
                if app.projects.isEmpty || (reviewing && app.projects.allSatisfy { $0.tasks.allSatisfy { $0.changedFiles.isEmpty } }) {
                    WorkspaceEmptyView(icon: reviewing ? "git-pull-request" : "folder",
                                       title: reviewing ? "No changes to review" : "No projects",
                                       detail: reviewing ? "Changes from project tasks will appear here." : "Projects you add to your workspace will appear here.")
                }
            }
        }
    }
}

private extension TaskItem {
    var changedFiles: [ChangedFile] {
        thread.flatMap { block in
            if case let .changes(files) = block { return files }
            return []
        }
    }
}

private struct WorkspaceSecurityView: View {
    @Environment(AppState.self) private var app
    var body: some View {
        PageContent {
            VStack(alignment: .leading, spacing: 24) {
                WorkspacePageHeader(title: "Security", detail: "Workspace permissions and command approvals.") { EmptyView() }
                PermissionsSettingsView(settings: app.settings)
            }
        }
    }
}
