import SwiftUI

struct DiffView: View {
    let file: ReviewFile
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Text(file.path).font(KFont.mono(11, .medium)).foregroundStyle(K.text).lineLimit(1)
                Spacer()
                Text("+\(file.added)").foregroundStyle(K.success)
                Text("−\(file.removed)").foregroundStyle(K.danger)
            }.font(KFont.mono(11)).padding(12).kBorder(.bottom)
            ScrollView([.horizontal, .vertical]) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(file.lines) { line in
                        HStack(alignment: .top, spacing: 8) {
                            Text(line.oldNumber.map(String.init) ?? "").foregroundStyle(K.text3).frame(width: 25, alignment: .trailing)
                            Text(line.newNumber.map(String.init) ?? "").foregroundStyle(K.text3).frame(width: 25, alignment: .trailing)
                            Text(symbol(line.tone)).foregroundStyle(color(line.tone)).frame(width: 12)
                            Text(line.text.isEmpty ? " " : line.text)
                                .foregroundStyle(line.tone == .header ? K.text3 : K.text)
                                .textSelection(.enabled)
                                .fixedSize(horizontal: true, vertical: false)
                            Spacer(minLength: 12)
                        }
                        .font(KFont.mono(11)).padding(.horizontal, 8).padding(.vertical, 5)
                        .frame(maxWidth: .infinity, alignment: .leading).background(background(line.tone))
                    }
                }.frame(minWidth: 500, alignment: .leading)
            }
            Text("Demo diff excerpt · file totals shown above")
                .font(KFont.caption()).foregroundStyle(K.text3).padding(10)
        }.kCard(radius: K.rMd, fill: K.bg)
    }
    private func symbol(_ tone: DiffTone) -> String {
        switch tone { case .added: "+"; case .removed: "−"; default: " " }
    }
    private func color(_ tone: DiffTone) -> Color {
        switch tone { case .added: K.success; case .removed: K.danger; default: K.text3 }
    }
    private func background(_ tone: DiffTone) -> Color {
        switch tone { case .added: K.diffAddBg; case .removed: K.diffDelBg; case .header: K.surface2; default: .clear }
    }
}
