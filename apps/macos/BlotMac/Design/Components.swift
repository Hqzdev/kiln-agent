//
//  Components.swift
//  BlotMac
//
//  Reusable building blocks from agent.pen → «Components — Atoms / Rows / Blocks / Shell».
//

import SwiftUI

// MARK: - Icon

/// Hugeicons icons from agent.pen, bundled as vector template PDFs in Icons.xcassets
/// (`hugeicons-<name>`). Call sites may pass either a Hugeicons name (kebab-case key) («square-pen») or the
/// SF Symbol name used earlier («square.and.pencil»); unknown names fall back to SF Symbols.
enum HugeIcons {
    static let fromSFSymbol: [String: String] = [
        "terminal": "terminal",
        "plus": "plus",
        "minus": "minus",
        "pencil": "pencil",
        "doc.text": "file-text",
        "sidebar.left": "panel-left",
        "sidebar.right": "panel-right",
        "magnifyingglass": "search",
        "bubble.left": "message-square",
        "bubble.left.and.bubble.right": "messages-square",
        "xmark": "x",
        "square.and.pencil": "square-pen",
        "puzzlepiece.extension": "puzzle",
        "line.3.horizontal.decrease": "list-filter",
        "envelope": "mail",
        "clock": "clock",
        "checkmark.circle": "circle-check",
        "checkmark": "check",
        "arrow.triangle.pull": "git-pull-request",
        "arrow.triangle.branch": "workflow",
        "point.3.connected.trianglepath.dotted": "network",
        "waveform.path.ecg": "activity",
        "stop": "square",
        "sparkle": "sparkle",
        "smallcircle.filled.circle": "circle-dot",
        "circle": "circle",
        "play": "play",
        "pause": "pause",
        "person": "user",
        "person.2": "users",
        "person.badge.plus": "user-plus",
        "mic": "mic",
        "lock": "lock",
        "list.bullet": "list",
        "gearshape": "settings",
        "gauge.with.dots.needle.33percent": "gauge",
        "flag": "flag",
        "eye": "eye",
        "exclamationmark.shield": "shield-alert",
        "checkmark.shield": "shield-check",
        "exclamationmark.circle": "circle-alert",
        "ellipsis": "ellipsis",
        "cursorarrow.click": "mouse-pointer-click",
        "chevron.down": "chevron-down",
        "chevron.up": "chevron-up",
        "bell": "bell",
        "arrow.up.left.and.arrow.down.right": "maximize-2",
        "arrow.up": "arrow-up",
        "arrow.right": "arrow-right",
        "folder": "folder",
        "folder.fill": "folder-open",
        "square.grid.2x2": "grid-2x2",
        "server": "server",
        "desktopcomputer": "laptop",
        "display": "monitor",
        "rectangle.portrait.and.arrow.right": "log-out",
        "bolt": "zap",
        "arrow.counterclockwise": "rotate-ccw",
        "chevron.left": "chevron-left",
        "chevron.right": "chevron-right",
        "trash": "trash-2",
        "keyboard": "keyboard",
        "cpu": "cpu",
        "globe": "globe",
        "shield": "shield",
        "key": "key",
        "sun.max": "sun",
        "chart.bar": "chart-bar",
        "slider.horizontal.3": "sliders-horizontal",
        "chevron.left.forwardslash.chevron.right": "code",
        "arrow.up.right.square": "square-arrow-out-up-right",
    ]

    /// Kebab-case names bundled as `hugeicons-<name>` that have no SF Symbol alias above.
    private static let extra: Set<String> = ["git-branch", "laptop", "monitor", "log-out", "zap", "rotate-ccw",
                                             "chevron-left", "chevron-right", "trash-2", "sun", "chart-bar",
                                             "sliders-horizontal", "code", "square-arrow-out-up-right"]

    private static let bundled = Set(fromSFSymbol.values).union(extra)

    /// Asset name for a Hugeicons or SF Symbol name, or nil if there is no Hugeicons equivalent.
    static func asset(for name: String) -> String? {
        if bundled.contains(name) { return "hugeicons-" + name }
        return fromSFSymbol[name].map { "hugeicons-" + $0 }
    }
}

