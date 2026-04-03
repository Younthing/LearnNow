import SwiftUI

struct ReviewFiltersSheet: View {
    let model: ReviewFiltersSheetModel
    let onReset: () -> Void
    let onSelectTime: (LearnNowReviewTimeFilter) -> Void
    let onToggleTopic: (String) -> Void
    let onToggleModule: (String) -> Void
    let onSelectMastery: (LearnNowReviewMasteryFilter) -> Void
    let onSelectFavorite: (LearnNowReviewFavoriteFilter) -> Void
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void
    let onApply: () -> Void

    var body: some View {
        ScrollView(showsIndicators: false) {
            ReviewFiltersContent(
                model: model,
                onReset: onReset,
                onSelectTime: onSelectTime,
                onToggleTopic: onToggleTopic,
                onToggleModule: onToggleModule,
                onSelectMastery: onSelectMastery,
                onSelectFavorite: onSelectFavorite,
                onToggleFavorite: onToggleFavorite,
                onToggleMastered: onToggleMastered
            )
        }
        .background(LearnNowPalette.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            ReviewFiltersFooter(
                countText: model.footerCountText,
                summary: model.footerSummary,
                applyButtonTitle: model.applyButtonTitle,
                canApply: model.canApply,
                onApply: onApply
            )
        }
    }
}

// MARK: - Content

private struct ReviewFiltersContent: View {
    let model: ReviewFiltersSheetModel
    let onReset: () -> Void
    let onSelectTime: (LearnNowReviewTimeFilter) -> Void
    let onToggleTopic: (String) -> Void
    let onToggleModule: (String) -> Void
    let onSelectMastery: (LearnNowReviewMasteryFilter) -> Void
    let onSelectFavorite: (LearnNowReviewFavoriteFilter) -> Void
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ReviewFiltersHeader(
                title: model.title,
                subtitle: model.subtitle,
                canReset: model.canReset,
                onReset: onReset
            )

            ReviewFiltersSummaryCard(
                stagedResultSummary: model.stagedResultSummary,
                activeFilterCount: model.activeFilterCount,
                summaryMessage: model.summaryMessage
            )

            timeSection
            topicSection
            moduleSection
            masterySection
            favoriteSection

            ReviewFiltersResultsSection(
                title: model.resultsTitle,
                emptyTitle: model.emptyResultsTitle,
                emptyMessage: model.emptyResultsMessage,
                resultCards: model.resultCards,
                onToggleFavorite: onToggleFavorite,
                onToggleMastered: onToggleMastered
            )
        }
        .padding(.horizontal, LearnNowSpacing.screenHorizontal)
        .padding(.top, LearnNowSpacing.screenTop)
        .padding(.bottom, 24)
    }

    private var timeSection: some View {
        FilterSection(title: "时间范围", subtitle: "用到期窗口切分本轮卡池") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(model.timeOptions) { option in
                        FilterChip(
                            title: option.title,
                            accent: .blue,
                            isSelected: option.isSelected,
                            action: { onSelectTime(option.filter) }
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var topicSection: some View {
        FilterSection(title: "主题", subtitle: "按知识点聚焦当前问题域") {
            FlowLayout(items: model.topicOptions) { option in
                FilterChip(
                    title: "\(option.title) \(option.count)",
                    accent: option.accent,
                    isSelected: option.isSelected,
                    action: { onToggleTopic(option.id) }
                )
            }
        }
    }

    private var moduleSection: some View {
        FilterSection(title: "课程模块", subtitle: "只看指定课程中的卡片") {
            FlowLayout(items: model.moduleOptions) { option in
                FilterChip(
                    title: "\(option.title) \(option.count)",
                    accent: option.accent,
                    isSelected: option.isSelected,
                    action: { onToggleModule(option.id) }
                )
            }
        }
    }

    private var masterySection: some View {
        FilterSection(title: "掌握状态", subtitle: "决定是否把熟悉卡片纳入这一轮") {
            HStack(spacing: 10) {
                ForEach(model.masteryOptions) { option in
                    FilterChip(
                        title: option.title,
                        accent: .mint,
                        isSelected: option.isSelected,
                        expands: true,
                        action: { onSelectMastery(option.filter) }
                    )
                }
            }
        }
    }

    private var favoriteSection: some View {
        FilterSection(title: "收藏状态", subtitle: "只保留你想重点回看的卡片") {
            HStack(spacing: 10) {
                ForEach(model.favoriteOptions) { option in
                    FilterChip(
                        title: option.title,
                        accent: .amber,
                        isSelected: option.isSelected,
                        expands: true,
                        action: { onSelectFavorite(option.filter) }
                    )
                }
            }
        }
    }
}

// MARK: - Sections

private struct ReviewFiltersHeader: View {
    let title: String
    let subtitle: String
    let canReset: Bool
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Text(subtitle)
                    .font(LearnNowTypography.screenSubtitle)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button("重置", action: onReset)
                .font(.system(size: 14, weight: .heavy, design: .rounded))
                .foregroundStyle(canReset ? LearnNowPalette.color(for: .amber) : LearnNowPalette.textMuted)
                .buttonStyle(.plain)
                .disabled(!canReset)
        }
    }
}

