import SwiftUI

private enum HomeLayout {
    static let topPadding: CGFloat = LearnNowSpacing.screenTop
    static let horizontalPadding: CGFloat = LearnNowSpacing.screenHorizontal
    static let cardSpacing: CGFloat = 14
    static let estimatedHeaderHeight: CGFloat = 58
    static let cardContentPadding: CGFloat = 20

    static func cardHeights(for availableHeight: CGFloat) -> (status: CGFloat, secondary: CGFloat) {
        let totalCardHeight = max(
            0,
            availableHeight - topPadding - estimatedHeaderHeight - cardSpacing * 3
        )
        let unit = totalCardHeight / 7

        return (status: unit * 3, secondary: unit * 2)
    }

    static func contentHeight(for cardHeight: CGFloat) -> CGFloat {
        max(0, cardHeight - cardContentPadding * 2)
    }
}

struct HomeScreen: View {
    let model: HomeScreenModel
    let onContinueLearning: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let cardHeights = HomeLayout.cardHeights(for: geometry.size.height)

            VStack(alignment: .leading, spacing: HomeLayout.cardSpacing) {
                ScreenHeader(
                    title: model.title,
                    subtitle: model.subtitle,
                    trailing: { AvatarBadge() }
                )
                .frame(height: HomeLayout.estimatedHeaderHeight, alignment: .center)

                TodayStatusCard(
                    metrics: model.statusMetrics,
                    contentHeight: HomeLayout.contentHeight(for: cardHeights.status),
                    action: onContinueLearning
                )

                ContinueLearningCard(
                    sectionTitle: model.continueSectionTitle,
                    badge: model.continueCard.badge,
                    title: model.continueCard.title,
                    progress: model.continueCard.progress,
                    progressText: model.continueCard.progressText,
                    accent: .blue,
                    contentHeight: HomeLayout.contentHeight(for: cardHeights.secondary),
                    action: onContinueLearning
                )

                KnowledgeTipCard(
                    title: model.tipSectionTitle,
                    tip: model.knowledgeTip,
                    contentHeight: HomeLayout.contentHeight(for: cardHeights.secondary)
                )
            }
            .padding(.horizontal, HomeLayout.horizontalPadding)
            .padding(.top, HomeLayout.topPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .accessibilityIdentifier("screen.home")
    }
}

private struct TodayStatusCard: View {
    let metrics: [LearnNowMetric]
    let contentHeight: CGFloat
    let action: () -> Void

    private var primaryMetric: LearnNowMetric? {
        metrics.first { $0.id == "streak" } ?? metrics.first
    }

    private var supportingMetrics: [LearnNowMetric] {
        guard let primaryMetric else { return Array(metrics.dropFirst()) }
        return metrics.filter { $0.id != primaryMetric.id }
    }

