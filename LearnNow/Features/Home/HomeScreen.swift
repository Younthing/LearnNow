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

            TodaySpotlightCard(
                badge: model.spotlightBadge,
                title: model.spotlightTitle,
                detail: model.spotlightBody
            )

            HeroProgressCard(
                sectionTitle: model.continueSectionTitle,
                badge: model.continueCard.badge,
                title: model.continueCard.title,
                progress: model.continueCard.progress,
                progressText: model.continueCard.progressText,
                accent: .blue,
                action: onContinueLearning
            )

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
            onContinueLearning: {}
        )
    }
}
