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

    @State private var showsAdvancedFilters: Bool

    init(
        model: ReviewFiltersSheetModel,
        onReset: @escaping () -> Void,
        onSelectTime: @escaping (LearnNowReviewTimeFilter) -> Void,
        onToggleTopic: @escaping (String) -> Void,
        onToggleModule: @escaping (String) -> Void,
        onSelectMastery: @escaping (LearnNowReviewMasteryFilter) -> Void,
        onSelectFavorite: @escaping (LearnNowReviewFavoriteFilter) -> Void,
        onToggleFavorite: @escaping (String) -> Void,
        onToggleMastered: @escaping (String) -> Void,
        onApply: @escaping () -> Void
    ) {
        self.model = model
        self.onReset = onReset
        self.onSelectTime = onSelectTime
        self.onToggleTopic = onToggleTopic
        self.onToggleModule = onToggleModule
        self.onSelectMastery = onSelectMastery
        self.onSelectFavorite = onSelectFavorite
        self.onToggleFavorite = onToggleFavorite
        self.onToggleMastered = onToggleMastered
        self.onApply = onApply
        _showsAdvancedFilters = State(initialValue: model.hasAdvancedSelections || model.resultCards.isEmpty)
    }

    var body: some View {
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
                summaryMessage: model.summaryMessage,
                activeFilterLabels: model.activeFilterLabels
            )

            quickFiltersSection

            if showsAdvancedFilters {
                advancedFiltersSection
                    .transition(.move(edge: .top).combined(with: .opacity))
            }

            ReviewFiltersResultsSection(
                title: model.resultsTitle,
                countText: model.footerCountText,
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
        .animation(.spring(response: 0.36, dampingFraction: 0.84), value: showsAdvancedFilters)
    }

    private var quickFiltersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("快速筛选")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text("先用时间范围快速收窄，再浏览下方卡池。")
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                Spacer(minLength: 0)

                AdvancedFiltersToggleControl(
                    isExpanded: showsAdvancedFilters,
                    activeCount: model.advancedFilterCount
                ) {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.82)) {
                        showsAdvancedFilters.toggle()
                    }
                }
            }

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

    private var advancedFiltersSection: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("高级筛选")
                        .font(.system(size: 18, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text("按主题、课程模块和卡片状态继续收窄范围，结果会即时刷新。")
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                topicSection
                moduleSection
                masterySection
                favoriteSection
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
    let activeFilterLabels: [String]

    var body: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("当前范围")
                            .font(.system(size: 12, weight: .black, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)

                        Text(stagedResultSummary)
                            .font(LearnNowTypography.cardHeadline)
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    if activeFilterCount > 0 {
                        MetaCapsule(
                            text: "\(activeFilterCount) 个条件",
                            accent: .blue
                        )
                    }
                }

                FlowLayout(items: activeFilterLabels) { label in
                    SummaryFilterChip(text: label)
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
    let countText: String
    let emptyTitle: String
    let emptyMessage: String
    let resultCards: [ReviewFiltersSheetModel.ResultCard]
    let onToggleFavorite: (String) -> Void
    let onToggleMastered: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(LearnNowTypography.sectionTitle)
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text("按当前条件实时刷新，默认按到期时间排序。")
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                Spacer(minLength: 0)

                SummaryFilterChip(text: countText)
            }

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

private struct AdvancedFiltersToggleControl: View {
    let isExpanded: Bool
    let activeCount: Int
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 13, weight: .bold))

                Text(isExpanded ? "收起高级" : "高级筛选")
                    .font(.system(size: 13, weight: .heavy, design: .rounded))

                if activeCount > 0 {
                    Text("\(activeCount)")
                        .font(.system(size: 11, weight: .black, design: .rounded))
                        .padding(.horizontal, 7)
                        .padding(.vertical, 3)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LearnNowPalette.color(for: .blue).opacity(0.14))
                        )
                }

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundStyle(
                activeCount > 0 || isExpanded
                    ? LearnNowPalette.color(for: .blue)
                    : LearnNowPalette.textMuted
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
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
    }
}

private struct SummaryFilterChip: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 12, weight: .black, design: .rounded))
            .foregroundStyle(LearnNowPalette.textSecondary)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule(style: .continuous)
                    .fill(LearnNowPalette.base)
                    .modifier(OuterSurface(cornerRadius: 999))
            )
    }
}

private struct ReviewCardPoolRow: View {
    let card: ReviewFiltersSheetModel.ResultCard
    let onToggleFavorite: () -> Void
    let onToggleMastered: () -> Void

    var body: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                Text(card.frontTitle)
                    .font(.system(size: 20, weight: .heavy, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(alignment: .top, spacing: 10) {
                    Text(card.moduleTitle)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .fixedSize(horizontal: false, vertical: true)

                    Spacer(minLength: 0)

                    Label(card.dueLabel, systemImage: "clock")
                        .font(LearnNowTypography.screenSubtitle)
                        .foregroundStyle(LearnNowPalette.color(for: card.topicAccent))
                }

                HStack(spacing: 8) {
                    MetaCapsule(text: card.topic, accent: card.topicAccent)
                    MetaCapsule(text: card.bucketTitle, accent: card.bucketAccent, subdued: true)
                }

                InsetCard(contentPadding: 14) {
                    Text(card.highlight)
                        .font(LearnNowTypography.body)
                        .foregroundStyle(LearnNowPalette.textSecondary)
                        .lineSpacing(3)
                        .fixedSize(horizontal: false, vertical: true)
                }

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

private extension ReviewFiltersSheetModel {
    var selectedTopicCount: Int {
        topicOptions.filter { $0.isSelected }.count
    }

    var selectedModuleCount: Int {
        moduleOptions.filter { $0.isSelected }.count
    }

    var selectedTimeTitle: String? {
        timeOptions.first { $0.isSelected && $0.filter != .all }?.title
    }

    var selectedMasteryTitle: String? {
        masteryOptions.first { $0.isSelected && $0.filter != .all }?.title
    }

    var selectedFavoriteTitle: String? {
        favoriteOptions.first { $0.isSelected && $0.filter != .all }?.title
    }

    var advancedFilterCount: Int {
        selectedTopicCount +
        selectedModuleCount +
        (selectedMasteryTitle == nil ? 0 : 1) +
        (selectedFavoriteTitle == nil ? 0 : 1)
    }

    var hasAdvancedSelections: Bool {
        advancedFilterCount > 0
    }

    var activeFilterLabels: [String] {
        var labels: [String] = []

        if let selectedTimeTitle {
            labels.append(selectedTimeTitle)
        }

        if selectedTopicCount > 0 {
            labels.append("\(selectedTopicCount) 个主题")
        }

        if selectedModuleCount > 0 {
            labels.append("\(selectedModuleCount) 个模块")
        }

        if let selectedMasteryTitle {
            labels.append(selectedMasteryTitle)
        }

        if let selectedFavoriteTitle {
            labels.append(selectedFavoriteTitle)
        }

        return labels.isEmpty ? ["全部卡池"] : labels
    }
}
