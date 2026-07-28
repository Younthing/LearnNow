import SwiftUI

enum LearnNowTheme: String, CaseIterable, Codable, Identifiable, Sendable {
    case emerald
    case sand
    case ink
    case graphite
    case clay

    var id: Self { self }

    var displayName: String {
        switch self {
        case .emerald: "清水翡翠"
        case .sand: "暖沙米白"
        case .ink: "墨青素笺"
        case .graphite: "石墨素灰"
        case .clay: "柔陶暖灰"
        }
    }
}

/// Process-wide current theme for `LearnNowPalette` / `LearnNowSemanticRole` statics.
/// Synced from `LearnNowFlowState.selectedTheme` at the app root.
enum LearnNowThemeStore {
    static var current: LearnNowTheme = .emerald
}

struct LearnNowDynamicColor: Equatable, Sendable {
    let light: UInt
    let dark: UInt
    var lightOpacity: Double = 1
    var darkOpacity: Double = 1

    var color: Color {
        Color.dynamic(
            light: light,
            dark: dark,
            lightOpacity: lightOpacity,
            darkOpacity: darkOpacity
        )
    }
}

struct LearnNowRoleTokens: Equatable, Sendable {
    let foreground: LearnNowDynamicColor
    let softFill: LearnNowDynamicColor
    let onFill: LearnNowDynamicColor
}

struct LearnNowThemeTokens: Equatable, Sendable {
    let base: LearnNowDynamicColor
    let surfaceOpaque: LearnNowDynamicColor
    let canvas: LearnNowDynamicColor
    let textPrimary: LearnNowDynamicColor
    let textSecondary: LearnNowDynamicColor
    let textMuted: LearnNowDynamicColor
    let shadowDark: LearnNowDynamicColor
    let shadowLight: LearnNowDynamicColor

    let brand: LearnNowRoleTokens
    let warning: LearnNowRoleTokens
    let danger: LearnNowRoleTokens
    let brandGradientStart: LearnNowDynamicColor
    let brandGradientEnd: LearnNowDynamicColor

    let accentBlue: LearnNowDynamicColor
    let accentPink: LearnNowDynamicColor
    let accentMint: LearnNowDynamicColor
    let accentPurple: LearnNowDynamicColor
    let accentAmber: LearnNowDynamicColor

    func accent(for accent: LearnNowAccent) -> LearnNowDynamicColor {
        switch accent {
        case .blue: accentBlue
        case .pink: accentPink
        case .mint: accentMint
        case .purple: accentPurple
        case .amber: accentAmber
        }
    }
}

enum LearnNowThemeCatalog {
    static func tokens(for theme: LearnNowTheme) -> LearnNowThemeTokens {
        switch theme {
        case .emerald: emerald
        case .sand: sand
        case .ink: ink
        case .graphite: graphite
        case .clay: clay
        }
    }

    /// Shared grey-gold / grey-rose semantics — do not chase brand hue.
    private static let sharedWarning = LearnNowRoleTokens(
        foreground: .init(light: 0x8C6410, dark: 0xE0C06A),
        softFill: .init(light: 0xF6EEDA, dark: 0x2B2416),
        onFill: .init(light: 0xFFFFFF, dark: 0x211A08)
    )

    private static let sharedDanger = LearnNowRoleTokens(
        foreground: .init(light: 0xB4434E, dark: 0xEC9AA2),
        softFill: .init(light: 0xF8E7E9, dark: 0x2F1D20),
        onFill: .init(light: 0xFFFFFF, dark: 0x230F12)
    )