    var body: some View {
        Button(action: action) {
            LayeredStatusGlassCard(contentHeight: contentHeight) {
                VStack(alignment: .leading, spacing: 20) {
                    if let primaryMetric {
                        StreakAchievementHero(metric: primaryMetric)
                    }

                    if !supportingMetrics.isEmpty {
                        StatusMetricsBand(metrics: Array(supportingMetrics.prefix(2)))
                    }
                }
                .frame(height: contentHeight, alignment: .center)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("继续学习，保持连续学习")
        .accessibilityElement(children: .combine)
    }
}

private struct LayeredStatusGlassCard<Content: View>: View {
    let contentHeight: CGFloat
    private let content: Content
    @Environment(\.colorScheme) private var colorScheme

    init(contentHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.contentHeight = contentHeight
        self.content = content()
    }

    var body: some View {
        let cardHeight = contentHeight + HomeLayout.cardContentPadding * 2
        let cornerRadius: CGFloat = 34
        let isDark = colorScheme == .dark

        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDark ? 0.11 : 0.42),
                            LearnNowPalette.color(for: .blue).opacity(isDark ? 0.12 : 0.16),
                            LearnNowPalette.color(for: .purple).opacity(isDark ? 0.10 : 0.13)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            StatusAlignedGlassPanels(cornerRadius: cornerRadius - 10, isDark: isDark)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(isDark ? 0.72 : 0.82)

            StatusGlassHighlights(cornerRadius: cornerRadius, isDark: isDark)

            content
                .padding(HomeLayout.cardContentPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: cardHeight, alignment: .center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isDark ? 0.22 : 0.72),
                            Color.white.opacity(isDark ? 0.08 : 0.24),
                            LearnNowPalette.color(for: .blue).opacity(isDark ? 0.18 : 0.26)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: LearnNowPalette.shadowLight.opacity(isDark ? 0.05 : 0.65), radius: 10, x: -7, y: -7)
        .shadow(color: LearnNowPalette.shadowDark.opacity(isDark ? 0.42 : 0.28), radius: 24, x: 0, y: 16)
        .contentShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

private struct StatusAlignedGlassPanels: View {
    let cornerRadius: CGFloat
    let isDark: Bool

    var body: some View {
        GeometryReader { geometry in
            let inset: CGFloat = 14
            let width = max(0, geometry.size.width - inset * 2)
            let topHeight = geometry.size.height * 0.52
            let bottomHeight = geometry.size.height * 0.34

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                LearnNowPalette.color(for: .mint).opacity(isDark ? 0.16 : 0.22),
                                LearnNowPalette.color(for: .blue).opacity(isDark ? 0.08 : 0.12),
                                .clear
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: topHeight)
                    .offset(x: inset, y: inset)

                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isDark ? 0.08 : 0.26),
                                LearnNowPalette.color(for: .purple).opacity(isDark ? 0.15 : 0.18),
                                LearnNowPalette.color(for: .pink).opacity(isDark ? 0.12 : 0.16)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: width, height: bottomHeight)
                    .offset(x: inset, y: geometry.size.height - bottomHeight - inset)

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(isDark ? 0.07 : 0.24))
                    .frame(width: 96, height: 118)
                    .offset(x: geometry.size.width - 116, y: 34)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StatusGlassHighlights: View {
    let cornerRadius: CGFloat
    let isDark: Bool

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    LearnNowPalette.color(for: .blue).opacity(isDark ? 0.30 : 0.26),
                    .clear
                ],
                center: .topLeading,
                startRadius: 8,
                endRadius: 230
            )

            RadialGradient(
                colors: [
                    LearnNowPalette.color(for: .pink).opacity(isDark ? 0.14 : 0.16),
                    .clear
                ],
                center: .bottomTrailing,
                startRadius: 12,
                endRadius: 200
            )

            VStack {
                Capsule(style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(isDark ? 0.22 : 0.58),
                                Color.white.opacity(0.03)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 9)
                    .padding(.horizontal, 36)
                    .padding(.top, 15)

                Spacer()
            }

            HStack {
                Spacer()

                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.white.opacity(isDark ? 0.06 : 0.28))
                    .frame(width: 92, height: 132)
                    .rotationEffect(.degrees(-18))
                    .offset(x: 22, y: -20)
                    .blur(radius: 0.2)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .allowsHitTesting(false)
    }
}

