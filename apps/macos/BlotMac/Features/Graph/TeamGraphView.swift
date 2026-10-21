import BlotAPI
import SwiftUI

struct TeamGraphView: View {
    @Environment(AppState.self) private var app
    private var graph: WorkspaceGraph? {
        guard let records = app.workspace.records, let id = UUID(uuidString: app.selectedRunID),
            records.find("RUN", id: id) != nil
        else { return nil }
        let mode: WorkspaceGraphMode =
            app.graphMode == .dependencies
            ? .dependencies : app.graphMode == .organization ? .organization : .communication
        return WorkspaceGraph(records: records, runID: id, mode: mode)
    }
    var body: some View {
        @Bindable var app = app
        VStack(spacing: 0) {
            HStack {
                Picker("Граф", selection: $app.graphMode) {
                    ForEach(GraphMode.allCases) { Text($0.rawValue).tag($0) }
                }.pickerStyle(.segmented)
                Button("Переписка") { app.openWorkRun(app.selectedRunID) }
            }.padding(16)
            if let graph, !graph.nodes.isEmpty {
                RunGraphCanvas(graph: graph)
                Text(
                    "Связи построены по назначениям, сообщениям, ревью и зависимостям. Нажмите узел или связь, чтобы открыть источник."
                )
                .font(KFont.caption()).foregroundStyle(K.text2).padding(12)
            } else {
                CatalogEmptyView(
                    title: "Граф пока пуст",
                    detail: "Выберите запуск. Задачи и специалисты появятся после принятия плана.")
            }
        }
    }
}

private struct RunGraphCanvas: View {
    @Environment(AppState.self) private var app
    let graph: WorkspaceGraph
    private func point(_ id: String) -> CGPoint {
        let index = graph.nodes.firstIndex { $0.id == id } ?? 0
        return CGPoint(x: 140 + (index % 3) * 280, y: 65 + (index / 3) * 150)
    }
    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            ZStack(alignment: .topLeading) {
                ForEach(graph.edges) { edge in
                    let from = point(edge.from)
                    let to = point(edge.to)
                    GraphConnection(from: from, to: to).stroke(
                        K.text3.opacity(0.65), style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    Button(edge.label) { select(.edge(edge.source)) }
                        .font(KFont.caption()).padding(4).background(K.surface2, in: Capsule())
                        .position(x: (from.x + to.x) / 2, y: (from.y + to.y) / 2)
                        .help(edge.source)
                }
                ForEach(graph.nodes) { node in
                    Button {
                        select(.node(node.id))
                    } label: {
                        HStack(spacing: 10) {
                            FaceAvatar(role: .backendRole(node.role), size: 28)
                            VStack(alignment: .leading, spacing: 6) {
                                Text(node.title).font(KFont.body(.medium)).lineLimit(2)
                                Text(node.status).font(KFont.caption()).foregroundStyle(K.text2).lineLimit(2)
                                Text(node.kind == "TASK" ? "Задача" : "Сессия специалиста").font(
                                    KFont.caption()
                                ).foregroundStyle(K.text3)
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        }.padding(12).frame(width: 245, height: 100).kCard(fill: K.surface2)
                    }.buttonStyle(.plain).position(point(node.id))
                }
            }.frame(width: 850, height: CGFloat(max(1, (graph.nodes.count + 2) / 3) * 150))
        }
    }
    private func select(_ selection: GraphSelection) {
        app.graphSelection = selection
        app.inspectorVisible = true
        app.shell.rightVisible = true
    }
}

private struct GraphConnection: Shape {
    let from: CGPoint
    let to: CGPoint
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: from)
        let middle = (from.y + to.y) / 2
        path.addCurve(to: to, control1: CGPoint(x: from.x, y: middle), control2: CGPoint(x: to.x, y: middle))
        let direction = atan2(to.y - from.y, to.x - from.x)
        path.move(to: CGPoint(x: to.x - cos(direction - 0.5) * 10, y: to.y - sin(direction - 0.5) * 10))
        path.addLine(to: to)
        path.addLine(to: CGPoint(x: to.x - cos(direction + 0.5) * 10, y: to.y - sin(direction + 0.5) * 10))
        return path
    }
}
