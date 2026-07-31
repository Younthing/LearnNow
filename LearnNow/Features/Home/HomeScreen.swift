import SwiftUI

private enum HomeLayout {
    static let topPadding: CGFloat = LearnNowSpacing.screenTop
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
                    .frame(minHeight: HomeLayout.headerHeight, alignment: .center)

                    TodayStatusCard(
                        metrics: model.statusMetrics,
                        streakDays: model.streakDays,
                        contentHeight: HomeLayout.contentHeight(for: cardHeights.status),
                        action: onContinueLearning
                    )

                    ContinueLearningCard(
                        sectionTitle: model.continueSectionTitle,
                        badge: model.continueCard.badge,
                        title: model.continueCard.title,
                        progress: model.continueCard.progress,
                        progressText: model.continueCard.progressText,
                        contentHeight: HomeLayout.contentHeight(for: cardHeights.secondary),
                        action: onContinueLearning
                    )

                    KnowledgeTipCard(
                        title: model.tipSectionTitle,
                        tip: model.knowledgeTip,
                        contentHeight: HomeLayout.contentHeight(for: cardHeights.secondary)
                    )
                }
                .padding(
                    .horizontal,
                    LearnNowSpacing.screenHorizontal(for: geometry.size.width)
                )
                .padding(.top, HomeLayout.topPadding)
                .padding(.bottom, HomeLayout.bottomPadding)
                .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                .frame(maxWidth: .infinity, minHeight: geometry.size.height, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .accessibilityIdentifier("screen.home")
    }
}

private struct TodayStatusCard: View {
    let metrics: [LearnNowMetric]
    let streakDays: Int
    let contentHeight: CGFloat
    let action: () -> Void

    private var primaryMetric: LearnNowMetric? {
        metrics.first { $0.id == "streak" }
    }

    private var supportingMetrics: [LearnNowMetric] {
        metrics.filter { $0.id != "streak" }
    }

    private var accessibilityValue: String {
        metrics
            .map { metric in
                let unit = metric.unit.map { " \($0)" } ?? ""
                return "\(metric.title) \(metric.value)\(unit)"
            }
            .joined(separator: "，")
    }

    var body: some View {
        Button(action: action) {
            StatusSoftCardContent(contentHeight: contentHeight) {
                VStack(alignment: .leading, spacing: 20) {
                    if let primaryMetric {
                        StreakAchievementHero(
                            metric: primaryMetric,
                            streakDays: streakDays
                        )
                    }

                    if !supportingMetrics.isEmpty {
                        StatusMetricsBand(metrics: Array(supportingMetrics.prefix(2)))
                    }
                }
                .frame(minHeight: contentHeight, alignment: .center)
            }
        }
        .buttonStyle(SoftPressStyle(cornerRadius: HomeLayout.cardCornerRadius))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("继续学习")
        .accessibilityValue(accessibilityValue)
        .accessibilityHint("打开当前课程")
        .accessibilityIdentifier("home.status.continue")
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
            .frame(minHeight: cardHeight, alignment: .center)
            .contentShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
    }
}

private struct StreakAchievementHero: View {
    let metric: LearnNowMetric
    let streakDays: Int

    var body: some View {
        HStack(alignment: .center, spacing: 18) {
            StreakIconBadge(
                streakDays: streakDays,
                accent: metric.accent
            )

            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(metric.value)
                        .font(LearnNowTypography.metricValue)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(streakSuffix)
                        .font(LearnNowTypography.metricUnit)
                        .foregroundStyle(LearnNowPalette.textSecondary)
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
        let current = max(streakDays, 0)

        guard let nextTarget = targets.first(where: { current < $0 }) else {
            return "保持节奏"
        }

        return "距 \(nextTarget) 天还 \(nextTarget - current) 天"
    }
}

private struct StreakIconBadge: View {
    let streakDays: Int
    let accent: LearnNowAccent

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        AchievementSymbolBadge(
            size: 80,
            accent: accent,
            glowSize: 96,
            glowOpacity: 0.12,
            glowBlur: 14,
            strokeOpacity: isActive ? 0.30 : 0.18,
            showsGlow: isActive && !reduceTransparency
        ) {
            Image(systemName: isActive ? "flame.fill" : "flame")
                .font(.largeTitle.weight(.semibold))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(
                    LearnNowPalette.color(for: accent).opacity(isActive ? 1 : 0.62)
                )
        }
        .frame(width: 86, height: 86)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }

    private var isActive: Bool {
        streakDays > 0
    }
}

private struct StatusMetricsBand: View {
    let metrics: [LearnNowMetric]

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                ForEach(metrics) { metric in
                    StatusSummaryMetric(metric: metric)
                }
            }

            VStack(spacing: 12) {
                ForEach(metrics) { metric in
                    StatusSummaryMetric(metric: metric)
                }
            }
        }
    }
}

private struct StatusSummaryMetric: View {
    let metric: LearnNowMetric

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            StatusIconBadge(metric: metric)

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(LearnNowTypography.caption)
                    .foregroundStyle(LearnNowPalette.textMuted)

                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(metric.value)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

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
                .fill(LearnNowSemanticRole.neutral.softFill)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(
                    LearnNowSemanticRole.neutral.foreground.opacity(0.13),
                    lineWidth: 0.75
                )
        }
    }
}

