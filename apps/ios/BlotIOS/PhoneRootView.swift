import SwiftUI
import BlotAPI

struct PhoneRootView: View {
    @State private var connection = PhoneConnection()
    @State private var code = ""
    @State private var bluetooth = false
    @State private var scanner = false
    var body: some View {
        Group {
            if let client = connection.client {
                PhoneWorkspaceView(client: client, disconnect: connection.disconnect)
            } else {
                NavigationStack {
                    Form {
                        Section("Connect to your Mac") {
                            Text(connection.status)
                            Toggle("Use Bluetooth", isOn: $bluetooth)
                            Button("Scan QR code") { scanner = true }
                            TextField("Or paste the connection code", text: $code, axis: .vertical).textInputAutocapitalization(.never).autocorrectionDisabled()
                            Button("Connect") { connection.pair(json: code, bluetooth: bluetooth) }.disabled(code.isEmpty)
                            Button("Reconnect saved Mac") { Task { await connection.restore(bluetooth: bluetooth) } }
                            if let error = connection.error { Text(error).foregroundStyle(.red).textSelection(.enabled) }
                        }
                    }.navigationTitle("Blot")
                }
            }
        }
        .task { await connection.restore() }
        .sheet(isPresented: $scanner) {
            PhoneQRScanner { value in code = value; scanner = false; connection.pair(json: value, bluetooth: bluetooth) }
        }
    }
}

struct PhoneWorkspaceView: View {
    let client: BackendClient
    let disconnect: () -> Void
    @State private var conversations: [BackendEntity<BackendJSON>] = []
    @State private var runs: [BackendEntity<BackendJSON>] = []
    @State private var projects: [BackendEntity<BackendJSON>] = []
    @State private var goal = ""
    @State private var selectedProject: UUID?
    @State private var error: String?
    @State private var title = ""
    @State private var busy = false
    @State private var pendingChat: UUID?
    @State private var pendingTitle: String?
    @State private var pendingRun: UUID?
    @State private var pendingGoal: String?
    @State private var pendingProject: UUID?
    var body: some View {
        TabView {
            NavigationStack {
                List {
                    Section("New conversation") {
                        TextField("Title", text: $title).disabled(busy || pendingChat != nil)
                        Button("Create chat") { Task { await createChat() } }.disabled(title.isEmpty || busy)
                    }
                    ForEach(conversations.filter { $0.data.text("mode") == "WORK" }, id: \.id) { row in
                        NavigationLink(row.data.text("title")) { PhoneChatView(client: client, conversation: row.id) }
                    }
                }.navigationTitle("Chats").refreshable { await refresh() }
            }.tabItem { Label("Chats", systemImage: "bubble.left.and.bubble.right") }
            NavigationStack {
                List {
                    Section("New Code run") {
                        Picker("Project", selection: $selectedProject) { ForEach(projects, id: \.id) { Text($0.data.text("name")).tag(Optional($0.id)) } }
                        TextField("What should Blot do?", text: $goal, axis: .vertical).disabled(busy || pendingRun != nil)
                        Button("Create plan") { Task { await createRun() } }.disabled(goal.isEmpty || selectedProject == nil || busy)
                    }
                    ForEach(runs, id: \.id) { row in
                        NavigationLink { PhoneRunView(client: client, run: row) } label: { VStack(alignment: .leading) { Text(row.data.text("goal")); Text(row.data.text("status")).font(.caption) } }
                    }
                }.navigationTitle("Code").refreshable { await refresh() }
            }.tabItem { Label("Code", systemImage: "terminal") }
            NavigationStack { PhoneApprovalsView(client: client) }.tabItem { Label("Decisions", systemImage: "checkmark.shield") }
            NavigationStack { Form { if let error { Text(error).foregroundStyle(.red) }; Button("Disconnect", role: .destructive, action: disconnect) }.navigationTitle("Connection") }.tabItem { Label("Connection", systemImage: "network") }
        }.task(id: client.baseURL) { await refresh() }
    }
    private func refresh() async {
        do {
            conversations = try await client.records("CONVERSATION", as: BackendJSON.self)
            runs = try await client.records("RUN", as: BackendJSON.self)
            projects = try await client.records("PROJECT", as: BackendJSON.self)
            if selectedProject == nil { selectedProject = projects.first?.id }
        } catch { self.error = error.localizedDescription }
    }
    private func createChat() async {
        guard !busy else { return }
        busy = true; defer { busy = false }
        let id = pendingChat ?? UUID(); pendingChat = id
        let content = pendingTitle ?? title; pendingTitle = content
        do {
            _ = try await client.command("conversation.create", payload: ["title": content], commandId: id)
            pendingChat = nil; pendingTitle = nil; title = ""; await refresh()
        } catch let failure as BackendFailure {
            if failure.isDefiniteRejection { pendingChat = nil; pendingTitle = nil }
            error = failure.localizedDescription
        } catch { self.error = error.localizedDescription }
    }
    private func createRun() async {
        guard !busy, let selectedProject else { return }
        busy = true; defer { busy = false }
        let id = pendingRun ?? UUID()
        if pendingRun == nil { pendingGoal = goal; pendingProject = selectedProject }
        pendingRun = id
        do {
            _ = try await client.command("run.create", payload: ["goal": pendingGoal ?? goal], projectId: pendingProject, commandId: id)
            pendingRun = nil; pendingGoal = nil; pendingProject = nil; goal = ""; await refresh()
        } catch let failure as BackendFailure {
            if failure.isDefiniteRejection { pendingRun = nil; pendingGoal = nil; pendingProject = nil }
            error = failure.localizedDescription
        } catch { self.error = error.localizedDescription }
    }

}

