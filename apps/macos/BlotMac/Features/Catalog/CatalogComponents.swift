import SwiftUI

struct CatalogDetail<Content: View>: View {
    @ViewBuilder var content: () -> Content
    var body: some View {
        PageContent(content: content)
    }
}

struct CatalogSearch: View {
    let placeholder: String
    @Binding var text: String
    var body: some View {
        HStack(spacing: 8) {
            KIcon("search", size: 14, color: K.text3)
            TextField(placeholder, text: $text).textFieldStyle(.plain).font(KFont.body())
            if !text.isEmpty { IconButton(icon: "x", size: 18, iconSize: 12) { text = "" } }
        }
        .padding(.horizontal, 10).frame(height: 32)
        .kCard(radius: 6, fill: K.surface2)
        .padding(.horizontal, 8).padding(.top, 10).padding(.bottom, 6)
    }
}

struct CatalogItemRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let selected: Bool
    let select: () -> Void
    @Binding var enabled: Bool
    var body: some View {
        HStack(spacing: 10) {
            Button(action: select) {
                HStack(alignment: .top, spacing: 10) {
                    KIcon(icon, size: 16).padding(.top, 2)
                    VStack(alignment: .leading, spacing: 5) {
                        Text(title).font(KFont.body(.medium)).foregroundStyle(K.text).lineLimit(2)
                        Text(subtitle).font(KFont.caption()).foregroundStyle(K.text3).lineLimit(2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .contentShape(Rectangle())
            }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
            KToggle(isOn: $enabled).accessibilityLabel("Enable \(title)")
        }
        .padding(10).frame(minHeight: 62)
        .kHover(radius: K.rMd, active: selected)
    }
}

struct CatalogEmptyView: View {
    let title: String
    let detail: String
    var body: some View {
        VStack(spacing: 10) {
            KIcon("search", size: 24, color: K.text3)
            Text(title).font(KFont.ui(15, .medium)).foregroundStyle(K.text)
            Text(detail).font(KFont.body()).foregroundStyle(K.text3).multilineTextAlignment(.center)
        }.padding(32).frame(maxWidth: .infinity)
    }
}
