import SwiftUI

struct CommandPaletteView: View {
    @Environment(AppState.self) private var app
    @State private var query = ""
    @State private var selectedID: String?
    @State private var preview: PaletteEntry?
    @FocusState private var searchFocused: Bool
    private var results: [PaletteEntry] { CommandPaletteIndex.entries(projects: app.projects, query: query) }

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                K.scrim.contentShape(Rectangle()).onTapGesture { dismiss() }
                VStack(spacing: 0) {
                    header
                    if let preview {
                        filePreview(preview).frame(height: min(420, geometry.size.height - 200))
                    } else {
                        resultList.frame(maxHeight: min(420, geometry.size.height - 200))
                    }
                    HStack(spacing: 18) {
                        Text("↑↓ navigate")
                        Text("↵ open")
                        Spacer()
                        Text("esc close")
                    }
                    .font(KFont.mono(10)).foregroundStyle(K.text3)
                    .padding(.horizontal, 16).frame(height: 36).kBorder(.top)
                }
                .frame(width: min(640, geometry.size.width - 48))
                .kCard(radius: 16, fill: K.surface, stroke: K.borderStrong)
                .shadow(color: .black.opacity(0.4), radius: 40, y: 24)
                .padding(.top, max(64, min(150, geometry.size.height * 0.17)))
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear { selectedID = results.first?.id; searchFocused = true }
        .onChange(of: query) { _, _ in selectedID = results.first?.id; preview = nil }
        .onExitCommand { dismiss() }
    }
    private var header: some View {
        HStack(spacing: 10) {
            KIcon("magnifyingglass", size: 18)
            TextField("Search tasks, files and actions", text: $query)
                .textFieldStyle(.plain).font(KFont.ui(15)).foregroundStyle(K.text)
                .focused($searchFocused).onSubmit { activateSelected() }
                .onKeyPress(.downArrow) { move(1); return .handled }
                .onKeyPress(.upArrow) { move(-1); return .handled }
            Button(action: dismiss) {
                Text("esc").font(KFont.mono(11)).foregroundStyle(K.text3)
                    .padding(.horizontal, 6).padding(.vertical, 3).kCard(radius: 4)
            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).accessibilityLabel("Close command palette")
        }.padding(.horizontal, 16).frame(height: 52).kBorder(.bottom)
    }
    private var resultList: some View {
        ScrollViewReader { reader in
            ScrollView {
                VStack(spacing: 1) {
                    ForEach(["Tasks", "Files", "Actions"], id: \.self) { group in
                        let entries = results.filter { $0.group == group }
                        if !entries.isEmpty {
                            SectionLabel(title: group, actionIcon: nil)
                            ForEach(entries) { entry in
                                Button { selectedID = entry.id; activate(entry) } label: {
                                    HStack(spacing: 10) {
                                        KIcon(entry.icon, size: 15)
                                        Text(entry.title).font(KFont.body()).foregroundStyle(K.text).lineLimit(1)
                                        Spacer(minLength: 12)
                                        Text(entry.detail).font(KFont.caption()).foregroundStyle(K.text3).lineLimit(1)
                                    }.padding(.horizontal, 10).frame(height: 36)
                                        .kHover(radius: K.rMd, active: selectedID == entry.id)
                                }
                                .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).id(entry.id)
                                .accessibilityAddTraits(selectedID == entry.id ? .isSelected : [])
                            }
                        }
                    }
                    if !query.isEmpty && !results.contains(where: { $0.group != "Actions" }) {
                        Text("No matching tasks or files").font(KFont.body()).foregroundStyle(K.text3).padding(12)
                    }
                }.padding(.horizontal, 8).padding(.bottom, 8)
            }
            .onChange(of: selectedID) { _, id in if let id { reader.scrollTo(id, anchor: .center) } }
        }
    }
    private func filePreview(_ entry: PaletteEntry) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Button { preview = nil; searchFocused = true } label: {
                HStack(spacing: 4) {
                    KIcon("chevron-left", size: 14, color: K.text2)
                    Text("Back to results").font(KFont.body()).foregroundStyle(K.text2)
                }
            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
            if case let .file(_, _, path) = entry.action {
                Text(path).font(KFont.mono(12)).textSelection(.enabled)
                Text("Фактические изменения доступны в артефактах запуска.").font(KFont.body()).foregroundStyle(K.text2)
                if case let .file(projectID, taskID, _) = entry.action {
                    Button("Открыть результаты запуска") { app.openTask(projectID: projectID, taskID: taskID); app.reviewVisible = true; dismiss() }
                }

            }
        }.padding(16)
    }
    private func move(_ offset: Int) {
        guard preview == nil, !results.isEmpty else { return }
        let index = results.firstIndex { $0.id == selectedID } ?? 0
        selectedID = results[(index + offset + results.count) % results.count].id
    }
    private func activateSelected() {
        guard preview == nil, let entry = results.first(where: { $0.id == selectedID }) else { return }
        activate(entry)
    }
    private func activate(_ entry: PaletteEntry) {
        switch entry.action {
        case .file: preview = entry
        case let .task(projectID, taskID): app.openTask(projectID: projectID, taskID: taskID)
        case let .newTask(prompt): app.openHome(draft: prompt)
        case .settings: dismiss(); app.showingSettings = true
        case .automations: navigate(.automations)
        case .skills: navigate(.skills)
        case .graph: dismiss(); app.showingSettings = false; app.openGraph()
        }
    }
    private func navigate(_ route: CodeRoute) {
        dismiss(); app.showingSettings = false; app.product = .code; app.codeRoute = route
    }
    private func dismiss() { app.paletteVisible = false }
}
