import SwiftUI

struct HomeScreen: View {
    let model: HomeScreenModel
    let onContinueLearning: () -> Void

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: model.title,
                subtitle: model.subtitle,
                trailing: { AvatarBadge() }
            )

            HomeHeroCard(
                totalXPText: model.totalXPText,
                streakDays: model.streakDays
            )

            MetricGridSection(items: model.metrics) { metric in
                HomeMetricCard(metric: metric)
            }

            SectionHeader(title: model.continueSectionTitle)

            HeroProgressCard(
                badge: model.continueCard.badge,
                title: model.continueCard.title,
                progress: model.continueCard.progress,
                progressText: model.continueCard.progressText,
                accent: .blue,
                action: onContinueLearning
            )

            InsightCard(
                title: model.studyRecordTitle,
                accessory: {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(LearnNowPalette.textMuted)
                }
            ) {
                HeatmapGrid(cells: model.heatmap)
            }
        }
        .accessibilityIdentifier("screen.home")
    }
}

private struct HomeHeroCard: View {
    let totalXPText: String
    let streakDays: Int

    var body: some View {
        SoftCard {
            HStack(alignment: .center, spacing: 18) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("绝佳状态")
                        .font(LearnNowTypography.cardHeadline)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(totalXPText)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                Spacer()

                InsetCircle(size: 72) {
                    VStack(spacing: 2) {
                        Text("\(streakDays)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundStyle(LearnNowPalette.color(for: .pink))

                        Text("天连胜")
                            .font(.system(size: 10, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
        }
    }
}

private struct HomeMetricCard: View {
    let metric: LearnNowHeaderMetric

    var body: some View {
        InsetCard {
            VStack(spacing: 10) {
                Text(metric.title)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(metric.value)
                        .font(LearnNowTypography.metricValue)
                        .foregroundStyle(LearnNowPalette.color(for: metric.accent))

                    if let unit = metric.unit {
                        Text(unit)
                            .font(LearnNowTypography.metricUnit)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
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

private struct HeatmapGrid: View {
    let cells: [LearnNowHeatCell]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 8) {
            ForEach(cells) { cell in
                Group {
                    if cell.level == 0 {
                        Circle()
                            .fill(fillColor(for: cell.level))
                            .modifier(OuterSurface(cornerRadius: 11))
                    } else {
                        Circle()
                            .fill(fillColor(for: cell.level))
                            .modifier(InsetSurface(cornerRadius: 11))
                    }
                }
                .frame(height: 22)
                .opacity(cell.level == nil ? 0 : 1)
            }
        }
    }

    private func fillColor(for level: Int?) -> Color {
        switch level {
        case nil:
            .clear
        case 0:
            LearnNowPalette.base
        case 1:
            LearnNowPalette.color(for: .mint)
        case 2:
            LearnNowPalette.color(for: .blue)
        default:
            LearnNowPalette.color(for: .pink)
        }
    }
}

#Preview("Home") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(model: LearnNowFlowState.homePreview.homeScreenModel, onContinueLearning: {})
    }
}