/// Hugeicons glyph that takes the surrounding foreground style (for buttons and chips).
struct HugeIconImage: View {
    let name: String
    var size: CGFloat = 16

    init(_ name: String, size: CGFloat = 16) {
        self.name = name
        self.size = size
    }

    var body: some View {
        if let asset = HugeIcons.asset(for: name) {
            Image(asset)
                .renderingMode(.template)
                .resizable()
                .interpolation(.high)
                .aspectRatio(contentMode: .fit)
                .frame(width: size, height: size)
        } else {
            Image(systemName: name)
                .font(.system(size: size * 0.82))
                .frame(width: size, height: size)
        }
    }
}

struct KIcon: View {
    let name: String
    var size: CGFloat = 16
    var color: Color = K.text2
    var weight: Font.Weight = .regular

    init(_ name: String, size: CGFloat = 16, color: Color = K.text2, weight: Font.Weight = .regular) {
        self.name = name
        self.size = size
        self.color = color
        self.weight = weight
    }

    var body: some View {
        HugeIconImage(name, size: size)
            .fontWeight(weight)
            .foregroundStyle(color)
    }
}

// MARK: - Hover

struct HoverBackground: ViewModifier {
    @Environment(\.isEnabled) private var enabled
    var radius: CGFloat = K.rMd
    var active: Bool = false
    var activeFill: Color = K.selected
    @State private var hovering = false

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(active ? activeFill : (hovering && enabled ? K.hover : Color.clear))
            )
            .contentShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .onHover { hovering = $0 }
    }
}

extension View {
    func kHover(radius: CGFloat = K.rMd, active: Bool = false, activeFill: Color = K.selected) -> some View {
        modifier(HoverBackground(radius: radius, active: active, activeFill: activeFill))
    }

    /// Card with a 1 px border, used for groups, terminal blocks and lists.
    func kCard(radius: CGFloat = K.rLg, fill: Color = K.surface, stroke: Color = K.border) -> some View {
        self
            .background(RoundedRectangle(cornerRadius: radius, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: radius, style: .continuous).strokeBorder(stroke, lineWidth: 1))
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// 1 px separator on one edge.
    func kBorder(_ edge: Edge, color: Color = K.border) -> some View {
        overlay(alignment: edge.alignment) {
            Rectangle()
                .fill(color)
                .frame(
                    width: edge == .leading || edge == .trailing ? 1 : nil,
                    height: edge == .top || edge == .bottom ? 1 : nil
                )
        }
    }
}

private extension Edge {
    var alignment: Alignment {
        switch self {
        case .top: .top
        case .bottom: .bottom
        case .leading: .leading
        case .trailing: .trailing
        }
    }
}

// MARK: - Button

enum KButtonKind {
    case standard   // surface-2 + border
    case primary    // inverse fill (white in dark theme)
    case ghost      // no fill until hover
    case danger
}

struct KButtonStyle: ButtonStyle {
    var kind: KButtonKind = .standard
    var height: CGFloat = K.controlHeight

    func makeBody(configuration: Configuration) -> some View {
        KButtonBody(configuration: configuration, kind: kind, height: height)
    }
}

private struct KButtonBody: View {
    @Environment(\.isEnabled) private var enabled
    let configuration: ButtonStyleConfiguration
    let kind: KButtonKind
    let height: CGFloat
    @State private var hovering = false

    var body: some View {
        configuration.label
            .font(KFont.body(.medium))
            .foregroundStyle(foreground)
            .padding(.horizontal, KSpace.lg)
            .frame(height: height)
            .background(RoundedRectangle(cornerRadius: K.rMd, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: K.rMd, style: .continuous).strokeBorder(stroke, lineWidth: 1))
            .opacity(!enabled ? 0.45 : configuration.isPressed ? 0.8 : 1)
            .contentShape(Rectangle())
            .onHover { hovering = enabled && $0 }
    }

    private var foreground: Color {
        switch kind {
        case .primary: K.onInverse
        case .danger: K.danger
        default: K.text
        }
    }

    private var fill: Color {
        switch kind {
        case .standard: hovering ? K.selected : K.surface2
        case .primary: K.inverse.opacity(hovering ? 0.9 : 1)
        case .ghost: hovering ? K.hover : .clear
        case .danger: hovering ? K.dangerBg : K.surface2
        }
    }

