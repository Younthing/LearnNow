import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

enum LearnNowPalette {
    static let base = Color.dynamic(light: 0xFFFFFF, dark: 0x1E1E24, lightOpacity: 0.55, darkOpacity: 0.5)
    static let canvas = Color.dynamic(light: 0xF4F6F9, dark: 0x07070A)
    static let textPrimary = Color.dynamic(light: 0x1E293B, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.95)
    static let textSecondary = Color.dynamic(light: 0x475569, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.75)
    static let textMuted = Color.dynamic(light: 0x94A3B8, dark: 0xFFFFFF, lightOpacity: 1.0, darkOpacity: 0.5)
    static let shadowDark = Color.dynamic(light: 0xA4ADC1, dark: 0x000000, lightOpacity: 0.4, darkOpacity: 0.5)
    static let shadowLight = Color.dynamic(light: 0xFFFFFF, dark: 0xFFFFFF, lightOpacity: 0.9, darkOpacity: 0.1)

    static func color(for accent: LearnNowAccent) -> Color {
        switch accent {
        case .blue:
            return Color.dynamic(light: 0x2563EB, dark: 0x5E6AD2)
        case .pink:
            return Color.dynamic(light: 0xEC4899, dark: 0xF43F5E)
        case .mint:
            return Color.dynamic(light: 0x10B981, dark: 0x10B981)
        case .purple:
            return Color.dynamic(light: 0x8B5CF6, dark: 0x8B5CF6)
        case .amber:
            return Color.dynamic(light: 0xF59E0B, dark: 0xF59E0B)
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

struct BackgroundGlow: View {
    @State private var phase = false
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let opacityMultiplier: Double = colorScheme == .dark ? 0.7 : 1.0

        ZStack {
            Circle()
                .fill(LearnNowPalette.color(for: .blue).opacity(0.35 * opacityMultiplier))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: phase ? 100 : -100, y: phase ? -200 : -350)

            Circle()
                .fill(LearnNowPalette.color(for: .purple).opacity(0.30 * opacityMultiplier))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: phase ? -120 : 120, y: phase ? -80 : 80)

            Circle()
                .fill(LearnNowPalette.color(for: .mint).opacity(0.35 * opacityMultiplier))
                .frame(width: 300, height: 300)
                .blur(radius: 70)
                .offset(x: phase ? 140 : -140, y: phase ? 250 : 380)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                phase.toggle()
            }
        }
    }
}

struct OuterSurface: ViewModifier {
    let cornerRadius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.white.opacity(colorScheme == .dark ? 0.15 : 0.6), .clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: LearnNowPalette.shadowDark, radius: 16, x: 0, y: 8)
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
        HStack(alignment: .center) {
            VStack(alignment: centered ? .center : .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                }
            }
            .frame(maxWidth: .infinity, alignment: centered ? .center : .leading)

            if !centered {
                trailing()
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
                            .font(.system(size: 21, weight: .bold))
                            .foregroundStyle(
                                tab == selectedTab
                                    ? LearnNowPalette.color(for: .blue)
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

struct FlowLayout<Item: Hashable, Content: View>: View {
    let items: [Item]
    let content: (Item) -> Content

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 84), spacing: 8)],
            alignment: .leading,
            spacing: 8
        ) {
            ForEach(items, id: \.self) { item in
                content(item)
            }
        }
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
    let accent: LearnNowAccent
    let height: CGFloat

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(InsetSurface(cornerRadius: height / 2))

                Capsule(style: .continuous)
                    .fill(LearnNowPalette.gradient(for: accent))
                    .frame(width: max(geometry.size.width * progress, 0), height: height)
            }
        }
        .frame(height: height)
    }
}

struct NeumorphicPill: View {
    let text: String
    let accent: LearnNowAccent
    var isSelected = false
    var isExpanded = false

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundStyle(
                isSelected ? LearnNowPalette.color(for: accent) : LearnNowPalette.textMuted
            )
            .padding(.horizontal, 8)
            .padding(.vertical, 10)
            .frame(maxWidth: isExpanded ? .infinity : nil)
            .background(
                Group {
                    if isSelected {
                        Capsule(style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(InsetSurface(cornerRadius: 999))
                    } else {
                        Capsule(style: .continuous)
                            .fill(LearnNowPalette.base)
                            .modifier(OuterSurface(cornerRadius: 999))
                    }
                }
            )
    }
}

struct CircleIconButton: View {
    let systemImage: String
    let accent: LearnNowAccent
    var size: CGFloat = 44
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Circle()
                .fill(LearnNowPalette.base)
                .frame(width: size, height: size)
                .modifier(OuterSurface(cornerRadius: size / 2))
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: accent))
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

struct FullWidthButton: View {
    let title: String
    var accent: LearnNowAccent? = nil
    var systemImage: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 16, weight: .heavy, design: .rounded))

                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundStyle(accentColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
        .buttonStyle(SoftPressStyle(cornerRadius: 999))
    }

    private var accentColor: Color {
        if let accent {
            LearnNowPalette.color(for: accent)
        } else {
            LearnNowPalette.textPrimary
        }
    }
}

extension View {
    func softOuter(radius: CGFloat, x: CGFloat, y: CGFloat) -> some View {
        shadow(color: LearnNowPalette.shadowDark, radius: radius, x: 0, y: y)
    }
}

extension Color {
#if canImport(UIKit)
    static func dynamic(
        light: UInt,
        dark: UInt,
        lightOpacity: Double = 1.0,
        darkOpacity: Double = 1.0
    ) -> Color {
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
    }
#endif

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
