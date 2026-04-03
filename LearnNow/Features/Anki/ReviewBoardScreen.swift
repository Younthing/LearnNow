import SwiftUI

struct ReviewBoardScreen: View {
    let model: ReviewBoardModel
    let onOpenFilters: () -> Void
    let onFlipCard: () -> Void
    let onRate: (LearnNowReviewRating) -> Void
    let onEmptyAction: () -> Void

    var body: some View {
        ScreenScaffold(spacing: 22) {
            ReviewBoardHeader(
                title: model.title,
                activeFilterCount: model.activeFilterCount,
                onOpenFilters: onOpenFilters
            )

            ReviewSummaryPills(summaries: model.summaries)

            ReviewBoardStage(
                stage: model.stage,
                onFlipCard: onFlipCard,
                onRate: onRate,
                onEmptyAction: onEmptyAction
            )
        }
        .accessibilityIdentifier("screen.anki")
    }
}

private struct ReviewBoardStage: View {
    let stage: ReviewBoardModel.Stage
    let onFlipCard: () -> Void
    let onRate: (LearnNowReviewRating) -> Void
    let onEmptyAction: () -> Void

    var body: some View {
        switch stage {
        case .card(let stage):
            VStack(spacing: 22) {
                ReviewScopeCaption(scope: stage.scope)

                ReviewFlashcardView(
                    card: stage.card,
                    isFlipped: stage.isFlipped,
                    onFlip: onFlipCard
                )
                .accessibilityIdentifier("anki.card")

                if stage.showsRatingGrid {
                    ReviewRatingGrid(onRate: onRate)
                }
            }
        case .empty(let state):
            ReviewEmptyStateCard(
                state: state,
                action: onEmptyAction
            )
        }
    }
}

private struct ReviewBoardHeader: View {
    let title: String
    let activeFilterCount: Int
    let onOpenFilters: () -> Void

    var body: some View {
        ZStack {
            Text(title)
                .font(LearnNowTypography.screenTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            HStack {
                Spacer()

                Button(action: onOpenFilters) {
                    ZStack(alignment: .topTrailing) {
                        Circle()
                            .fill(LearnNowPalette.base)
                            .frame(width: 48, height: 48)
                            .modifier(OuterSurface(cornerRadius: 24))
                            .overlay {
                                Image(systemName: "line.3.horizontal.decrease.circle")
                                    .font(.system(size: 19, weight: .bold))
                                    .foregroundStyle(
                                        activeFilterCount > 0
                                            ? LearnNowPalette.color(for: .blue)
                                            : LearnNowPalette.textMuted
                                    )
                            }

                        if activeFilterCount > 0 {
                            Text("\(activeFilterCount)")
                                .font(.system(size: 11, weight: .black, design: .rounded))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 7)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule(style: .continuous)
                                        .fill(LearnNowPalette.color(for: .pink))
                                )
                                .offset(x: 8, y: -4)
                        }
                    }
                }
                .buttonStyle(.plain)
                .accessibilityLabel(activeFilterCount > 0 ? "打开筛选，当前有 \(activeFilterCount) 个条件" : "打开筛选")
            }
        }
    }
}

private struct ReviewSummaryPills: View {
    let summaries: [ReviewBoardModel.Summary]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(summaries) { summary in
                NeumorphicPill(
                    text: "\(summary.bucket.title) \(summary.count)",
                    accent: summary.bucket.accent,
                    isExpanded: true
                )
            }
        }
    }
}

private struct ReviewScopeCaption: View {
    let scope: ReviewBoardModel.Scope

