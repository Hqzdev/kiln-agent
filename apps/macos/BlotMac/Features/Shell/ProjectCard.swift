import SwiftUI
import UniformTypeIdentifiers

struct ProjectCard: View {
    @Environment(AppState.self) private var app
    @State private var importing = false
    @State private var importProjectID = ""
    @State private var importError: String?
    private var added: Int { app.shellChangedFiles.reduce(0) { $0 + $1.added } }
    private var removed: Int { app.shellChangedFiles.reduce(0) { $0 + $1.removed } }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(app.shellProjectName).font(KFont.body()).foregroundStyle(K.text3).lineLimit(1)
                Spacer()
                KMenu(alignment: .trailing, items: {[
                    .button("Hide project panel") { app.shell.rightVisible = false },
                    .button("View sources") { app.shell.expandedSources.toggle() }
                ]}) { KIcon("ellipsis", size: 16).frame(width: 26, height: 26) }
                    .accessibilityLabel("Project actions")
                IconButton(icon: "play", size: 26, iconSize: 18, help: app.isMotes ? "Open run details" : "Preview changes") { app.showShellReview() }
                    .disabled(!app.shellHasConversation)
            }
            Button { app.showShellReview() } label: {
                HStack(spacing: 8) {
                    KIcon("doc.badge.plus", size: 18)
                    Text(app.isMotes ? "Motes" : "Changes").font(KFont.body()).foregroundStyle(K.text)
                    Spacer()
                    if !app.isMotes {
                        Text("+" + added.formatted(.number))
                            .foregroundStyle(K.success).accessibilityLabel("\(added) lines added")
                        Text("−" + removed.formatted(.number))
                            .foregroundStyle(K.danger).accessibilityLabel("\(removed) lines removed")
                    } else {
                        Text("\(app.teamRoute == .newRun ? 0 : app.team.count) Motes").foregroundStyle(K.text3)
                    }
                }.font(KFont.body()).monospacedDigit().frame(height: 32).contentShape(Rectangle())
            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).disabled(!app.shellHasConversation)
            HDivider()
            HStack {
                Text("Sources").font(KFont.body()).foregroundStyle(K.text3)
                Spacer()
                IconButton(icon: "plus", size: 26, iconSize: 15, help: "Add local source") {
                    importProjectID = app.shellProjectID; importing = true
                }
            }
            if app.shellSources.isEmpty {
                Text("Add a file for this project").font(KFont.caption()).foregroundStyle(K.text3).padding(.vertical, 4)
            }
            ForEach(app.shell.expandedSources ? app.shellSources : Array(app.shellSources.prefix(3))) { source in
                ProjectSourceRow(source: source)
            }
            if let importError { Text(importError).font(KFont.caption()).foregroundStyle(K.danger) }
            Button { app.shell.expandedSources.toggle() } label: {
                HStack(spacing: 8) {
                    KIcon("point.3.connected.trianglepath.dotted", size: 18, color: K.text3)
                    Text(app.shell.expandedSources ? "Show less" : "View all").font(KFont.body()).foregroundStyle(K.text3)
                }.frame(height: 32)
            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).disabled(app.shellSources.count <= 3)
        }.padding(20).kCard(radius: 20, fill: K.surface2)
        .fileImporter(isPresented: $importing, allowedContentTypes: [.item], allowsMultipleSelection: true) { result in
            switch result {
            case .success(let urls): app.shell.addSources(urls, projectID: importProjectID); importError = nil
            case .failure(let error): importError = error.localizedDescription
            }
        }
    }
}
