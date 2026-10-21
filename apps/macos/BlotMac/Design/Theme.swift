//
//  Theme.swift
//  BlotMac
//
//  Design tokens based on agent.pen → «Blot — Design System».
//  Secondary text and semantic colors include contrast adjustments.
//  Every color has a dark and a light value and follows the window appearance.
//

import AppKit
import CoreText
import SwiftUI

// MARK: - Colors

nonisolated private func nsColor(_ rgba: UInt32) -> NSColor {
    NSColor(
        srgbRed: CGFloat((rgba >> 24) & 0xFF) / 255,
        green: CGFloat((rgba >> 16) & 0xFF) / 255,
        blue: CGFloat((rgba >> 8) & 0xFF) / 255,
        alpha: CGFloat(rgba & 0xFF) / 255
    )
}

/// Builds a color that resolves per appearance. Values are 0xRRGGBBAA.
nonisolated private func dynamicColor(dark: UInt32, light: UInt32) -> Color {
    let darkColor = nsColor(dark)
    let lightColor = nsColor(light)
    return Color(nsColor: NSColor(name: nil) { appearance in
        appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? darkColor : lightColor
    })
}

extension Color {
    /// 0xRRGGBB, opaque.
    nonisolated init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

/// Blot design tokens. Names match the variables in agent.pen.
enum K {
    static let bg = dynamicColor(dark: 0x0F0F11FF, light: 0xFFFFFFFF)
    static let bgSidebar = dynamicColor(dark: 0x131315FF, light: 0xF7F7F7FF)
    static let bgChrome = dynamicColor(dark: 0x1B1B1CFF, light: 0xEFEFEFFF)
    static let composer = dynamicColor(dark: 0x2A2A2CFF, light: 0xF3F3F3FF)
    static let composerContext = dynamicColor(dark: 0x1E1E20FF, light: 0xEAEAEAFF)
    static let surface = dynamicColor(dark: 0x1C1C1CFF, light: 0xFFFFFFFF)
    static let surface2 = dynamicColor(dark: 0x232323FF, light: 0xF3F3F3FF)
    static let card = dynamicColor(dark: 0x1A1A1AFF, light: 0xF7F7F9FF)
    static let hover = dynamicColor(dark: 0xFFFFFF0D, light: 0x0000000A)
    static let selected = dynamicColor(dark: 0xFFFFFF14, light: 0x0000000F)
    static let border = dynamicColor(dark: 0xFFFFFF14, light: 0x00000014)
    static let borderStrong = dynamicColor(dark: 0xFFFFFF26, light: 0x00000024)
    static let text = dynamicColor(dark: 0xECECECFF, light: 0x0D0D0DFF)
    static let text2 = dynamicColor(dark: 0xA1A1A1FF, light: 0x5D5D5DFF)
    static let text3 = dynamicColor(dark: 0x999999FF, light: 0x666666FF)
    static let focus = Color(nsColor: .keyboardFocusIndicatorColor)
    static let inverse = dynamicColor(dark: 0xECECECFF, light: 0x0D0D0DFF)
    static let onInverse = dynamicColor(dark: 0x121212FF, light: 0xFFFFFFFF)
    static let success = dynamicColor(dark: 0x5FBF8FFF, light: 0x187344FF)
    static let danger = dynamicColor(dark: 0xE36A62FF, light: 0xC8372DFF)
    static let warning = dynamicColor(dark: 0xD9A84AFF, light: 0x89600AFF)
    static let successBg = dynamicColor(dark: 0x5FBF8F1A, light: 0x1F8A5714)
    static let dangerBg = dynamicColor(dark: 0xE36A621A, light: 0xC8372D12)
    static let ember = dynamicColor(dark: 0xE36A62FF, light: 0xE5484DFF)
    static let profileAvatar = Color(hex: 0xEA4A37)
    static let diffAddBg = dynamicColor(dark: 0x5FBF8F14, light: 0x1F8A5712)
    static let diffDelBg = dynamicColor(dark: 0xE36A6214, light: 0xC8372D10)
    static let scrim = Color.black.opacity(0.45)
    static let graphGrid = dynamicColor(dark: 0xFFFFFF08, light: 0x00000008)
    static let edgeGray = Color(hex: 0x6E6E6E)