    private var stroke: Color {
        switch kind {
        case .primary: K.inverse
        case .ghost: .clear
        default: K.border
        }
    }
}

/// Button with optional leading SF Symbol, as in the «Button» component.
struct KButton: View {
    let title: String
    var icon: String?
    var kind: KButtonKind = .standard
    var height: CGFloat = K.controlHeight
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                if let icon {
                    HugeIconImage(icon, size: 14)
                }
                Text(title)
                    .lineLimit(1)
            }
        }
        .buttonStyle(KButtonStyle(kind: kind, height: height))
        .kFocusRing()
    }
}

struct IconButton: View {
    let icon: String
    var size: CGFloat = 32
    var iconSize: CGFloat = 16
    var color: Color = K.text2
    var help: String?
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            KIcon(icon, size: iconSize, color: color)
                .frame(width: size, height: size)
                .kHover(radius: K.rSm)
        }
        .buttonStyle(KIconButtonStyle())
        .kFocusRing(radius: K.rSm)
        .accessibilityLabel(help ?? icon)
        .help(help ?? "")
    }
}

/// Filled circular send button from the composer.
struct SendButton: View {
    var enabled = true
    var size: CGFloat = 36
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HugeIconImage("arrow-up", size: 16)
                .foregroundStyle(K.onInverse)
                .frame(width: size, height: size)
                .background(Circle().fill(enabled ? K.inverse : K.text3))
        }
        .buttonStyle(KIconButtonStyle())
        .disabled(!enabled)
        .kFocusRing(radius: size / 2)
        .accessibilityLabel("Send message")
        .help(enabled ? "Send message" : "Enter a message to send")
    }
}

// MARK: - Chip / Badge / Dot

struct Chip: View {
    var icon: String?
    let label: String
    var chevron = true
    var color: Color = K.text2
    var bordered = false
    var mono = false

    var body: some View {
        HStack(spacing: 6) {
            if let icon { KIcon(icon, size: 14, color: color) }
            Text(label)
                .font(mono ? KFont.mono(12) : KFont.body())
                .foregroundStyle(color)
                .lineLimit(1)
            if chevron {
                KIcon("chevron-down", size: 12, color: K.text3)
            }
        }
        .padding(.horizontal, 8)
        .frame(height: 28)
        .overlay {
            if bordered {
                RoundedRectangle(cornerRadius: K.rMd, style: .continuous).strokeBorder(K.border, lineWidth: 1)
            }
        }
        .kHover(radius: K.rMd)
    }
}

/// Chip that opens an app-styled menu (`KMenu`).
struct MenuChip: View {
    var icon: String?
    let label: String
    var bordered = false
    var color: Color = K.text2
    let items: () -> [KMenuItem]

    var body: some View {
        KMenu(items: items) {
            Chip(icon: icon, label: label, color: color, bordered: bordered)
        }
        .fixedSize()
    }
}

struct Badge: View {
    let text: String
    var fg: Color = K.text2
    var bg: Color = K.surface2

    var body: some View {
        Text(text)
            .font(KFont.mono(11, .medium))
            .foregroundStyle(fg)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(RoundedRectangle(cornerRadius: 4, style: .continuous).fill(bg))
            .lineLimit(1)
            .fixedSize()
    }
}

struct StatusDot: View {
    var color: Color
    var size: CGFloat = 6

    var body: some View {
        Circle().fill(color).frame(width: size, height: size)
    }
}

// MARK: - Toggle

/// «Toggle» component: 30 × 18, inverse track when on.
struct KToggle: View {
    @Binding var isOn: Bool

    var body: some View {
        Button {
            withAnimation(.snappy(duration: 0.18)) { isOn.toggle() }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(isOn ? K.inverse : K.selected)
                    .overlay(Capsule().strokeBorder(isOn ? Color.clear : K.border, lineWidth: 1))
                Circle()
                    .fill(isOn ? K.onInverse : K.text3)
                    .frame(width: 14, height: 14)
                    .padding(2)
            }
            .frame(width: 30, height: 18)
            .contentShape(Capsule())
        }
        .buttonStyle(KIconButtonStyle())
        .accessibilityAddTraits(.isToggle)
        .kFocusRing(radius: K.rSm)
        .accessibilityValue(isOn ? "On" : "Off")
    }
}

