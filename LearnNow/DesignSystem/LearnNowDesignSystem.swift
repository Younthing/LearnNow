import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

private struct LearnNowAnimationsEnabledKey: EnvironmentKey {
    static let defaultValue = true
}

private struct LearnNowReduceMotionOverrideKey: EnvironmentKey {
    static let defaultValue: Bool? = nil
}

extension EnvironmentValues {
    var learnNowAnimationsEnabled: Bool {
        get { self[LearnNowAnimationsEnabledKey.self] }
        set { self[LearnNowAnimationsEnabledKey.self] = newValue }
    }

    var learnNowReduceMotionOverride: Bool? {
        get { self[LearnNowReduceMotionOverrideKey.self] }
        set { self[LearnNowReduceMotionOverrideKey.self] = newValue }
    }
}

enum LearnNowPalette {
    static let base = Color.dynamic(light: 0xFFFFFF, dark: 0x181C1A, lightOpacity: 0.58, darkOpacity: 0.65)
    /// 无障碍降级用的不透明表面（Increase Contrast / Reduce Transparency）。
    static let surfaceOpaque = Color.dynamic(light: 0xF9FBFA, dark: 0x181C1A)
    static let canvas = Color.dynamic(light: 0xF4F6F5, dark: 0x0B0D0C)
    static let textPrimary = Color.dynamic(light: 0x1E2522, dark: 0xF3F6F4, lightOpacity: 1.0, darkOpacity: 0.95)
    static let textSecondary = Color.dynamic(light: 0x4A5551, dark: 0xC3CCC8)
    static let textMuted = Color.dynamic(light: 0x7E8985, dark: 0x8B9691)
    static let shadowDark = Color.dynamic(light: 0xA9AEAC, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5)
    static let shadowLight = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1)

    static func color(for accent: LearnNowAccent) -> Color {
        switch accent {
        case .blue:
            return Color.dynamic(light: 0x4A7089, dark: 0x8FB8CE)
        case .pink:
            return Color.dynamic(light: 0xA4525C, dark: 0xDA9AA3)
        case .mint:
            return Color.dynamic(light: 0x0F7258, dark: 0x66CDA8)
        case .purple:
            return Color.dynamic(light: 0x337873, dark: 0x7CC7C0)
        case .amber:
            return Color.dynamic(light: 0x8C6410, dark: 0xD9BC6E)
        }
    }

    static func gradient(for accent: LearnNowAccent) -> LinearGradient {
        let color = color(for: accent)
        return LinearGradient(
            colors: [color.opacity(0.85), color],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

/// UI 自身决定的语义颜色（CTA、进度、状态），不进入内容协议。
/// 内容驱动的颜色仍走 `LearnNowAccent` → `LearnNowPalette.color(for:)`。
enum LearnNowSemanticRole {
    case brand
    case warning
    case danger
    case neutral

    var foreground: Color {
        switch self {
        case .brand:
            return Color.dynamic(light: 0x0B7A5C, dark: 0x5FD3A6)
        case .warning:
            return Color.dynamic(light: 0x8C6410, dark: 0xE0C06A)
        case .danger:
            return Color.dynamic(light: 0xB4434E, dark: 0xEC9AA2)
        case .neutral:
            return LearnNowPalette.textSecondary
        }
    }

    var softFill: Color {
        switch self {
        case .brand:
            return Color.dynamic(light: 0xDEF2E9, dark: 0x163529)
        case .warning:
            return Color.dynamic(light: 0xF6EEDA, dark: 0x2B2416)
        case .danger:
            return Color.dynamic(light: 0xF8E7E9, dark: 0x2F1D20)
        case .neutral:
            return Color.dynamic(light: 0x1E2522, dark: 0xF3F6F4, lightOpacity: 0.06, darkOpacity: 0.08)
        }
    }

    var onFill: Color {
        switch self {
        case .brand:
            return Color.dynamic(light: 0xFFFFFF, dark: 0x07110D)
        case .warning:
            return Color.dynamic(light: 0xFFFFFF, dark: 0x211A08)
        case .danger:
            return Color.dynamic(light: 0xFFFFFF, dark: 0x230F12)
        case .neutral:
            return Color.dynamic(light: 0xFFFFFF, dark: 0x1E2522)
        }
    }

    var stroke: Color {
        foreground.opacity(0.32)
    }

    static let brandGradient = LinearGradient(
        colors: [
            Color.dynamic(light: 0x0B7A5C, dark: 0x47BE94),
            // 亮端压深到 #0D9A6B：保证渐变实填上的白色图标 ≥3:1（WCAG UI 部件）。
            Color.dynamic(light: 0x0D9A6B, dark: 0x5FD3A6)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

struct BackgroundGlow: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.learnNowAnimationsEnabled) private var animationsEnabled
    @Environment(\.learnNowReduceMotionOverride) private var reduceMotionOverride

    var body: some View {
        let opacityMultiplier: Double = colorScheme == .dark ? 0.7 : 1.0

        if !reduceTransparency {
            if shouldAnimate {
                AnimatedBackgroundGlow(opacityMultiplier: opacityMultiplier)
            } else {
                BackgroundGlowLayer(
                    phase: false,
                    opacityMultiplier: opacityMultiplier
                )
            }
        }
    }

    private var shouldAnimate: Bool {
        animationsEnabled && !(reduceMotionOverride ?? reduceMotion)
    }
}

private struct AnimatedBackgroundGlow: View {
    let opacityMultiplier: Double

    @State private var phase = false

    var body: some View {
        BackgroundGlowLayer(
            phase: phase,
            opacityMultiplier: opacityMultiplier
        )
        .task {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase = true
            }
        }
    }
}

private struct BackgroundGlowLayer: View {
    let phase: Bool
    let opacityMultiplier: Double

    var body: some View {
        ZStack {
            Circle()
                .fill(LearnNowSemanticRole.brand.foreground.opacity(0.16 * opacityMultiplier))
                .frame(width: 340, height: 340)
                .blur(radius: 70)
                .offset(x: phase ? 60 : -60, y: phase ? -220 : -300)

            Circle()
                .fill(LearnNowSemanticRole.brand.foreground.opacity(0.10 * opacityMultiplier))
                .frame(width: 300, height: 300)
                .blur(radius: 80)
                .offset(x: phase ? -80 : 80, y: phase ? 260 : 340)
        }
    }
}

struct OuterSurface: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    func body(content: Content) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)

        return content
            .background {
                if usesOpaqueSurface {
                    shape.fill(LearnNowPalette.surfaceOpaque)
                } else {
                    shape.fill(.ultraThinMaterial)
                }
            }
            .overlay {
                if colorSchemeContrast == .increased {
                    // Increase Contrast：不透明表面 + 对背景 ≥3:1 的中性描边。
                    shape.stroke(LearnNowPalette.textSecondary, lineWidth: 1)
                } else {
                    shape.stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.15 : 0.6), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
                }
            }
            .shadow(color: LearnNowPalette.shadowDark, radius: 16, x: 0, y: 8)
    }

    private var usesOpaqueSurface: Bool {
        reduceTransparency || colorSchemeContrast == .increased
    }
}

