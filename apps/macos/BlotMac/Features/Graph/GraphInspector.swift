import BlotAPI
import SwiftUI

struct GraphInspector: View {
    @Environment(AppState.self) private var app
    private var evidence: WorkspaceEvidence? {
        let source: String
        switch app.graphSelection {
        case .node(let id), .edge(let id): source = id
        case nil: return nil
        }
        let parts = source.split(separator: "|")
        guard parts.count == 2, let id = UUID(uuidString: String(parts[1])) else { return nil }
        return WorkspaceEvidence(kind: String(parts[0]), id: id)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Источник связи").font(KFont.body(.semibold))
                    Spacer()
                    Button("Закрыть") { app.inspectorVisible = false }
                }
                if let evidence, let row = app.workspace.find(evidence.kind, evidence.id) {
                    Text(evidence.kind).font(KFont.caption()).foregroundStyle(K.text2)
                    Text(row.id.uuidString).font(KFont.mono(10)).textSelection(.enabled)
                    Text("Версия \(row.version)").font(KFont.caption())
                    Text(row.data.formatted).font(KFont.mono(11)).textSelection(.enabled)
                    if let id = row.data.uuid("artifactId") { ArtifactLink(id: id) }
                } else {
                    Text("Выберите узел или связь на графе.").foregroundStyle(K.text2)
                }
            }.padding(18)
        }
    }
}

struct TeamLivePanel: View {
    @Environment(AppState.self) private var app
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Состояние запуска").font(KFont.body(.semibold))
                if let run = app.workspace.find("RUN", app.selectedRunID) {
                    Text(run.data.text("goal"))
                    Badge(text: run.data.text("status"))
                    Text(run.data.text("waitingReason")).font(KFont.caption()).foregroundStyle(K.text2)
                    Button("Открыть граф") { app.openGraph() }
                    ForEach(app.workspace.rows("AGENT_SESSION", parentID: run.id), id: \.id) { session in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(session.data.text("role")).font(KFont.body(.medium))
                            Text(session.data.text("status") + " " + session.data.text("waitingReason")).font(
                                KFont.caption()
                            ).foregroundStyle(K.text2)
                        }
                    }
                }
            }.padding(18)
        }
    }
}
