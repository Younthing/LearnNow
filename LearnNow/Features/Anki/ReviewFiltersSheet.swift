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

    @State private var showsAdvancedFilters = false

    var body: some View {
        GeometryReader { geometry in
            let horizontalPadding = LearnNowSpacing.screenHorizontal(for: geometry.size.width)

            ScrollView(showsIndicators: false) {
                ReviewFiltersContent(
                    model: model,
                    showsAdvancedFilters: $showsAdvancedFilters,
                    onReset: onReset,
                    onSelectTime: onSelectTime,
                    onToggleTopic: onToggleTopic,
                    onToggleModule: onToggleModule,
                    onSelectMastery: onSelectMastery,
                    onSelectFavorite: onSelectFavorite,
                    onToggleFavorite: onToggleFavorite,
                    onToggleMastered: onToggleMastered
                )
                .padding(.horizontal, horizontalPadding)
                .padding(.top, LearnNowSpacing.screenTop)
                .padding(.bottom, 24)
                .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                .frame(maxWidth: .infinity)
            }
            .accessibilityIdentifier("screen.review.filters")
            .safeAreaInset(edge: .bottom) {
                if model.resultCount > 0 {
                    ReviewFiltersFooter(
                        onApply: onApply
                    )
                    .padding(.horizontal, horizontalPadding)
                    .padding(.vertical, 8)
                    .frame(maxWidth: LearnNowSpacing.maximumContentWidth)
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                }
            }
        }
        .background(LearnNowPalette.canvas.ignoresSafeArea())
    }
}

// MARK: - Content

private struct ReviewFiltersContent: View {
    let model: ReviewFiltersSheetModel
    @Binding var showsAdvancedFilters: Bool
    let onReset: () -> Void
    let onSelectTime: (LearnNowReviewTimeFilter) -> Void
    let onToggleTopic: (String) -> Void
    let onToggleModule: (String) -> Void
    let onSelectMastery: (LearnNowReviewMasteryFilter) -> Void
    let onSelectFavorite: (LearnNowReviewFavoriteFilter) -> Void
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ReviewFiltersHeader(
                title: model.title,
                canReset: model.canReset,
                onReset: onReset
            )

            if model.emptyState != .noCards {
                filterControls
            }

            ReviewFiltersResultsSection(
                resultCount: model.resultCount,
                emptyState: model.emptyState,
                resultCards: model.resultCards,
                onReset: onReset,
                onToggleFavorite: onToggleFavorite,
                onToggleMastered: onToggleMastered
            )
        }
        .animation(.spring(response: 0.34, dampingFraction: 0.84), value: showsAdvancedFilters)
    }

    private var filterControls: some View {
        VStack(alignment: .leading, spacing: 12) {
            FlowLayout(items: model.timeOptions.map(SelectionChipItem.init)) { item in
                FilterChip(
                    title: item.title,
                    accent: .blue,
                    isSelected: item.isSelected,
                    accessibilityIdentifier: "review.filters.time.\(item.id)",
                    action: {
                        guard let filter = LearnNowReviewTimeFilter(rawValue: item.id) else { return }
                        onSelectTime(filter)
                    }
                )
            }

            AdvancedFiltersToggleControl(
                isExpanded: showsAdvancedFilters,
                activeCount: model.advancedFilterCount
            ) {
                withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                    showsAdvancedFilters.toggle()
                }
            }

            if showsAdvancedFilters {
                advancedFiltersSection
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }

    private var advancedFiltersSection: some View {
        SoftCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 20) {
                topicSection
                moduleSection
                masterySection
                favoriteSection
            }
        }
    }

    private var topicSection: some View {
        FilterSection(title: "主题") {
            FlowLayout(items: model.topicOptions) { option in
                FilterChip(
                    title: "\(option.title) \(option.count)",
                    accent: option.accent,
                    isSelected: option.isSelected,
                    accessibilityIdentifier: "review.filters.topic.\(option.id)",
                    action: { onToggleTopic(option.id) }
                )
            }
        }
    }

    private var moduleSection: some View {
        FilterSection(title: "课程模块") {
            FlowLayout(items: model.moduleOptions) { option in
                FilterChip(
                    title: "\(option.title) \(option.count)",
                    accent: option.accent,
                    isSelected: option.isSelected,
                    accessibilityIdentifier: "review.filters.module.\(option.id)",
                    action: { onToggleModule(option.id) }
                )
            }
        }
    }

    private var masterySection: some View {
        FilterSection(title: "掌握状态") {
            FlowLayout(items: model.masteryOptions.map(SelectionChipItem.init)) { item in
                FilterChip(
                    title: item.title,
                    accent: .mint,
                    isSelected: item.isSelected,
                    accessibilityIdentifier: "review.filters.mastery.\(item.id)",
                    action: {
                        guard let filter = LearnNowReviewMasteryFilter(rawValue: item.id) else { return }
                        onSelectMastery(filter)
                    }
                )
            }
        }
    }

    private var favoriteSection: some View {
        FilterSection(title: "收藏状态") {
            FlowLayout(items: model.favoriteOptions.map(SelectionChipItem.init)) { item in
                FilterChip(
                    title: item.title,
                    accent: .amber,
                    isSelected: item.isSelected,
                    accessibilityIdentifier: "review.filters.favorite.\(item.id)",
                    action: {
                        guard let filter = LearnNowReviewFavoriteFilter(rawValue: item.id) else { return }
                        onSelectFavorite(filter)
                    }
                )
            }
        }
    }
}