/// 通栏材质背景（底部操作条等）的无障碍降级：
/// Reduce Transparency / Increase Contrast 时改用不透明表面。
struct BarMaterialBackground: ViewModifier {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.colorSchemeContrast) private var colorSchemeContrast

    func body(content: Content) -> some View {
        if reduceTransparency || colorSchemeContrast == .increased {
            content.background(LearnNowPalette.surfaceOpaque)
        } else {
            content.background(.ultraThinMaterial)
        }
    }
}

extension View {
    func learnNowBarBackground() -> some View {
        modifier(BarMaterialBackground())
    }
}

struct InsetSurface: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(
                Color.black.opacity(colorScheme == .dark ? 0.35 : 0.05),
                in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(colorScheme == .dark ? 0.05 : 0.4), lineWidth: 1)
            )
            .shadow(color: LearnNowPalette.shadowDark.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

struct SoftPressStyle: ButtonStyle {
    let cornerRadius: CGFloat

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                Group {
                    if configuration.isPressed {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(InsetSurface(cornerRadius: cornerRadius))
                    } else {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(OuterSurface(cornerRadius: cornerRadius))
                    }
                }
            )
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ScreenHeader<Trailing: View>: View {
    let title: String
    var subtitle: String?
    var centered = false
    @ViewBuilder var trailing: () -> Trailing
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    init(
        title: String,
        subtitle: String? = nil,
        centered: Bool = false,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.centered = centered
        self.trailing = trailing
    }

    var body: some View {
        Group {
            if centered {
                titleBlock
                    .frame(maxWidth: .infinity, alignment: .center)
            } else if dynamicTypeSize.isAccessibilitySize {
                VStack(alignment: .leading, spacing: 12) {
                    titleBlock
                        .frame(maxWidth: .infinity, alignment: .leading)
                    trailing()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                HStack(alignment: .center, spacing: 12) {
                    titleBlock
                        .frame(maxWidth: .infinity, alignment: .leading)
                    trailing()
                }
            }
        }
    }

    private var titleBlock: some View {
        VStack(alignment: centered ? .center : .leading, spacing: 4) {
            Text(title)
                .font(LearnNowTypography.screenTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            if let subtitle {
                Text(subtitle)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

struct FloatingTabBar: View {
    let selectedTab: LearnNowTab
    let onSelect: (LearnNowTab) -> Void

    var body: some View {
        HStack(spacing: 10) {
            ForEach(LearnNowTab.allCases) { tab in
                Button {
                    onSelect(tab)
                } label: {
                    ZStack {
                        if tab == selectedTab {
                            Circle()
                                .fill(LearnNowPalette.base)
                                .frame(width: 50, height: 50)
                                .modifier(InsetSurface(cornerRadius: 25))
                        } else {
                            Circle()
                                .fill(LearnNowPalette.base)
                                .frame(width: 50, height: 50)
                                .modifier(OuterSurface(cornerRadius: 25))
                        }

                        Image(systemName: tab.systemImage)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(
                                tab == selectedTab
                                    ? LearnNowSemanticRole.brand.foreground
                                    : LearnNowPalette.textMuted
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("tab.\(tab.rawValue)")
                .accessibilityLabel(tab.title)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule(style: .continuous)
                .fill(LearnNowPalette.base)
                .modifier(OuterSurface(cornerRadius: 999))
        )
    }
}

struct SoftCard<Content: View>: View {
    var contentPadding: CGFloat = 24
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: 26))
            )
    }
}

struct InsetCard<Content: View>: View {
    var contentPadding: CGFloat = 20
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(contentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: 22))
            )
    }
}

struct ProgressTrack: View {
    let progress: Double
    /// 向后兼容：仍传 accent 的调用方保持内容色渐变；默认（nil）走 brand 渐变。
    var accent: LearnNowAccent? = nil
    let height: CGFloat

    var body: some View {
        let clampedProgress = min(max(progress, 0), 1)

        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: height / 2))

                Capsule(style: .continuous)
                    .fill(fillGradient)
                    .frame(width: geometry.size.width * clampedProgress, height: height)
            }
        }
        .frame(height: height)
    }

    private var fillGradient: LinearGradient {
        if let accent {
            LearnNowPalette.gradient(for: accent)
        } else {
            LearnNowSemanticRole.brandGradient
        }
    }
}

