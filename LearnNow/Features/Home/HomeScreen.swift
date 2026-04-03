import SwiftUI

struct HomeScreen: View {
    let model: HomeScreenModel
    let onContinueLearning: () -> Void
    let onOpenReviewBoard: () -> Void
    let onOpenRoutes: () -> Void
    let onOpenFavorites: () -> Void
    let onOpenProfile: () -> Void

    var body: some View {
        ScreenScaffold {
            ScreenHeader(
                title: model.title,
                subtitle: model.subtitle,
                trailing: { AvatarBadge() }
            )

            TodaySpotlightCard(
                badge: model.spotlightBadge,
                title: model.spotlightTitle,
                detail: model.spotlightBody
            )

            SectionHeader(title: model.continueSectionTitle)

            HeroProgressCard(
                badge: model.continueCard.badge,
                title: model.continueCard.title,
                progress: model.continueCard.progress,
                progressText: model.continueCard.progressText,
                accent: .blue,
                action: onContinueLearning
            )

            SectionHeader(title: model.quickActionSectionTitle)

            MetricGridSection(items: model.quickActions) { action in
                HomeQuickActionCard(action: action) {
                    handleQuickAction(action.id)
                }
            }

            InsightCard(title: model.rhythmTitle) {
                VStack(spacing: 14) {
                    ForEach(Array(model.rhythmItems.enumerated()), id: \.element.id) { index, item in
                        HomeRhythmRow(item: item)

                        if index < model.rhythmItems.count - 1 {
                            Divider()
                                .overlay(LearnNowPalette.shadowDark.opacity(0.18))
                        }
                    }
                }
            }
        }
        .accessibilityIdentifier("screen.home")
    }

    private func handleQuickAction(_ id: String) {
        switch id {
        case "review":
            onOpenReviewBoard()
        case "routes":
            onOpenRoutes()
        case "favorites":
            onOpenFavorites()
        case "profile":
            onOpenProfile()
        default:
            break
        }
    }
}

private struct TodaySpotlightCard: View {
    let badge: String
    let title: String
    let detail: String

    var body: some View {
        SoftCard {
            HStack(alignment: .top, spacing: 18) {
                VStack(alignment: .leading, spacing: 12) {
                    NeumorphicPill(text: badge, accent: .amber)

                    Text(title)
                        .font(LearnNowTypography.cardHeadline)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(detail)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                InsetCircle(size: 72) {
                    Image(systemName: "target")
                        .font(.system(size: 26, weight: .black))
                        .foregroundStyle(LearnNowPalette.color(for: .amber))
                }
            }
        }
    }
}

private struct HomeQuickActionCard: View {
    let action: HomeScreenModel.QuickAction
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            InsetCard {
                VStack(alignment: .leading, spacing: 14) {
                    HStack(alignment: .center) {
                        Image(systemName: action.systemImage)
                            .font(.system(size: 16, weight: .black))
                            .foregroundStyle(LearnNowPalette.color(for: action.accent))

                        Spacer()

                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }

                    Text(action.title)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)

                    Text(action.value)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)

                    Text(action.subtitle)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .buttonStyle(.plain)
    }
}

private struct HomeRhythmRow: View {
    let item: HomeScreenModel.RhythmItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(LearnNowPalette.base)
                    .frame(width: 40, height: 40)
                    .modifier(InsetSurface(cornerRadius: 20))

                Image(systemName: item.systemImage)
                    .font(.system(size: 14, weight: .black))
                    .foregroundStyle(LearnNowPalette.color(for: item.accent))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)

                Text(item.value)
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)
            }

            Spacer()
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

#Preview("Home") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        HomeScreen(
            model: LearnNowFlowState.homePreview.homeScreenModel,
            onContinueLearning: {},
            onOpenReviewBoard: {},
            onOpenRoutes: {},
            onOpenFavorites: {},
            onOpenProfile: {}
        )
    }
}
