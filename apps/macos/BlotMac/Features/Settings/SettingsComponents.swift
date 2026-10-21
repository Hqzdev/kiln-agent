import SwiftUI

struct SettingsGroup<Content: View>: View {
    let title: String
    @ViewBuilder var content: () -> Content
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(KFont.body(.medium)).foregroundStyle(K.text)
            VStack(spacing: 0, content: content).kCard(radius: K.rMd)
        }
    }
}

struct SettingsRow<Control: View>: View {
    let title: String
    var detail: String = ""
    @ViewBuilder var control: () -> Control
    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: KSpace.xl) {
                description.frame(minWidth: 180, maxWidth: .infinity, alignment: .leading)
                control().fixedSize(horizontal: true, vertical: false)
            }
            VStack(alignment: .leading, spacing: KSpace.md) {
                description
                control()
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(KSpace.lg)
        .frame(minHeight: 64)
    }

    private var description: some View {
        VStack(alignment: .leading, spacing: KSpace.xs) {
            Text(title).font(KFont.body(.medium)).foregroundStyle(K.text)
            if !detail.isEmpty {
                Text(detail).font(KFont.body()).foregroundStyle(K.text2)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct SettingsChoice: View {
    @Binding var value: String
    let options: [String]
    var body: some View {
        KMenu(alignment: .trailing, items: {
            KMenuItem.choices(options, selected: value) { value = $0 }
        }) { Chip(label: value, bordered: true) }
    }
}

struct SettingsToggleRow: View {
    let title: String
    var detail: String = ""
    @Binding var value: Bool
    var body: some View {
        SettingsRow(title: title, detail: detail) {
            KToggle(isOn: $value).accessibilityLabel(title)
        }
    }
}

struct SettingsTextField: View {
    let label: String
    @Binding var text: String
    var required = false
    var error: String?
    @FocusState private var focused: Bool
    @State private var edited = false

    private var validation: String? {
        if let error { return error }
        return required && edited && !focused && text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            ? "\(label) is required." : nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: KSpace.sm) {
            Text(label).font(KFont.caption(.medium)).foregroundStyle(K.text2)
            TextField("", text: $text)
                .textFieldStyle(.plain).font(KFont.body()).foregroundStyle(K.text)
                .focused($focused)
                .padding(KSpace.md)
                .kCard(radius: K.rSm, fill: K.bg,
                       stroke: validation != nil ? K.danger : focused ? K.focus : K.borderStrong)
                .accessibilityLabel(label)
                .accessibilityHint(validation ?? (required ? "Required" : ""))
            if let validation { InlineFeedback(text: validation, tone: .error) }
        }
        .onChange(of: focused) { _, value in if value { edited = true } }
    }
}