    private static let emerald = LearnNowThemeTokens(
        base: .init(light: 0xFFFFFF, dark: 0x181C1A, lightOpacity: 0.58, darkOpacity: 0.65),
        surfaceOpaque: .init(light: 0xF9FBFA, dark: 0x181C1A),
        canvas: .init(light: 0xF4F6F5, dark: 0x0B0D0C),
        textPrimary: .init(light: 0x1E2522, dark: 0xF3F6F4, lightOpacity: 1.0, darkOpacity: 0.95),
        textSecondary: .init(light: 0x4A5551, dark: 0xC3CCC8),
        textMuted: .init(light: 0x7E8985, dark: 0x8B9691),
        shadowDark: .init(light: 0xA9AEAC, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5),
        shadowLight: .init(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1),
        brand: LearnNowRoleTokens(
            foreground: .init(light: 0x0B7A5C, dark: 0x5FD3A6),
            softFill: .init(light: 0xDEF2E9, dark: 0x163529),
            onFill: .init(light: 0xFFFFFF, dark: 0x07110D)
        ),
        warning: sharedWarning,
        danger: sharedDanger,
        brandGradientStart: .init(light: 0x0B7A5C, dark: 0x47BE94),
        brandGradientEnd: .init(light: 0x0D9A6B, dark: 0x5FD3A6),
        accentBlue: .init(light: 0x4A7089, dark: 0x8FB8CE),
        accentPink: .init(light: 0xA4525C, dark: 0xDA9AA3),
        accentMint: .init(light: 0x0F7258, dark: 0x66CDA8),
        accentPurple: .init(light: 0x337873, dark: 0x7CC7C0),
        accentAmber: .init(light: 0x8C6410, dark: 0xD9BC6E)
    )

    private static let sand = LearnNowThemeTokens(
        base: .init(light: 0xFFFBF5, dark: 0x1C1915, lightOpacity: 0.58, darkOpacity: 0.65),
        surfaceOpaque: .init(light: 0xFAF6F0, dark: 0x1C1915),
        canvas: .init(light: 0xF7F3EC, dark: 0x120F0C),
        textPrimary: .init(light: 0x2A241C, dark: 0xF6F1E8, lightOpacity: 1.0, darkOpacity: 0.95),
        textSecondary: .init(light: 0x5A5146, dark: 0xC9C0B4),
        textMuted: .init(light: 0x8A8176, dark: 0x948B80),
        shadowDark: .init(light: 0xB0A89C, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5),
        shadowLight: .init(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1),
        brand: LearnNowRoleTokens(
            foreground: .init(light: 0x7A4E22, dark: 0xD4A66A),
            softFill: .init(light: 0xF0E4D4, dark: 0x2A2218),
            onFill: .init(light: 0xFFFFFF, dark: 0x1A1208)
        ),
        warning: sharedWarning,
        danger: sharedDanger,
        brandGradientStart: .init(light: 0x7A4E22, dark: 0xC09050),
        brandGradientEnd: .init(light: 0x96622E, dark: 0xD4A66A),
        accentBlue: .init(light: 0x5A6E7A, dark: 0xA0B4C0),
        accentPink: .init(light: 0x9A5A55, dark: 0xD4A0A0),
        accentMint: .init(light: 0x5F6B3A, dark: 0xB0BC8A),
        accentPurple: .init(light: 0x6B5E5A, dark: 0xC0B0A8),
        accentAmber: .init(light: 0x8C6410, dark: 0xD9BC6E)
    )

    private static let ink = LearnNowThemeTokens(
        base: .init(light: 0xF8FBFC, dark: 0x151A1E, lightOpacity: 0.58, darkOpacity: 0.65),
        surfaceOpaque: .init(light: 0xF5F8FA, dark: 0x151A1E),
        canvas: .init(light: 0xF1F4F6, dark: 0x0A0C0E),
        textPrimary: .init(light: 0x1A2228, dark: 0xEEF3F6, lightOpacity: 1.0, darkOpacity: 0.95),
        textSecondary: .init(light: 0x46525C, dark: 0xB8C4CC),
        textMuted: .init(light: 0x7A8790, dark: 0x849099),
        shadowDark: .init(light: 0xA4AEB4, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5),
        shadowLight: .init(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1),
        brand: LearnNowRoleTokens(
            foreground: .init(light: 0x2F6170, dark: 0x7AB0C0),
            softFill: .init(light: 0xD8E8ED, dark: 0x152028),
            onFill: .init(light: 0xFFFFFF, dark: 0x081014)
        ),
        warning: sharedWarning,
        danger: sharedDanger,
        brandGradientStart: .init(light: 0x2F6170, dark: 0x5A98A8),
        brandGradientEnd: .init(light: 0x3A7A8C, dark: 0x7AB0C0),
        accentBlue: .init(light: 0x3D5F78, dark: 0x8FB0C8),
        accentPink: .init(light: 0x8A5A68, dark: 0xC8A0B0),
        accentMint: .init(light: 0x2F6B62, dark: 0x70C0B4),
        accentPurple: .init(light: 0x4A6578, dark: 0x90A8C0),
        accentAmber: .init(light: 0x7A6820, dark: 0xD0BC70)
    )

