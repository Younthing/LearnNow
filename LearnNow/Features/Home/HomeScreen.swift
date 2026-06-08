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
                    title: model.todayStatusTitle,
                    metrics: model.statusMetrics,
                    contentHeight: HomeLayout.contentHeight(for: cardHeights.status)
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
    let title: String
    let metrics: [LearnNowMetric]
    let contentHeight: CGFloat

    private var primaryMetric: LearnNowMetric? {
        metrics.first { $0.id == "streak" } ?? metrics.first
    }

    private var supportingMetrics: [LearnNowMetric] {
        guard let primaryMetric else { return Array(metrics.dropFirst()) }
        return metrics.filter { $0.id != primaryMetric.id }
    }

    var body: some View {
        SoftCard(contentPadding: 20) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .center) {
                    Text(title)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Spacer(minLength: 12)

                    if let primaryMetric {
                        NeumorphicPill(
                            text: "\(primaryMetric.value)\(primaryMetric.unit ?? "") 连续",
                            accent: primaryMetric.accent
                        )
                    }
                }

                ViewThatFits(in: .horizontal) {
                    HStack(alignment: .center, spacing: 20) {
                        if let primaryMetric {
                            PrimaryStatusMetric(metric: primaryMetric)
                        }

                        Spacer(minLength: 0)

                        VStack(alignment: .leading, spacing: 14) {
                            ForEach(supportingMetrics) { metric in
                                SupportingStatusMetric(metric: metric)
                            }
                        }
                        .frame(maxWidth: 150, alignment: .leading)
                    }

                    VStack(alignment: .leading, spacing: 16) {
                        if let primaryMetric {
                            PrimaryStatusMetric(metric: primaryMetric)
                        }

                        Divider()
                            .overlay(LearnNowPalette.shadowDark.opacity(0.18))

                        ForEach(supportingMetrics) { metric in
                            SupportingStatusMetric(metric: metric)
                        }
                    }
                }
            }
            .frame(height: contentHeight, alignment: .center)
        }
        .accessibilityElement(children: .combine)
    }
}

private struct PrimaryStatusMetric: View {
    let metric: LearnNowMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Circle()
                    .fill(LearnNowPalette.gradient(for: metric.accent))
                    .frame(width: 48, height: 48)
                    .softOuter(radius: 10, x: 0, y: 6)

                if let systemImage = metric.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .black))
                        .foregroundStyle(.white.opacity(0.95))
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(metric.value)
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    if let unit = metric.unit {
                        Text(unit)
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }

                Text(metric.title)
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.textSecondary)
            }
        }
        .frame(minWidth: 112, alignment: .leading)
    }
}

private struct SupportingStatusMetric: View {
    let metric: LearnNowMetric

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ZStack {
                Circle()
                    .fill(LearnNowPalette.base)
                    .frame(width: 36, height: 36)
                    .modifier(InsetSurface(cornerRadius: 18))

                if let systemImage = metric.systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 14, weight: .black))
                        .foregroundStyle(LearnNowPalette.color(for: metric.accent))
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.title)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)

                HStack(alignment: .firstTextBaseline, spacing: 3) {
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

            Spacer(minLength: 0)
        }
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
