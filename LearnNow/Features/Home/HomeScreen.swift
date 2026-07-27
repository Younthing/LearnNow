import SwiftUI

private enum HomeLayout {
    static let topPadding: CGFloat = LearnNowSpacing.screenTop
    static let horizontalPadding: CGFloat = LearnNowSpacing.screenHorizontal
    static let headerHeight: CGFloat = 58
    static let bottomPadding: CGFloat = 0
    static let cardContentPadding: CGFloat = 20
    static let cardCornerRadius: CGFloat = 26
    static let progressBottomSpacing: CGFloat = 12

    static func cardHeights(
        for availableHeight: CGFloat,
        cardSpacing: CGFloat
    ) -> (status: CGFloat, secondary: CGFloat) {
        let totalCardHeight = max(
            0,
            availableHeight
                - topPadding
                - bottomPadding
                - headerHeight
                - cardSpacing * 3
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
    var cardSpacing: CGFloat = 14
    let onContinueLearning: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let cardHeights = HomeLayout.cardHeights(
                for: geometry.size.height,
                cardSpacing: cardSpacing
            )

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: cardSpacing) {
                    ScreenHeader(
                        title: model.title,
                        subtitle: model.subtitle
                    )
                    .frame(height: HomeLayout.headerHeight, alignment: .center)

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
                .padding(.bottom, HomeLayout.bottomPadding)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
            }
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
            StatusSoftCardContent(contentHeight: contentHeight) {
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
        .buttonStyle(SoftPressStyle(cornerRadius: HomeLayout.cardCornerRadius))
        .accessibilityLabel("继续学习，保持连续学习")
        .accessibilityElement(children: .combine)
    }
}

private struct StatusSoftCardContent<Content: View>: View {
    let contentHeight: CGFloat
    private let content: Content

    init(contentHeight: CGFloat, @ViewBuilder content: () -> Content) {
        self.contentHeight = contentHeight
        self.content = content()
    }

    var body: some View {
        let cardHeight = contentHeight + HomeLayout.cardContentPadding * 2
        content
            .padding(HomeLayout.cardContentPadding)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: cardHeight, alignment: .center)
            .contentShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
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

                MetadataChip(text: milestoneText, accent: metric.accent)
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
                .fill(LearnNowPalette.base)
                .frame(width: 84, height: 84)
                .modifier(OuterSurface(cornerRadius: 42))

            Circle()
                .fill(LearnNowPalette.color(for: accent).opacity(0.11))
                .frame(width: 66, height: 66)
                .modifier(InsetSurface(cornerRadius: 33))

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
                .fill(Color.white.opacity(0.38))
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
        HStack(spacing: 12) {
            ForEach(metrics) { metric in
                StatusSummaryMetric(metric: metric)
            }
        }
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
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LearnNowPalette.color(for: metric.accent).opacity(0.07))
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LearnNowPalette.color(for: metric.accent).opacity(0.13),
                    lineWidth: 0.75
                )
        }
    }
}

private struct StatusIconBadge: View {
    let systemImage: String?
    let accent: LearnNowAccent

    var body: some View {
        ZStack {
            Circle()
                .fill(LearnNowPalette.color(for: accent).opacity(0.10))
                .frame(width: 40, height: 40)

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

                    MetadataChip(text: progressText, accent: accent)
                }

                HStack(alignment: .center, spacing: 16) {
                    VStack(alignment: .leading, spacing: 10) {
                        MetadataChip(text: badge, accent: accent)

                        Text(title)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .lineLimit(2)
                            .minimumScaleFactor(0.82)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    CircleIconButton(systemImage: "play.fill", accent: accent, action: action)
                        .accessibilityLabel("继续学习")
                }

                Spacer(minLength: HomeLayout.progressBottomSpacing)

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

#Preview("Home") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(
            model: LearnNowFlowState.homePreview.homeScreenModel,
            onContinueLearning: {}
        )
    }
}