    var body: some View {
        VStack(spacing: 6) {
            Text("第 \(scope.current) / \(scope.total) 张")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LearnNowPalette.textSecondary)

            Text(scope.title == "全卡池复习" ? scope.subtitle : scope.title)
                .font(LearnNowTypography.screenSubtitle)
                .foregroundStyle(LearnNowPalette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ReviewFlashcardView: View {
    let card: ReviewBoardModel.Card
    let isFlipped: Bool
    let onFlip: () -> Void

    @ScaledMetric(relativeTo: .title) private var cardHeight: CGFloat = 340

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(LearnNowPalette.base)
                .softOuter(radius: 16, x: 8, y: 8)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    LearnNowPalette.color(for: card.accent).opacity(0.08),
                                    .clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.8
                        )
                )

            VStack(spacing: 20) {
                Text(isFlipped ? card.backTitle : card.topic)
                    .font(.system(size: 13, weight: .black, design: .rounded))
                    .foregroundStyle(
                        isFlipped
                            ? LearnNowPalette.color(for: .pink)
                            : LearnNowPalette.color(for: card.accent)
                    )
                    .textCase(.uppercase)

                if isFlipped {
                    VStack(spacing: 18) {
                        Text(card.backBody)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        InsetCard(contentPadding: 16) {
                            Text(card.backHighlight)
                                .font(.system(size: 15, weight: .heavy, design: .rounded))
                                .foregroundStyle(LearnNowPalette.color(for: .pink))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    Button(action: onFlip) {
                        VStack(spacing: 12) {
                            Text(card.frontTitle)
                                .font(.system(size: 34, weight: .black, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            if let frontSubtitle = card.frontSubtitle {
                                Text(frontSubtitle)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                    .foregroundStyle(LearnNowPalette.textMuted)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Label("点击卡片翻转", systemImage: "hand.tap")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundStyle(LearnNowPalette.textMuted)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("双击翻转卡片查看答案与评分")
                }
            }
            .padding(.horizontal, 26)
        }
        .frame(height: cardHeight)
    }
}

private struct ReviewRatingGrid: View {
    let onRate: (LearnNowReviewRating) -> Void

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(LearnNowReviewRating.allCases) { rating in
                Button {
                    onRate(rating)
                } label: {
                    VStack(spacing: 4) {
                        Text(rating.title)
                            .font(.system(size: 14, weight: .heavy, design: .rounded))

                        Text(rating.interval)
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                    }
                    .foregroundStyle(LearnNowPalette.color(for: rating.accent))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                .buttonStyle(SoftPressStyle(cornerRadius: 18))
                .accessibilityIdentifier("anki.rate.\(rating.rawValue)")
            }
        }
    }
}

private struct ReviewEmptyStateCard: View {
    let state: ReviewBoardModel.EmptyState
    let action: () -> Void

    var body: some View {
        SoftCard(contentPadding: 24) {
            VStack(spacing: 18) {
                InsetCircle(size: 72) {
                    Image(systemName: state.hasActiveFilters ? "line.3.horizontal.decrease.circle" : "checkmark.circle")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: state.hasActiveFilters ? .amber : .mint))
                }

                VStack(spacing: 8) {
                    Text(state.title)
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(state.message)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                FullWidthButton(
                    title: state.actionTitle,
                    accent: state.actionAccent,
                    systemImage: state.actionSystemImage,
                    action: action
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview("Anki") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ReviewBoardScreen(
            model: LearnNowFlowState.reviewBoardPreview.reviewBoardModel,
            onOpenFilters: {},
            onFlipCard: {},
            onRate: { _ in },
            onEmptyAction: {}
        )
    }
}

#Preview("Anki Empty") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ReviewBoardScreen(
            model: LearnNowFlowState.reviewBoardEmptyPreview.reviewBoardModel,
            onOpenFilters: {},
            onFlipCard: {},
            onRate: { _ in },
            onEmptyAction: {}
        )
    }
}

#Preview("Anki Filtered") {
    ZStack {
        LearnNowPalette.canvas.ignoresSafeArea()
        ReviewBoardScreen(
            model: LearnNowFlowState.reviewBoardFilteredPreview.reviewBoardModel,
            onOpenFilters: {},
            onFlipCard: {},
            onRate: { _ in },
            onEmptyAction: {}
        )
    }
}