struct CircleIconButton: View {
    let systemImage: String
    var size: CGFloat = 44
    let action: () -> Void
    private let iconColor: Color

    init(
        systemImage: String,
        accent: LearnNowAccent,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.action = action
        self.iconColor = LearnNowPalette.color(for: accent)
    }

    init(
        systemImage: String,
        role: LearnNowSemanticRole,
        size: CGFloat = 44,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.size = size
        self.action = action
        self.iconColor = role.foreground
    }

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(LearnNowPalette.base)
                .frame(width: size, height: size)
                .modifier(OuterSurface(cornerRadius: size / 2))
                .overlay {
                    Image(systemName: systemImage)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(iconColor)
                }
        }
        .buttonStyle(.plain)
    }
}

struct InsetCircle<Content: View>: View {
    let size: CGFloat
    @ViewBuilder let content: Content

    var body: some View {
        Circle()
            .fill(LearnNowPalette.base)
            .frame(width: size, height: size)
            .modifier(InsetSurface(cornerRadius: size / 2))
            .overlay {
                content
            }
    }
}

struct AchievementSymbolBadge<Content: View>: View {
    let size: CGFloat
    let glowSize: CGFloat
    let glowOpacity: Double
    let glowBlur: CGFloat
    let strokeOpacity: Double
    let strokeWidth: CGFloat
    let showsGlow: Bool
    private let accentColor: Color
    private let content: Content

