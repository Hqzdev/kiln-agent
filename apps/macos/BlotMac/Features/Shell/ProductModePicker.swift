import SwiftUI

struct ProductModePicker: View {
    @Environment(AppState.self) private var app
    let title: String
    @State private var anchor = KMenuAnchor()
    @State private var presented = false

    var body: some View {
        Button(action: toggle) {
            HStack(spacing: 7) {
                Text(title).font(KFont.ui(18, .semibold)).foregroundStyle(K.text).lineLimit(1)
                KIcon("chevron-down", size: 12, color: K.text2)
            }.padding(.trailing, 6).frame(height: 34).kHover(radius: 12, active: presented)
        }
        .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
        .accessibilityLabel("Switch mode")
        .accessibilityValue(app.product.rawValue)
        .background(KMenuAnchorView(anchor: anchor))
        .onDisappear { if presented { KMenuController.shared.close() } }
        .onChange(of: app.shellDestination) { _, _ in if presented { KMenuController.shared.close() } }
    }

    private func toggle() {
        guard !presented, let view = anchor.view, let window = view.window else {
            KMenuController.shared.close()
            return
        }
        let rect = window.convertToScreen(view.convert(view.bounds, to: nil))
        presented = true
        KMenuController.shared.showDropdown(ProductModeMenuCard().environment(app), below: rect, in: window,
                                           title: "Switch mode") { presented = false }
    }
}

struct ProductModeMenuCard: View {
    @Environment(AppState.self) private var app
    var body: some View {
        VStack(spacing: 0) {
            ForEach([Product.work, .code], id: \.self) { product in
                Button {
                    KMenuController.shared.close()
                    app.switchProduct(product)
                } label: {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Blot \(product.rawValue)").font(KFont.body()).foregroundStyle(K.text)
                            Text(product.subtitle).font(KFont.caption()).foregroundStyle(K.text2)
                        }.frame(maxWidth: .infinity, alignment: .leading)
                        if app.product == product { KIcon("check", size: 16, color: K.text2) }
                    }
                    .padding(.horizontal, 12).frame(height: 54).contentShape(Rectangle())
                    .kHover(radius: 10)
                }.buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm).accessibilityAddTraits(app.product == product ? .isSelected : [])
            }
        }
        .padding(8).frame(width: 240)
        .background(K.surface2, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).strokeBorder(K.borderStrong, lineWidth: 1))
        .shadow(color: .black.opacity(0.25), radius: 18, y: 8)
    }
}
