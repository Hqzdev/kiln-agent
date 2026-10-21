import SwiftUI
import BlotAPI

struct PhoneRunView: View {
    let client: BackendClient
    @State var run: BackendEntity<BackendJSON>
    @State private var sessions: [BackendEntity<BackendJSON>] = []
    @State private var tasks: [BackendEntity<BackendJSON>] = []
    @State private var error: String?
    @State private var plan: BackendEntity<BackendJSON>?
    var body: some View {
        List {
            Section("Run") {
                Text(run.data.text("goal")); Text(run.data.text("status"))
                if run.data.text("status") == "AWAITING_PLAN", plan != nil { Button("Accept plan") { action("run.plan.approve") } }
                else if run.data.text("status") == "READY_FOR_ACCEPTANCE" { Button("Accept result") { action("run.accept") } }
                else if ["PAUSED", "INTERRUPTED", "WAITING"].contains(run.data.text("status")) { Button("Resume") { action("run.resume") } }
                else if run.data.text("status") == "RUNNING" { Button("Pause") { action("run.pause") } }
                if !["COMPLETED", "CANCELLED", "FAILED"].contains(run.data.text("status")) { Button("Stop", role: .destructive) { action("run.stop") } }
            }
            if let plan {
                Section("Requirements") {
                    ForEach(Array(plan.data.items("requirements").enumerated()), id: \.offset) { item in Text(item.element.text("content")) }
                }
                Section("Plan") {
                    ForEach(Array(plan.data.items("steps").enumerated()), id: \.offset) { item in
                        VStack(alignment: .leading) {
                            Text(item.element.text("title")).font(.headline)
                            ForEach(item.element.strings("criteria"), id: \.self) { Text($0).font(.caption) }
                        }
                    }
                }
            }
            Section("Tasks") { ForEach(tasks, id: \.id) { row in VStack(alignment: .leading) { Text(row.data.text("title")); Text(row.data.text("status")).font(.caption) } } }
            Section("Team and Motes") { ForEach(sessions, id: \.id) { row in VStack(alignment: .leading) { Text(row.data.text("role")); Text(row.data.text("status") + " " + row.data.text("waitingReason")).font(.caption) } } }
            if let error { Text(error).foregroundStyle(.red) }
        }.navigationTitle("Code run")
        .task(id: client.baseURL) { while !Task.isCancelled { await refresh(); try? await Task.sleep(for: .seconds(1)) } }
    }
    private func refresh() async {
        do {
            run = try await client.get("v2/records/RUN/\(run.id.uuidString)", as: BackendEntity<BackendJSON>.self)
            tasks = try await client.records("TASK", parentId: run.id, as: BackendJSON.self)
            sessions = try await client.records("AGENT_SESSION", parentId: run.id, as: BackendJSON.self)
            if let planID = UUID(uuidString: run.data.text("planId")) {
                plan = try await client.get("v2/records/PLAN/\(planID.uuidString)", as: BackendEntity<BackendJSON>.self)
            } else { plan = nil }
        } catch { self.error = error.localizedDescription }
    }
    private func action(_ name: String) { Task { do { _ = try await client.command(name, payload: ["id": run.id.uuidString], expectedVersion: run.version); await refresh() } catch { self.error = error.localizedDescription; await refresh() } } }
}

struct PhoneApprovalsView: View {
    let client: BackendClient
    @State private var actions: [BackendEntity<BackendJSON>] = []
    @State private var questions: [BackendEntity<BackendJSON>] = []
    @State private var customAnswers: [UUID: String] = [:]
    @State private var error: String?
    @State private var plan: BackendEntity<BackendJSON>?
    nonisolated private struct Grant: Encodable, Sendable { let id: UUID; let seconds = 300; let uses = 1 }
    nonisolated private struct Answer: Encodable, Sendable { let id: UUID; let answer: String }
    var body: some View {
        List {
            ForEach(actions.filter { $0.data.text("status") == "PREPARED" }, id: \.id) { row in
                VStack(alignment: .leading, spacing: 8) {
                    Text(row.data.text("capability")).font(.headline)
                    if case .object(let value) = row.data, case .object(let arguments) = value["arguments"] {
                        if case .string(let path) = arguments["path"] { Text(path).font(.body.monospaced()).textSelection(.enabled) }
                        if case .string(let content) = arguments["content"] { Text(content).font(.caption.monospaced()).lineLimit(12).textSelection(.enabled) }
                        if case .string(let program) = arguments["program"] {
                            let args: [String] = { if case .array(let list) = arguments["arguments"] { return list.compactMap { if case .string(let arg) = $0 { return arg }; return nil } }; return [] }()
                            Text(([program] + args).joined(separator: " ")).font(.body.monospaced()).textSelection(.enabled)
                        }
                        if case .string(let remote) = arguments["remote"] { Text("Remote: " + remote) }
                        if case .array(let urls) = arguments["pushUrls"] {
                            ForEach(Array(urls.enumerated()), id: \.offset) { entry in if case .string(let url) = entry.element { Text(url).font(.caption.monospaced()).textSelection(.enabled) } }
                        }
                        if case .string(let sha) = arguments["expectedCommit"] { Text("Commit: " + sha).font(.caption.monospaced()).textSelection(.enabled) }
                        if case .string(let hash) = arguments["snapshotHash"] { Text("Changes SHA-256: " + hash).font(.caption.monospaced()).textSelection(.enabled) }
                        if case .string(let value) = arguments["artifactId"], let id = UUID(uuidString: value) {
                            NavigationLink("Inspect accepted changes") { PhoneArtifactView(client: client, id: id) }
                        }
                        if case .string(let refspec) = arguments["refspec"] { Text(refspec).font(.caption.monospaced()) }
                        if case .string(let message) = arguments["message"] { Text(message) }
                    }
                    HStack { Button("Allow once") { grant(row) }; Button("Deny", role: .destructive) { deny(row) } }
                }
            }
            ForEach(questions.filter { $0.data.flag("open") }, id: \.id) { row in
                VStack(alignment: .leading) {
                    Text(row.data.text("question"))
                    ForEach(row.data.strings("options"), id: \.self) { option in Button(option) { answer(row, option) } }
                    TextField("Your answer", text: Binding(get: { customAnswers[row.id] ?? "" }, set: { customAnswers[row.id] = $0 }))
                    Button("Send answer") { answer(row, customAnswers[row.id] ?? "") }.disabled((customAnswers[row.id] ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            if let error { Text(error).foregroundStyle(.red) }
        }.navigationTitle("Your decisions")
        .task(id: client.baseURL) { while !Task.isCancelled { await refresh(); try? await Task.sleep(for: .seconds(1)) } }
    }
    private func refresh() async { do { actions = try await client.records("PREPARED_ACTION", as: BackendJSON.self); questions = try await client.records("CHECKPOINT", as: BackendJSON.self) } catch { self.error = error.localizedDescription } }
    private func deny(_ action: BackendEntity<BackendJSON>) { Task { do { _ = try await client.command("permission.deny", payload: ["id": action.id.uuidString], expectedVersion: action.version); await refresh() } catch { self.error = error.localizedDescription } } }
    private func grant(_ action: BackendEntity<BackendJSON>) { Task { do { _ = try await client.command("permission.grant", payload: Grant(id: action.id), expectedVersion: action.version); await refresh() } catch { self.error = error.localizedDescription } } }
    private func answer(_ question: BackendEntity<BackendJSON>, _ value: String) { Task { do { _ = try await client.command("user.answer", payload: Answer(id: question.id, answer: value), expectedVersion: question.version); await refresh() } catch { self.error = error.localizedDescription } } }
}