    init(
        size: CGFloat,
        accent: LearnNowAccent,
        glowSize: CGFloat,
        glowOpacity: Double,
        glowBlur: CGFloat,
        strokeOpacity: Double,
        strokeWidth: CGFloat = 1,
        showsGlow: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.glowSize = glowSize
        self.glowOpacity = glowOpacity
        self.glowBlur = glowBlur
        self.strokeOpacity = strokeOpacity
        self.strokeWidth = strokeWidth
        self.showsGlow = showsGlow
        self.accentColor = LearnNowPalette.color(for: accent)
        self.content = content()
    }

    init(
        size: CGFloat,
        role: LearnNowSemanticRole,
        glowSize: CGFloat,
        glowOpacity: Double,
        glowBlur: CGFloat,
        strokeOpacity: Double,
        strokeWidth: CGFloat = 1,
        showsGlow: Bool,
        @ViewBuilder content: () -> Content
    ) {
        self.size = size
        self.glowSize = glowSize
        self.glowOpacity = glowOpacity
        self.glowBlur = glowBlur
        self.strokeOpacity = strokeOpacity
        self.strokeWidth = strokeWidth
        self.showsGlow = showsGlow
        self.accentColor = role.foreground
        self.content = content()
    }

    var body: some View {
        ZStack {
            if showsGlow {
                Circle()
                    .fill(accentColor.opacity(glowOpacity))
                    .frame(width: glowSize, height: glowSize)
                    .blur(radius: glowBlur)
            }

            InsetCircle(size: size) {
                content
            }
            .overlay {
                Circle()
                    .stroke(
                        accentColor.opacity(strokeOpacity),
                        lineWidth: strokeWidth
                    )
            }
        }
    }
}

struct FullWidthButton: View {
    let title: String
    var systemImage: String? = nil
    let action: () -> Void
    private let resolvedAccentColor: Color?

    init(
        title: String,
        accent: LearnNowAccent? = nil,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.resolvedAccentColor = accent.map { LearnNowPalette.color(for: $0) }
    }

    init(
        title: String,
        role: LearnNowSemanticRole,
        systemImage: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
        self.resolvedAccentColor = role.foreground
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(LearnNowTypography.label)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.subheadline.weight(.bold))
                }
            }
            .foregroundStyle(accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 999))
    }

    private var accentColor: Color {
        resolvedAccentColor ?? LearnNowPalette.textPrimary
    }
}

extension View {
    func softOuter(radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        shadow(color: LearnNowPalette.shadowDark, radius: radius, x: 0, y: y)
    }
}

extension Color {
    static func dynamic(
        light: UInt,
        dark: UInt,
        lightOpacity: Double = 1.0,
        darkOpacity: Double = 1.0
    ) -> Color {
#if canImport(UIKit)
        Color(UIColor { trait in
            let hex = trait.userInterfaceStyle == .dark ? dark : light
            let opacity = trait.userInterfaceStyle == .dark ? darkOpacity : lightOpacity

            return UIColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: CGFloat(opacity)
            )
        })
#elseif canImport(AppKit)
        Color(NSColor(name: nil) { appearance in
            let isDark = appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
            let hex = isDark ? dark : light
            let opacity = isDark ? darkOpacity : lightOpacity
            return NSColor(
                red: CGFloat((hex >> 16) & 0xFF) / 255.0,
                green: CGFloat((hex >> 8) & 0xFF) / 255.0,
                blue: CGFloat(hex & 0xFF) / 255.0,
                alpha: CGFloat(opacity)
            )
        })
#else
        Color(hex: light, opacity: lightOpacity)
#endif
    }

    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}