    private static let graphite = LearnNowThemeTokens(
        base: .init(light: 0xFFFFFF, dark: 0x18181A, lightOpacity: 0.58, darkOpacity: 0.65),
        surfaceOpaque: .init(light: 0xF7F7F8, dark: 0x18181A),
        canvas: .init(light: 0xF3F3F4, dark: 0x0C0C0D),
        textPrimary: .init(light: 0x1C1E22, dark: 0xF0F0F2, lightOpacity: 1.0, darkOpacity: 0.95),
        textSecondary: .init(light: 0x4A4E55, dark: 0xC0C2C8),
        textMuted: .init(light: 0x7E828A, dark: 0x8A8C94),
        shadowDark: .init(light: 0xA8AAB0, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5),
        shadowLight: .init(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1),
        brand: LearnNowRoleTokens(
            foreground: .init(light: 0x3E444A, dark: 0xA8ADB3),
            softFill: .init(light: 0xE2E4E7, dark: 0x222428),
            onFill: .init(light: 0xFFFFFF, dark: 0x0C0E10)
        ),
        warning: sharedWarning,
        danger: sharedDanger,
        brandGradientStart: .init(light: 0x3E444A, dark: 0x8A9098),
        brandGradientEnd: .init(light: 0x50565E, dark: 0xA8ADB3),
        accentBlue: .init(light: 0x4A5E6E, dark: 0x9AAEC0),
        accentPink: .init(light: 0x8A5A60, dark: 0xC8A0A8),
        accentMint: .init(light: 0x4A6A5A, dark: 0x9AB8A8),
        accentPurple: .init(light: 0x5A5E6A, dark: 0xA8ACB8),
        accentAmber: .init(light: 0x7A6828, dark: 0xD0BC78)
    )

    private static let clay = LearnNowThemeTokens(
        base: .init(light: 0xFFF8F7, dark: 0x1C1615, lightOpacity: 0.58, darkOpacity: 0.65),
        surfaceOpaque: .init(light: 0xFAF4F3, dark: 0x1C1615),
        canvas: .init(light: 0xF6F1F0, dark: 0x100C0C),
        textPrimary: .init(light: 0x2A201E, dark: 0xF6EEEB, lightOpacity: 1.0, darkOpacity: 0.95),
        textSecondary: .init(light: 0x5A4A47, dark: 0xC8B8B4),
        textMuted: .init(light: 0x8A7A76, dark: 0x948884),
        shadowDark: .init(light: 0xB0A4A0, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5),
        shadowLight: .init(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1),
        brand: LearnNowRoleTokens(
            foreground: .init(light: 0x8E4E42, dark: 0xD4A090),
            softFill: .init(light: 0xF0E0DC, dark: 0x2A1C1A),
            onFill: .init(light: 0xFFFFFF, dark: 0x180E0C)
        ),
        warning: sharedWarning,
        danger: sharedDanger,
        brandGradientStart: .init(light: 0x8E4E42, dark: 0xC08070),
        brandGradientEnd: .init(light: 0xA05A4C, dark: 0xD4A090),
        accentBlue: .init(light: 0x5A6870, dark: 0xA0B0B8),
        accentPink: .init(light: 0x9A5558, dark: 0xD4A0A4),
        accentMint: .init(light: 0x5A6A48, dark: 0xB0BC98),
        accentPurple: .init(light: 0x6A5A5E, dark: 0xC0A8B0),
        accentAmber: .init(light: 0x8C6410, dark: 0xD9BC6E)
    )
}