private struct StreakAchievementHero: View {
    let metric: LearnNowMetric

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            StreakIconBadge(accent: metric.accent)

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(metric.value)
                        .font(.system(size: 54, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(streakSuffix)
                        .font(.system(size: 21, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(milestoneText)
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 7)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color.white.opacity(0.20))
                            .background(.thinMaterial, in: Capsule(style: .continuous))
                            .overlay {
                                Capsule(style: .continuous)
                                    .stroke(Color.white.opacity(0.34), lineWidth: 0.8)
                            }
                    )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var streakSuffix: String {
        if let unit = metric.unit {
            return "\(unit)连续"
        }

        return "连续"
    }

    private var milestoneText: String {
        let targets = [7, 14, 30, 60, 100]
        guard
            let current = Int(metric.value),
            let nextTarget = targets.first(where: { current < $0 })
        else {
            return "保持节奏"
        }

        return "距 \(nextTarget) 天还 \(nextTarget - current) 天"
    }
}

private struct StreakIconBadge: View {
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 84, height: 84)
                .overlay {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.46),
                                    LearnNowPalette.color(for: accent).opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.54), lineWidth: 1)
                }
                .softOuter(radius: 16, x: 0, y: 10)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: 0xFFE8A3),
                            Color(hex: 0xFFAB1F),
                            Color(hex: 0xF66A18)
                        ],
                        center: .topLeading,
                        startRadius: 3,
                        endRadius: 44
                    )
                )
                .frame(width: 60, height: 60)
                .shadow(color: Color(hex: 0xF59E0B).opacity(0.34), radius: 16, x: 0, y: 8)

            RoundedFlameGlyph(accent: accent)
                .frame(width: 42, height: 47)
                .offset(y: 1)

            Circle()
                .fill(Color.white.opacity(0.48))
                .frame(width: 18, height: 18)
                .offset(x: 25, y: -24)
                .blur(radius: 0.3)

            Circle()
                .fill(Color.white.opacity(0.24))
                .frame(width: 9, height: 9)
                .offset(x: -28, y: 24)
        }
        .frame(width: 86, height: 86)
    }
}

private struct RoundedFlameGlyph: View {
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            OrganicFlameShape()
                .fill(LearnNowPalette.color(for: accent).opacity(0.30))
                .blur(radius: 8)
                .offset(y: 4)

            OrganicFlameShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xFFF4B8),
                            Color(hex: 0xFFC342),
                            Color(hex: 0xFF8A1C),
                            Color(hex: 0xF15C22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay {
                    OrganicFlameShape()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.58),
                                    Color.white.opacity(0.16),
                                    .clear
                                ],
                                center: .topLeading,
                                startRadius: 1,
                                endRadius: 30
                            )
                        )
                }
                .overlay {
                    OrganicFlameShape()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.66),
                                    Color.white.opacity(0.08),
                                    Color(hex: 0xD9480F).opacity(0.22)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.2
                        )
                }

            InnerFlameShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.96),
                            Color(hex: 0xFFE77A),
                            Color(hex: 0xFFB21A)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 19, height: 28)
                .offset(x: -1, y: 8)
                .shadow(color: Color.white.opacity(0.28), radius: 5, x: -1, y: -2)

            FlameHighlightShape()
                .fill(Color.white.opacity(0.38))
                .frame(width: 13, height: 18)
                .offset(x: -7, y: -7)
                .blur(radius: 0.2)
        }
    }
}

private struct OrganicFlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.52, y: h * 0.98))
        path.addCurve(
            to: CGPoint(x: w * 0.15, y: h * 0.70),
            control1: CGPoint(x: w * 0.32, y: h * 0.98),
            control2: CGPoint(x: w * 0.10, y: h * 0.88)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.34, y: h * 0.18),
            control1: CGPoint(x: w * 0.20, y: h * 0.50),
            control2: CGPoint(x: w * 0.25, y: h * 0.37)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.34),
            control1: CGPoint(x: w * 0.42, y: h * 0.20),
            control2: CGPoint(x: w * 0.45, y: h * 0.28)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.66, y: h * 0.04),
            control1: CGPoint(x: w * 0.58, y: h * 0.24),
            control2: CGPoint(x: w * 0.55, y: h * 0.08)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.86, y: h * 0.62),
            control1: CGPoint(x: w * 0.80, y: h * 0.20),
            control2: CGPoint(x: w * 0.90, y: h * 0.38)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.52, y: h * 0.98),
            control1: CGPoint(x: w * 0.84, y: h * 0.84),
            control2: CGPoint(x: w * 0.73, y: h * 0.98)
        )
        path.closeSubpath()

        return path
    }
}