    // Radii
    static let rSm: CGFloat = 6
    static let rMd: CGFloat = 8
    static let rLg: CGFloat = 12
    static let rXl: CGFloat = 16

    // Layout
    static let windowWidth: CGFloat = 1312
    static let windowHeight: CGFloat = 751
    static let sidebarWidth: CGFloat = 240
    static let headerHeight: CGFloat = 52
    static let contentWidth: CGFloat = 736
    static let profileContentWidth: CGFloat = 880
    static let railWidth: CGFloat = 52
    static let shellToolbarHeight: CGFloat = 44
    static let sidebarRowHeight: CGFloat = 29
    static let projectSidebarMin: CGFloat = sidebarWidth
    static let projectSidebarMax: CGFloat = 320
    static let projectPanelWidth: CGFloat = 280
    static let sidebarRowSpacing: CGFloat = 2
    static let railButtonSize: CGFloat = 36
    static let controlHeight: CGFloat = 36
    static let shellInset: CGFloat = 4
    static let pageInset: CGFloat = KSpace.xl
    static let pageTopInset: CGFloat = KSpace.section
    static let composerHeight: CGFloat = 98
    static let composerContextHeight: CGFloat = 50
    static let composerContextOverlap: CGFloat = 12
    static let composerBottomInset: CGFloat = 20 - shellInset
    static let composerPetClearance: CGFloat = 36
    static let composerRadius: CGFloat = 20
    static let primaryBlotSize: CGFloat = 76
    static let composerBlotSize: CGFloat = 56
}

enum KSpace {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let section: CGFloat = 32
}

private struct BlotReduceMotionKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var blotReduceMotion: Bool {
        get { self[BlotReduceMotionKey.self] }
        set { self[BlotReduceMotionKey.self] = newValue }
    }
}

enum KMotion {
    static let sidebar = Animation.smooth(duration: 0.26)
    static let loading = Animation.easeInOut(duration: 0.18)
}

// MARK: - Fonts

/// Inter for UI, JetBrains Mono for code. Both are bundled in Resources/Fonts and
/// registered at launch. If registration fails SwiftUI falls back to the system font.
enum KFont {
    enum Weight {
        case regular, medium, semibold, bold
    }

    static func ui(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .regular: name = "Inter-Regular"
        case .medium: name = "Inter-Medium"
        case .semibold: name = "Inter-SemiBold"
        case .bold: name = "Inter-Bold"
        }
        return .custom(name, fixedSize: size)
    }

    static func mono(_ size: CGFloat, _ weight: Weight = .regular) -> Font {
        let name: String
        switch weight {
        case .regular: name = "JetBrainsMono-Regular"
        case .medium: name = "JetBrainsMono-Medium"
        case .semibold, .bold: name = "JetBrainsMono-SemiBold"
        }
        return .custom(name, fixedSize: size)
    }

    static func body(_ weight: Weight = .regular) -> Font { ui(14, weight) }
    static func caption(_ weight: Weight = .regular) -> Font { ui(12, weight) }
    static func sidebarTitle() -> Font { ui(20, .semibold) }
    static func pageTitle(_ weight: Weight = .semibold) -> Font { ui(28, weight) }
}

enum FontRegistrar {
    /// Registers every .ttf found inside the app bundle for this process.
    static func registerBundledFonts() {
        guard let root = Bundle.main.resourceURL,
              let enumerator = FileManager.default.enumerator(at: root, includingPropertiesForKeys: nil)
        else { return }
        for case let url as URL in enumerator where url.pathExtension.lowercased() == "ttf" {
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        }
    }
}

// MARK: - Theme preference

enum ThemePreference: String, CaseIterable, Identifiable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}
