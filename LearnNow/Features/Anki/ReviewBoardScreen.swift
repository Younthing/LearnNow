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
                    ReviewRatingGrid(intervals: stage.ratingIntervals, onRate: onRate)
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
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(LearnNowTypography.screenTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)

            Button(action: onOpenFilters) {
                ZStack(alignment: .topTrailing) {
                    Circle()
                        .fill(LearnNowPalette.base)
                        .frame(width: 48, height: 48)
                        .modifier(OuterSurface(cornerRadius: 24))
                        .overlay {
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(
                                    activeFilterCount > 0
                                        ? LearnNowPalette.color(for: .blue)
                                        : LearnNowPalette.textMuted
                                )
                        }

                    if activeFilterCount > 0 {
                        Text("\(activeFilterCount)")
                            .font(LearnNowTypography.caption)
                            .fontWeight(.bold)
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
            .accessibilityIdentifier("anki.filters")
        }
    }
}

private struct ReviewSummaryPills: View {
    let summaries: [ReviewBoardModel.Summary]

    var body: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 100), spacing: 12)],
            spacing: 12
        ) {
            ForEach(summaries) { summary in
                MetadataChip(
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
                .font(LearnNowTypography.metadata)
                .fontWeight(.semibold)
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
                    .font(LearnNowTypography.label)
                    .foregroundStyle(
                        isFlipped
                            ? LearnNowPalette.color(for: .pink)
                            : LearnNowPalette.color(for: card.accent)
                    )
                    .textCase(.uppercase)

                if isFlipped {
                    VStack(spacing: 18) {
                        InlineContentText(content: card.backBody)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)

                        InsetCard(contentPadding: 16) {
                            InlineContentText(content: card.backHighlight)
                                .font(LearnNowTypography.cardTitle)
                                .foregroundStyle(LearnNowPalette.color(for: .pink))
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                        }
                    }
                } else {
                    Button(action: onFlip) {
                        VStack(spacing: 12) {
                            Text(card.frontTitle)
                                .font(LearnNowTypography.cardHeadline)
                                .foregroundStyle(LearnNowPalette.textPrimary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            if let frontSubtitle = card.frontSubtitle {
                                Text(frontSubtitle)
                                    .font(LearnNowTypography.body)
                                    .foregroundStyle(LearnNowPalette.textMuted)
                                    .multilineTextAlignment(.center)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            Label("点击卡片翻转", systemImage: "hand.tap")
                                .font(LearnNowTypography.metadata)
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
        .frame(minHeight: cardHeight)
    }
}

private struct ReviewRatingGrid: View {
    let intervals: [LearnNowReviewRating: String]
    let onRate: (LearnNowReviewRating) -> Void
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    private var columns: [GridItem] {
        Array(
            repeating: GridItem(.flexible(), spacing: 12),
            count: dynamicTypeSize.isAccessibilitySize ? 1 : 2
        )
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(LearnNowReviewRating.allCases) { rating in
                Button {
                    onRate(rating)
                } label: {
                    VStack(spacing: 4) {
                        Text(rating.title)
                            .font(LearnNowTypography.label)

                        Text(intervals[rating] ?? rating.interval)
                            .font(LearnNowTypography.caption)
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
                        .font(.title.weight(.bold))
                        .foregroundStyle(LearnNowPalette.color(for: state.hasActiveFilters ? .amber : .mint))
                }

                VStack(spacing: 8) {
                    Text(state.title)
                        .font(LearnNowTypography.cardHeadline)
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