// MARK: - Sections

private struct ReviewFiltersHeader: View {
    let title: String
    let canReset: Bool
    let onReset: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            Text(title)
                .font(LearnNowTypography.sheetTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            Spacer(minLength: 0)

            if canReset {
                Button("重置", action: onReset)
                    .font(LearnNowTypography.label)
                    .foregroundStyle(LearnNowPalette.color(for: .amber))
                    .frame(minWidth: 44, minHeight: 44)
                    .contentShape(Rectangle())
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("review.filters.reset")
            }
        }
    }
}

private struct ReviewFiltersResultsSection: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let resultCount: Int
    let emptyState: ReviewFiltersSheetModel.EmptyState?
    let resultCards: [ReviewFiltersSheetModel.ResultCard]
    let onReset: () -> Void
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("共 \(resultCount) 张卡片")
                .font(LearnNowTypography.sectionTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)
                .accessibilityIdentifier("review.filters.result-count")

            if let emptyState {
                ReviewFiltersEmptyState(
                    state: emptyState,
                    onReset: onReset
                )
            } else {
                LazyVGrid(columns: columns, spacing: 14) {
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

    private var columns: [GridItem] {
        if horizontalSizeClass == .regular, !dynamicTypeSize.isAccessibilitySize {
            return [
                GridItem(
                    .adaptive(minimum: 320),
                    spacing: 14,
                    alignment: .top
                ),
            ]
        }

        return [GridItem(.flexible(), alignment: .top)]
    }
}

private struct ReviewFiltersEmptyState: View {
    let state: ReviewFiltersSheetModel.EmptyState
    let onReset: () -> Void

    var body: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Label(title, systemImage: systemImage)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.textPrimary)

                if state == .noMatches {
                    Button("清除筛选", action: onReset)
                        .font(LearnNowTypography.label)
                        .foregroundStyle(LearnNowPalette.color(for: .amber))
                        .frame(minHeight: 44)
                        .contentShape(Rectangle())
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("review.filters.empty.reset")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var title: String {
        switch state {
        case .noMatches:
            "没有符合条件的卡片"
        case .noCards:
            "卡池暂无卡片"
        }
    }

    private var systemImage: String {
        switch state {
        case .noMatches:
            "line.3.horizontal.decrease.circle"
        case .noCards:
            "rectangle.stack"
        }
    }
}

private struct ReviewFiltersFooter: View {
    let onApply: () -> Void

    var body: some View {
        FullWidthButton(
            title: "开始复习",
            accent: .blue,
            systemImage: "play.fill",
            action: onApply
        )
        .accessibilityIdentifier("review.filters.apply")
    }
}

// MARK: - Reusable Views

private struct FilterSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(LearnNowTypography.cardTitle)
                .foregroundStyle(LearnNowPalette.textPrimary)

            content
        }
    }
}

private struct FilterChip: View {
    let title: String
    let accent: LearnNowAccent
    let isSelected: Bool
    let accessibilityIdentifier: String
    let action: () -> Void

    var body: some View {
        MetadataChipButton(
            title: title,
            accent: accent,
            isSelected: isSelected,
            action: action
        )
        .accessibilityIdentifier(accessibilityIdentifier)
    }
}

private struct SelectionChipItem: Hashable {
    let id: String
    let title: String
    let isSelected: Bool

    nonisolated init(_ option: ReviewFiltersSheetModel.TimeOption) {
        id = option.filter.rawValue
        title = option.title
        isSelected = option.isSelected
    }

    nonisolated init(_ option: ReviewFiltersSheetModel.MasteryOption) {
        id = option.filter.rawValue
        title = option.title
        isSelected = option.isSelected
    }