private struct ReviewFiltersSummaryCard: View {
    let stagedResultSummary: String
    let activeFilterCount: Int
    let summaryMessage: String

    var body: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(stagedResultSummary)
                        .font(LearnNowTypography.cardTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Spacer()

                    if activeFilterCount > 0 {
                        MetaCapsule(
                            text: "\(activeFilterCount) 个条件",
                            accent: .blue
                        )
                    }
                }

                Text(summaryMessage)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .lineSpacing(4)
            }
        }
    }
}

private struct ReviewFiltersResultsSection: View {
    let title: String
    let emptyTitle: String
    let emptyMessage: String
    let resultCards: [ReviewFiltersSheetModel.ResultCard]
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(LearnNowTypography.sectionTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            if resultCards.isEmpty {
                InsetCard(contentPadding: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(emptyTitle)
                            .font(LearnNowTypography.cardTitle)
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text(emptyMessage)
                            .font(LearnNowTypography.body)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(resultCards) { card in
                        ReviewCardPoolRow(
                            card: card,
                            onToggleFavorite: { onToggleFavorite(card.id) },
                            onToggleMastered: { onToggleMastered(card.id) }
                        )
                    }
                }
            }
        }
    }
}

private struct ReviewFiltersFooter: View {
    let countText: String
    let summary: String
    let applyButtonTitle: String
    let canApply: Bool
    let onApply: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Divider()
                .background(LearnNowPalette.shadowDark.opacity(0.3))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(countText)
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(summary)
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                FullWidthButton(
                    title: applyButtonTitle,
                    accent: canApply ? .blue : nil,
                    systemImage: canApply ? "play.fill" : nil,
                    action: onApply
                )
                .disabled(!canApply)
                .opacity(canApply ? 1 : 0.7)
            }
            .padding(.horizontal, LearnNowSpacing.screenHorizontal)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}

// MARK: - Reusable Views

private struct FilterSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Text(subtitle)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textMuted)
            }

            content
        }
    }
}

private struct FilterChip: View {
    let title: String
    let accent: LearnNowAccent
    let isSelected: Bool
    var expands = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 13, weight: .bold))
                }

                Text(title)
                    .font(LearnNowTypography.label)
                    .lineLimit(1)
            }
            .foregroundStyle(isSelected ? LearnNowPalette.color(for: accent) : LearnNowPalette.textMuted)
            .frame(maxWidth: expands ? .infinity : nil)
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
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
        .buttonStyle(.plain)
        .frame(minHeight: 44)
    }
}

private struct ReviewCardPoolRow: View {
    let card: ReviewFiltersSheetModel.ResultCard
    let onToggleFavorite: () -> Void
    let onToggleMastered: () -> Void

    var body: some View {
        SoftCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            MetaCapsule(text: card.topic, accent: card.topicAccent)
                            MetaCapsule(text: card.bucketTitle, accent: card.bucketAccent, subdued: true)
                        }

                        Text(card.frontTitle)
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(card.moduleTitle)
                            .font(LearnNowTypography.screenSubtitle)
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }

                    Spacer(minLength: 0)

                    Text(card.dueLabel)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.color(for: card.topicAccent))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LearnNowPalette.base)
                                .modifier(InsetSurface(cornerRadius: 999))
                        )
                }

                Text(card.highlight)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineSpacing(3)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    ReviewStatusButton(
                        title: card.isFavorited ? "已收藏" : "收藏",
                        systemImage: card.isFavorited ? "bookmark.fill" : "bookmark",
                        accent: .amber,
                        isSelected: card.isFavorited,
                        action: onToggleFavorite
                    )

                    ReviewStatusButton(
                        title: card.isMastered ? "已掌握" : "标记掌握",
                        systemImage: card.isMastered ? "checkmark.seal.fill" : "checkmark.seal",
                        accent: .mint,
                        isSelected: card.isMastered,
                        action: onToggleMastered
                    )
                }
            }
        }
    }
}

private struct ReviewStatusButton: View {
    let title: String
    let systemImage: String
    let accent: LearnNowAccent
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(LearnNowTypography.label)
                .foregroundStyle(isSelected ? LearnNowPalette.color(for: accent) : LearnNowPalette.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 12)
                .padding(.vertical, 14)
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
        .buttonStyle(.plain)
        .frame(minHeight: 48)
    }
}

private struct MetaCapsule: View {
    let text: String
    let accent: LearnNowAccent
    var subdued = false

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(subdued ? LearnNowPalette.textMuted : LearnNowPalette.color(for: accent))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: 999))
            )
    }
}