// MARK: - Segmented control

struct KSegmented<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    var label: (Option) -> String
    var icon: ((Option) -> String?)?
    var height: CGFloat = 30
    var fontSize: CGFloat = 14

    var body: some View {
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                let active = option == selection
                Button {
                    withAnimation(.snappy(duration: 0.2)) { selection = option }
                } label: {
                    HStack(spacing: 6) {
                        if let name = icon?(option) {
                            KIcon(name, size: 14, color: active ? K.text : K.text2)
                        }
                        Text(label(option))
                            .font(KFont.ui(fontSize, active ? .medium : .regular))
                            .foregroundStyle(active ? K.text : K.text2)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: height - 6)
                    .background(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(active ? K.selected : Color.clear)
                    )
                    .contentShape(Rectangle())
                }
                .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
                .accessibilityAddTraits(active ? .isSelected : [])
            }
        }
        .padding(3)
        .frame(height: height)
        .overlay(RoundedRectangle(cornerRadius: K.rMd, style: .continuous).strokeBorder(K.border, lineWidth: 1))
    }
}

// MARK: - Sidebar rows

struct SidebarItem: View {
    var icon: String?
    let label: String
    var meta: String?
    var metaColor: Color = K.text3
    var dot: Color?
    var active = false
    var labelColor: Color = K.text
    var leadingIndent = false
    var action: () -> Void = {}

    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon {
                    KIcon(icon, size: 16, color: active ? K.text : K.text2)
                } else if leadingIndent {
                    Color.clear.frame(width: 16, height: 16)
                }
                Text(label)
                    .font(KFont.body())
                    .foregroundStyle(labelColor)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if let dot {
                    StatusDot(color: dot, size: 7)
                } else if let meta {
                    Text(meta).font(KFont.body()).foregroundStyle(metaColor)
                }
            }
            .padding(.horizontal, 10)
            .frame(height: K.sidebarRowHeight)
            .kHover(radius: K.rMd, active: active)
        }
        .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
        .accessibilityAddTraits(active ? .isSelected : [])
    }
}

struct SectionLabel: View {
    let title: String
    var actionIcon: String? = "plus"
    var action: () -> Void = {}

    var body: some View {
        HStack {
            Text(title)
                .font(KFont.body(.medium))
                .foregroundStyle(K.text3)
                .frame(maxWidth: .infinity, alignment: .leading)
            if let actionIcon {
                Button(action: action) { KIcon(actionIcon, size: 14, color: K.text3) }
                    .buttonStyle(KIconButtonStyle()).kFocusRing(radius: K.rSm)
            }
        }
        .padding(EdgeInsets(top: 16, leading: 10, bottom: 6, trailing: 10))
    }
}

// MARK: - Avatars and brand

/// Role avatar from agent.pen («Face 34 / …»): the role's Blot in a circle, no motion.
struct FaceAvatar: View {
    let role: AgentRole
    var size: CGFloat = 32

    var body: some View {
        BlotDrawing(role: role, framing: .avatar)
            .frame(width: size, height: size)
            .accessibilityLabel(role.title)
    }
}

struct InitialsAvatar: View {
    let initials: String
    var size: CGFloat = 24
    var fill: Color = K.surface2
    var foreground: Color = K.text2
    var bordered = true
    var weight: KFont.Weight = .semibold

    var body: some View {
        Text(initials)
            .font(KFont.ui(size * 0.42, weight))
            .foregroundStyle(foreground)
            .frame(width: size, height: size)
            .background(Circle().fill(fill))
            .overlay(Circle().strokeBorder(bordered ? K.border : .clear, lineWidth: 1))
    }
}

// MARK: - Misc

struct HDivider: View {
    var color: Color = K.border
    var body: some View { Rectangle().fill(color).frame(height: 1) }
}

struct VDivider: View {
    var color: Color = K.border
    var body: some View { Rectangle().fill(color).frame(width: 1) }
}

/// Text with `seconds` formatted like «1m 12s».
func formatDuration(_ seconds: Int) -> String {
    let m = seconds / 60
    let s = seconds % 60
    return m > 0 ? "\(m)m \(s)s" : "\(s)s"
}