    nonisolated init(_ option: ReviewFiltersSheetModel.FavoriteOption) {
        id = option.filter.rawValue
        title = option.title
        isSelected = option.isSelected
    }
}

private struct AdvancedFiltersToggleControl: View {
    let isExpanded: Bool
    let activeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")

                Text(isExpanded ? "收起筛选" : "更多筛选")

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(LearnNowTypography.metadata)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LearnNowPalette.color(for: .blue).opacity(0.14))
                        )
                        .accessibilityLabel("\(activeCount) 个高级筛选条件")
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.bold))
            }
            .font(LearnNowTypography.label)
            .foregroundStyle(
                activeCount > 0 || isExpanded
                    ? LearnNowPalette.color(for: .blue)
                    : LearnNowPalette.textMuted
            )
            .padding(.horizontal, 14)
            .frame(minHeight: 44)
            .background(
                Group {
                    if activeCount > 0 || isExpanded {
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
        .accessibilityIdentifier("review.filters.more")
        .accessibilityValue(isExpanded ? "已展开" : "已折叠")
    }
}

private struct ReviewCardPoolRow: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let card: ReviewFiltersSheetModel.ResultCard
    let onToggleFavorite: () -> Void
    let onToggleMastered: () -> Void

    var body: some View {
        SoftCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Text(card.frontTitle)
                    .font(LearnNowTypography.cardTitle)
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                Text(card.answerPreview)
                    .font(LearnNowTypography.body)
                    .foregroundStyle(LearnNowPalette.textSecondary)
                    .lineLimit(2)

                metadata

                if dynamicTypeSize.isAccessibilitySize {
                    VStack(spacing: 10) {
                        favoriteButton
                        masteredButton
                    }
                } else {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 10) {
                            favoriteButton
                            masteredButton
                        }

                        VStack(spacing: 10) {
                            favoriteButton
                            masteredButton
                        }
                    }
                }
            }
        }
    }

    private var metadata: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 12) {
                topicLabel
                moduleLabel
                Spacer(minLength: 0)
                dueLabel
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 12) {
                    topicLabel
                    Spacer(minLength: 0)
                    dueLabel
                }

                moduleLabel
            }
        }
        .font(LearnNowTypography.metadata)
    }

    private var topicLabel: some View {
        Label(card.topic, systemImage: "tag")
            .foregroundStyle(LearnNowPalette.color(for: card.topicAccent))
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
            .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
    }

    private var moduleLabel: some View {
        Label(card.moduleTitle, systemImage: "book.closed")
            .foregroundStyle(LearnNowPalette.textMuted)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
            .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
    }

    private var dueLabel: some View {
        Label(card.dueLabel, systemImage: "clock")
            .foregroundStyle(LearnNowPalette.textMuted)
            .lineLimit(dynamicTypeSize.isAccessibilitySize ? nil : 1)
            .fixedSize(horizontal: false, vertical: dynamicTypeSize.isAccessibilitySize)
    }

    private var favoriteButton: some View {
        ReviewStatusButton(
            title: card.isFavorited ? "已收藏" : "收藏",
            systemImage: card.isFavorited ? "bookmark.fill" : "bookmark",
            accent: .amber,
            isSelected: card.isFavorited,
            action: onToggleFavorite
        )
        .accessibilityIdentifier("review.pool.favorite.\(card.id)")
    }

    private var masteredButton: some View {
        ReviewStatusButton(
            title: card.isMastered ? "已掌握" : "标记掌握",
            systemImage: card.isMastered ? "checkmark.seal.fill" : "checkmark.seal",
            accent: .mint,
            isSelected: card.isMastered,
            action: onToggleMastered
        )
        .accessibilityIdentifier("review.pool.mastered.\(card.id)")
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
                .foregroundStyle(
                    isSelected
                        ? LearnNowPalette.color(for: accent)
                        : LearnNowPalette.textMuted
                )
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.horizontal, 12)
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
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

private extension ReviewFiltersSheetModel {
    var selectedTopicCount: Int {
        topicOptions.filter(\.isSelected).count
    }

    var selectedModuleCount: Int {
        moduleOptions.filter(\.isSelected).count
    }

    var advancedFilterCount: Int {
        selectedTopicCount +
        selectedModuleCount +
        (masteryOptions.contains { $0.isSelected && $0.filter != .all } ? 1 : 0) +
        (favoriteOptions.contains { $0.isSelected && $0.filter != .all } ? 1 : 0)
    }
}
