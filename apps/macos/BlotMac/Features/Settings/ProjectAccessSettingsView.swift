import SwiftUI
import AppKit
import BlotAPI

struct ProjectAccessSettingsView: View {
    @State private var projects: [BackendEntity<ProjectValue>] = []
    @State private var busy = false
    @State private var error: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Git projects").font(KFont.pageTitle()).foregroundStyle(K.text)
            Text("Choose a repository on this Mac. Agents work in separate workspaces; commit and push require separate approvals.")
                .font(KFont.body()).foregroundStyle(K.text2)
            KButton(title: "Add repository…", icon: "folder", kind: .primary) { chooseFolder() }.disabled(busy)
            if busy { ProgressView() }
            if let error { Text(error).foregroundStyle(K.warning).textSelection(.enabled) }
            ForEach(projects, id: \.id) { project in
                VStack(alignment: .leading, spacing: 6) {
                    Text(project.data.name).font(KFont.body(.medium))
                    Text(project.data.repositoryPath).font(KFont.caption()).foregroundStyle(K.text2).textSelection(.enabled)
                    HStack {
                        Text(project.data.archived ? "Archived" : "Connected").font(KFont.caption()).foregroundStyle(K.text3)
                        Spacer()
                        Button("Choose folder again…") { chooseFolder(existing: project) }.disabled(busy)
                    }
                }.padding(14).kCard(fill: K.surface)
            }
            if projects.isEmpty && !busy { Text("No repositories connected.").foregroundStyle(K.text3) }
        }.task { await load() }
    }

    private func chooseFolder(existing: BackendEntity<ProjectValue>? = nil) {
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true; panel.canChooseFiles = false; panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK, let url = panel.url else { return }
        do {
            let path = try ProjectBookmarks.shared.remember(url)
            guard existing == nil || existing?.data.repositoryPath == path else {
                throw NSError(domain: "BlotProject", code: 1, userInfo: [NSLocalizedDescriptionKey: "Choose the same repository folder."])
            }
            busy = true; error = nil
            Task {
                defer { busy = false }
                do {
                    if existing == nil {
                        _ = try await BackendRuntime.shared.client.command("project.create", payload: ["name": url.lastPathComponent, "repositoryPath": path])
                    } else {
                        if let existing { _ = try await BackendRuntime.shared.client.command("project.access", payload: ["id": existing.id.uuidString]) }
                    }
                    await load()
                } catch { self.error = error.localizedDescription }
            }
        } catch { self.error = error.localizedDescription }
    }

    private func load() async {
        do { projects = try await BackendRuntime.shared.client.records("PROJECT", as: ProjectValue.self) }
        catch { self.error = error.localizedDescription }
    }

    nonisolated private struct ProjectValue: Codable, Sendable {
        let name: String
        let repositoryPath: String
        let archived: Bool
    }
}