private struct InnerFlameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.52, y: h * 0.98))
        path.addCurve(
            to: CGPoint(x: w * 0.16, y: h * 0.68),
            control1: CGPoint(x: w * 0.31, y: h * 0.97),
            control2: CGPoint(x: w * 0.14, y: h * 0.83)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.50, y: h * 0.08),
            control1: CGPoint(x: w * 0.18, y: h * 0.45),
            control2: CGPoint(x: w * 0.40, y: h * 0.31)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.84, y: h * 0.66),
            control1: CGPoint(x: w * 0.70, y: h * 0.27),
            control2: CGPoint(x: w * 0.86, y: h * 0.43)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.52, y: h * 0.98),
            control1: CGPoint(x: w * 0.82, y: h * 0.84),
            control2: CGPoint(x: w * 0.68, y: h * 0.98)
        )
        path.closeSubpath()

        return path
    }
}

private struct FlameHighlightShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        path.move(to: CGPoint(x: w * 0.54, y: h * 0.04))
        path.addCurve(
            to: CGPoint(x: w * 0.18, y: h * 0.62),
            control1: CGPoint(x: w * 0.30, y: h * 0.24),
            control2: CGPoint(x: w * 0.15, y: h * 0.42)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.54, y: h * 0.96),
            control1: CGPoint(x: w * 0.20, y: h * 0.80),
            control2: CGPoint(x: w * 0.34, y: h * 0.94)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.74, y: h * 0.54),
            control1: CGPoint(x: w * 0.72, y: h * 0.82),
            control2: CGPoint(x: w * 0.78, y: h * 0.66)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.54, y: h * 0.04),
            control1: CGPoint(x: w * 0.68, y: h * 0.32),
            control2: CGPoint(x: w * 0.56, y: h * 0.22)
        )
        path.closeSubpath()

        return path
    }
}

private struct StatusMetricsBand: View {
    let metrics: [LearnNowMetric]

    var body: some View {
        HStack(spacing: 10) {
            ForEach(metrics) { metric in
                StatusSummaryMetric(metric: metric)
            }
        }
        .padding(8)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.14))
                .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.48),
                                    Color.white.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                }
                .shadow(color: LearnNowPalette.shadowDark.opacity(0.16), radius: 10, x: 0, y: 7)
        )
    }
}

private struct StatusSummaryMetric: View {
    let metric: LearnNowMetric

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            StatusIconBadge(systemImage: metric.systemImage, accent: metric.accent)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(.system(size: 12, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(metric.value)
                        .font(.system(size: 18, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let unit = metric.unit {
                        Text(unit)
                            .font(LearnNowTypography.label)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.16))
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color.white.opacity(0.24), lineWidth: 0.7)
                }
        )
    }
}

private struct StatusIconBadge: View {
    let systemImage: String?
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.white.opacity(0.20))
                .background(.thinMaterial, in: Circle())
                .frame(width: 40, height: 40)
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(0.44), lineWidth: 1)
                }

            if let systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 17, weight: .black))
                    .foregroundStyle(LearnNowPalette.color(for: accent))
            }
        }
        .frame(width: 40, height: 40)
    }
}

private struct ContinueLearningCard: View {
    let sectionTitle: String
    let badge: String
    let title: String
    let progress: Double
    let progressText: String
    let accent: LearnNowAccent
    let contentHeight: CGFloat
    let action: () -> Void

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    Text(sectionTitle)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Spacer()

                    Text(progressText)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.color(for: accent))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 7)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LearnNowPalette.color(for: accent).opacity(0.12))
                        )
                }

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        NeumorphicPill(text: badge, accent: accent)

                        Text(title)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    CircleIconButton(systemImage: "play.fill", accent: accent, action: action)
                        .accessibilityLabel("继续学习")
                }

                ProgressTrack(progress: progress, accent: accent, height: 12)
            }
            .frame(height: contentHeight, alignment: .top)
        }
    }
}