private struct StatusIconBadge: View {
    let metric: LearnNowMetric

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Circle()
                .fill(LearnNowPalette.base)
                .overlay {
                    Circle()
                        .fill(LearnNowSemanticRole.neutral.foreground.opacity(0.08))
                }
                .overlay {
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(colorScheme == .dark ? 0.14 : 0.48),
                                    LearnNowSemanticRole.neutral.foreground.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.75
                        )
                }
                .frame(width: 40, height: 40)

            if let systemImage = metric.systemImage {
                Image(systemName: systemImage)
                    .font(.headline.weight(.semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(LearnNowSemanticRole.neutral.foreground)
            }
        }
        .frame(width: 40, height: 40)
        .accessibilityHidden(true)
        .allowsHitTesting(false)
    }
}

private struct ContinueLearningCard: View {
    let sectionTitle: String
    let badge: String
    let title: String
    let progress: Double
    let progressText: String
    let contentHeight: CGFloat
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            SoftCard(contentPadding: 20) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .center) {
                        Text(sectionTitle)
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Spacer()

                        MetadataChip(text: progressText, role: .brand)
                    }

                    HStack(alignment: .center, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            MetadataChip(text: badge, role: .brand)

                            Text(title)
                                .font(LearnNowTypography.cardHeadline)
                                .foregroundStyle(LearnNowPalette.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        ContinueLearningPlayIcon()
                    }

                    Spacer(minLength: HomeLayout.progressBottomSpacing)

                    ProgressTrack(progress: progress, height: 12)
                }
                .frame(minHeight: contentHeight, alignment: .top)
            }
            .contentShape(RoundedRectangle(cornerRadius: HomeLayout.cardCornerRadius, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("继续学习")
        .accessibilityValue("\(badge)，\(title)，\(progressText)")
        .accessibilityHint("打开当前课程")
        .accessibilityIdentifier("home.continue")
    }
}

private struct ContinueLearningPlayIcon: View {
    var body: some View {
        Circle()
            .fill(LearnNowPalette.base)
            .frame(width: 44, height: 44)
            .modifier(OuterSurface(cornerRadius: 22))
            .overlay {
                Image(systemName: "play.fill")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(LearnNowSemanticRole.brand.foreground)
            }
            .accessibilityHidden(true)
            .allowsHitTesting(false)
    }
}

private struct KnowledgeTipCard: View {
    let title: String
    let tip: HomeScreenModel.KnowledgeTip
    let contentHeight: CGFloat
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.color(for: .mint))

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(alignment: .leading, spacing: 12) {
                        TipIcon(systemImage: tip.systemImage, accent: tip.accent)
                        TipCopy(tip: tip)
                    }
                    .padding(.top, 8)
                } else {
                    standardContent
                }
            }
            .frame(minHeight: contentHeight, alignment: .top)
        }
        .accessibilityElement(children: .combine)
    }

    private var standardContent: some View {
        HStack(alignment: .center, spacing: 10) {
            TipIcon(systemImage: tip.systemImage, accent: tip.accent)

            TipCopy(tip: tip)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.top, 8)
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
                .font(.title3.weight(.medium))
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
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            InlineContentText(content: tip.body)
                .font(LearnNowTypography.screenSubtitle)
                .foregroundStyle(LearnNowPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)

        }
    }
}

#Preview("Home · Active Streak") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(
            model: LearnNowFlowState.homePreview.homeScreenModel,
            onContinueLearning: {}
        )
    }
}

private struct HomeStatusIconGallery: View {
    private let xpMetric = LearnNowMetric(
        id: "xp",
        title: "经验",
        value: "1240",
        unit: "XP",
        systemImage: "bolt.fill",
        accent: .purple
    )

    private let reviewMetric = LearnNowMetric(
        id: "review",
        title: "待复习卡片",
        value: "3",
        unit: "张",
        systemImage: "calendar.badge.clock",
        accent: .blue
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("连续学习")
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            HStack(spacing: 28) {
                previewStreak(days: 0, label: "尚未开始")
                previewStreak(days: 12, label: "已点燃")
            }

            Text("辅助指标")
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            HStack(spacing: 28) {
                previewMetric(xpMetric)
                previewMetric(reviewMetric)
            }
        }
        .padding(28)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(LearnNowPalette.canvas)
    }

    private func previewStreak(days: Int, label: String) -> some View {
        VStack(spacing: 8) {
            StreakIconBadge(streakDays: days, accent: .amber)

            Text(label)
                .font(LearnNowTypography.label)
                .foregroundStyle(LearnNowPalette.textMuted)
        }
    }

    private func previewMetric(_ metric: LearnNowMetric) -> some View {
        HStack(spacing: 10) {
            StatusIconBadge(metric: metric)

            Text(metric.title)
                .font(LearnNowTypography.label)
                .foregroundStyle(LearnNowPalette.textSecondary)
        }
    }
}

#Preview("Home · Status Icons") {
    HomeStatusIconGallery()
}

#Preview("Home · Status Icons · Dark") {
    HomeStatusIconGallery()
        .preferredColorScheme(.dark)
}