private struct KnowledgeTipCard: View {
    let title: String
    let tip: HomeScreenModel.KnowledgeTip
    let contentHeight: CGFloat

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.color(for: .mint))

                HStack(alignment: .center, spacing: 10) {
                    TipIcon(systemImage: tip.systemImage, accent: tip.accent)

                    TipCopy(tip: tip)
                        .padding(.trailing, 72)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .overlay(alignment: .trailing) {
                    TipIllustration(accent: tip.accent)
                        .frame(width: 70, height: 54)
                        .allowsHitTesting(false)
                }
                .padding(.top, 8)
            }
            .frame(height: contentHeight, alignment: .top)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct TipIcon: View {
    let systemImage: String
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            Circle()
                .fill(LearnNowPalette.color(for: accent).opacity(0.14))
                .frame(width: 50, height: 50)
                .modifier(OuterSurface(cornerRadius: 25))

            Circle()
                .fill(LearnNowPalette.gradient(for: accent))
                .frame(width: 38, height: 38)
                .opacity(0.18)

            Image(systemName: systemImage)
                .font(.system(size: 21, weight: .medium))
                .foregroundStyle(LearnNowPalette.color(for: accent))
        }
        .frame(width: 52, height: 52)
    }
}

private struct TipCopy: View {
    let tip: HomeScreenModel.KnowledgeTip

    var body: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(tip.title)
                .font(.system(size: 15, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(tip.body)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(LearnNowPalette.textSecondary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

        }
    }
}

private struct TipIllustration: View {
    let accent: LearnNowAccent

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let baseline = height * 0.82
            let peakX = width * 0.58
            let peakY = height * 0.14

            ZStack(alignment: .bottom) {
                TipBellCurve()
                    .stroke(
                        LearnNowPalette.color(for: accent),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )

                Path { path in
                    path.move(to: CGPoint(x: peakX, y: baseline))
                    path.addLine(to: CGPoint(x: peakX, y: peakY))
                }
                .stroke(
                    LearnNowPalette.color(for: accent).opacity(0.6),
                    style: StrokeStyle(lineWidth: 1.4, dash: [5, 4])
                )

                Path { path in
                    path.move(to: CGPoint(x: width * 0.73, y: baseline))
                    path.addCurve(
                        to: CGPoint(x: width * 0.96, y: baseline),
                        control1: CGPoint(x: width * 0.80, y: height * 0.50),
                        control2: CGPoint(x: width * 0.88, y: height * 0.66)
                    )
                    path.addLine(to: CGPoint(x: width * 0.96, y: baseline))
                    path.closeSubpath()
                }
                .fill(LearnNowPalette.color(for: accent).opacity(0.22))

                Path { path in
                    path.move(to: CGPoint(x: width * 0.06, y: baseline))
                    path.addLine(to: CGPoint(x: width * 0.96, y: baseline))
                }
                .stroke(LearnNowPalette.color(for: accent).opacity(0.7), lineWidth: 1)
            }
        }
        .aspectRatio(1.55, contentMode: .fit)
    }
}

private struct TipBellCurve: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let baseline = rect.height * 0.82

        path.move(to: CGPoint(x: rect.width * 0.06, y: baseline))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.58, y: rect.height * 0.14),
            control1: CGPoint(x: rect.width * 0.24, y: baseline),
            control2: CGPoint(x: rect.width * 0.40, y: rect.height * 0.15)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.96, y: baseline),
            control1: CGPoint(x: rect.width * 0.75, y: rect.height * 0.12),
            control2: CGPoint(x: rect.width * 0.78, y: baseline)
        )

        return path
    }
}

private struct AvatarBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [LearnNowPalette.color(for: .blue), LearnNowPalette.color(for: .purple)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 52, height: 52)
                .softOuter(radius: 8, x: 4, y: 4)

            Image(systemName: "person.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white.opacity(0.95))
        }
    }
}

#Preview("Home") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(
            model: LearnNowFlowState.homePreview.homeScreenModel,
            onContinueLearning: {}
        )
    }
}
