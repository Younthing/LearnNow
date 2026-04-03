import SwiftUI

struct ReviewBoardScreen: View {
    @Binding var flow: LearnNowFlowState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 22) {
                ReviewBoardHeader(activeFilterCount: flow.reviewFilterBadgeCount) {
                    flow.openReviewCardPool()
                }

                ReviewSummaryPills(summaryByBucket: flow.reviewSummaryByBucket)

                if let card = flow.currentReviewCard {
                    ReviewScopeCaption(
                        current: flow.currentReviewPosition,
                        total: flow.activeReviewCards.count,
                        title: flow.reviewScopeTitle,
                        subtitle: flow.reviewScopeSubtitle
                    )

                    ReviewFlashcardView(
                        card: card,
                        isFlipped: flow.isCurrentReviewCardFlipped
                    ) {
                        flow.flipCurrentReviewCard()
                    }
                    .accessibilityIdentifier("anki.card")

                    if flow.isCurrentReviewCardFlipped {
                        ReviewRatingGrid { rating in
                            flow.rateCurrentReviewCard(rating)
                        }
                    }
                } else {
                    ReviewEmptyStateCard(hasActiveFilters: flow.reviewFilterBadgeCount > 0) {
                        if flow.reviewFilterBadgeCount > 0 {
                            flow.appliedReviewFilters = .empty
                            flow.draftReviewFilters = .empty
                            flow.currentReviewCardIndex = 0
                        } else {
                            flow.selectTab(.home)
                        }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 40)
        }
        .sheet(
            isPresented: $flow.isReviewCardPoolPresented,
            onDismiss: { flow.dismissReviewCardPool() }
        ) {
            ReviewCardPoolSheet(flow: $flow)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .accessibilityIdentifier("screen.anki")
    }
}

private struct ReviewBoardHeader: View {
    let activeFilterCount: Int
    let onOpenFilters: () -> Void

    var body: some View {
        ZStack {
            Text("复习卡片")
                .font(.system(size: 30, weight: .black, design: .rounded))
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
    let summaryByBucket: [LearnNowReviewBucket: Int]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(LearnNowReviewBucket.allCases) { bucket in
                NeumorphicPill(
                    text: "\(bucket.title) \(summaryByBucket[bucket, default: 0])",
                    accent: bucket.accent,
                    isExpanded: true
                )
            }
        }
    }
}

private struct ReviewScopeCaption: View {
    let current: Int
    let total: Int
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 6) {
            Text("第 \(current) / \(total) 张")
                .font(.system(size: 13, weight: .black, design: .rounded))
                .foregroundStyle(LearnNowPalette.textSecondary)

            Text(title == "全卡池复习" ? subtitle : title)
                .font(.system(size: 12, weight: .bold, design: .rounded))
                .foregroundStyle(LearnNowPalette.textMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct ReviewFlashcardView: View {
    let card: LearnNowReviewCard
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
    let hasActiveFilters: Bool
    let action: () -> Void

    var body: some View {
        SoftCard(contentPadding: 24) {
            VStack(spacing: 18) {
                InsetCircle(size: 72) {
                    Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle" : "checkmark.circle")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(LearnNowPalette.color(for: hasActiveFilters ? .amber : .mint))
                }

                VStack(spacing: 8) {
                    Text(hasActiveFilters ? "当前筛选下暂无卡片" : "今日复习已完成")
                        .font(.system(size: 24, weight: .black, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)
                        .multilineTextAlignment(.center)

                    Text(hasActiveFilters ? "可以清空筛选条件，回到全卡池继续复习。" : "今天的复习范围已经处理完成，可以回到概览继续学习。")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                FullWidthButton(
                    title: hasActiveFilters ? "清除筛选" : "返回概览",
                    accent: hasActiveFilters ? .amber : .blue,
                    systemImage: hasActiveFilters ? "line.3.horizontal.decrease.circle" : "house.fill",
                    action: action
                )
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct ReviewCardPoolSheet: View {
    @Binding var flow: LearnNowFlowState

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                header
                summaryCard
                timeSection
                topicSection
                moduleSection
                masterySection
                favoriteSection
                resultsSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            .padding(.bottom, 24)
        }
        .background(LearnNowPalette.canvas.ignoresSafeArea())
        .safeAreaInset(edge: .bottom) {
            footer
        }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text("卡池浏览")
                    .font(.system(size: 28, weight: .black, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textPrimary)

                Text("按主题、时间与模块收窄范围，再开始这一轮复习。")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button("重置") {
                flow.resetDraftReviewFilters()
            }
            .font(.system(size: 14, weight: .heavy, design: .rounded))
            .foregroundStyle(flow.stagedFilterBadgeCount > 0 ? LearnNowPalette.color(for: .amber) : LearnNowPalette.textMuted)
            .buttonStyle(.plain)
            .disabled(flow.stagedFilterBadgeCount == 0)
        }
    }

    private var summaryCard: some View {
        SoftCard(contentPadding: 18) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(flow.stagedResultSummary)
                        .font(.system(size: 17, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Spacer()

                    if flow.stagedFilterBadgeCount > 0 {
                        MetaCapsule(text: "\(flow.stagedFilterBadgeCount) 个条件", accent: .blue)
                    }
                }

                Text(flow.draftReviewFilters.isDefault ? "未启用筛选时，将按全部卡池的默认顺序开始复习。" : "筛选只在你点击主按钮后生效；直接关闭不会改动当前复习队列。")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(LearnNowPalette.textMuted)
                    .lineSpacing(4)
            }
        }
    }

    private var timeSection: some View {
        FilterSection(title: "时间范围", subtitle: "用到期窗口切分本轮卡池") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(LearnNowReviewTimeFilter.allCases) { filter in
                        FilterChip(
                            title: filter.title,
                            accent: .blue,
                            isSelected: flow.draftReviewFilters.time == filter
                        ) {
                            flow.setDraftTimeFilter(filter)
                        }
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var topicSection: some View {
        FilterSection(title: "主题", subtitle: "按知识点聚焦当前问题域") {
            FlowLayout(items: flow.reviewTopicFacets) { facet in
                FilterChip(
                    title: "\(facet.title) \(facet.count)",
                    accent: facet.accent,
                    isSelected: flow.draftReviewFilters.topics.contains(facet.id)
                ) {
                    flow.toggleDraftTopic(facet.id)
                }
            }
        }
    }

    private var moduleSection: some View {
        FilterSection(title: "课程模块", subtitle: "只看指定课程中的卡片") {
            FlowLayout(items: flow.reviewModuleFacets) { facet in
                FilterChip(
                    title: "\(facet.title) \(facet.count)",
                    accent: facet.accent,
                    isSelected: flow.draftReviewFilters.moduleIDs.contains(facet.id)
                ) {
                    flow.toggleDraftModule(facet.id)
                }
            }
        }
    }

    private var masterySection: some View {
        FilterSection(title: "掌握状态", subtitle: "决定是否把熟悉卡片纳入这一轮") {
            HStack(spacing: 10) {
                ForEach(LearnNowReviewMasteryFilter.allCases) { filter in
                    FilterChip(
                        title: filter.title,
                        accent: .mint,
                        isSelected: flow.draftReviewFilters.mastery == filter,
                        expands: true
                    ) {
                        flow.setDraftMasteryFilter(filter)
                    }
                }
            }
        }
    }

    private var favoriteSection: some View {
        FilterSection(title: "收藏状态", subtitle: "只保留你想重点回看的卡片") {
            HStack(spacing: 10) {
                ForEach(LearnNowReviewFavoriteFilter.allCases) { filter in
                    FilterChip(
                        title: filter.title,
                        accent: .amber,
                        isSelected: flow.draftReviewFilters.favorite == filter,
                        expands: true
                    ) {
                        flow.setDraftFavoriteFilter(filter)
                    }
                }
            }
        }
    }

    private var resultsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("筛选结果")
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .foregroundStyle(LearnNowPalette.textPrimary)

            if flow.stagedReviewCards.isEmpty {
                InsetCard(contentPadding: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("当前筛选下暂无卡片")
                            .font(.system(size: 16, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)

                        Text("可以放宽时间窗口，或取消主题 / 模块限制。")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }
                }
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(flow.stagedReviewCards) { card in
                        ReviewCardPoolRow(
                            card: card,
                            onToggleFavorite: { flow.toggleReviewCardFavorited(id: card.id) },
                            onToggleMastered: { flow.toggleReviewCardMastered(id: card.id) }
                        )
                    }
                }
            }
        }
    }

    private var footer: some View {
        VStack(spacing: 12) {
            Divider()
                .background(LearnNowPalette.shadowDark.opacity(0.3))

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(flow.stagedReviewCards.isEmpty ? "暂无结果" : "\(flow.stagedReviewCards.count) 张卡片")
                        .font(.system(size: 16, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textPrimary)

                    Text(flow.draftReviewFilters.isDefault ? "将从全部卡池开始" : "仅应用到本轮复习")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(LearnNowPalette.textMuted)
                }

                FullWidthButton(
                    title: flow.applyFiltersCTA,
                    accent: flow.stagedReviewCards.isEmpty ? nil : .blue,
                    systemImage: flow.stagedReviewCards.isEmpty ? nil : "play.fill"
                ) {
                    flow.applyReviewCardPoolFilters()
                }
                .disabled(flow.stagedReviewCards.isEmpty)
                .opacity(flow.stagedReviewCards.isEmpty ? 0.7 : 1)
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 8)
        }
        .background(.ultraThinMaterial)
    }
}

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
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
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
                    .font(.system(size: 13, weight: .heavy, design: .rounded))
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
    let card: LearnNowReviewCard
    let onToggleFavorite: () -> Void
    let onToggleMastered: () -> Void

    var body: some View {
        SoftCard(contentPadding: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(alignment: .top, spacing: 10) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            MetaCapsule(text: card.topic, accent: card.accent)
                            MetaCapsule(text: card.bucket.title, accent: card.bucket.accent, subdued: true)
                        }

                        Text(card.frontTitle)
                            .font(.system(size: 19, weight: .heavy, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textPrimary)
                            .fixedSize(horizontal: false, vertical: true)

                        Text(card.moduleTitle)
                            .font(.system(size: 13, weight: .bold, design: .rounded))
                            .foregroundStyle(LearnNowPalette.textMuted)
                    }

                    Spacer(minLength: 0)

                    Text(LearnNowFlowState.dueLabel(for: card.dueAt))
                        .font(.system(size: 12, weight: .heavy, design: .rounded))
                        .foregroundStyle(LearnNowPalette.color(for: card.accent))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .background(
                            Capsule(style: .continuous)
                                .fill(LearnNowPalette.base)
                                .modifier(InsetSurface(cornerRadius: 999))
                        )
                }

                Text(card.backHighlight)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
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
                .font(.system(size: 13, weight: .heavy, design: .rounded))
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

#Preview("Anki") {
    ReviewBoardScreenPreviewContainer()
}

private struct ReviewBoardScreenPreviewContainer: View {
    @State private var flow = LearnNowFlowState.reviewBoardPreview

    var body: some View {
        ZStack {
            LearnNowPalette.canvas.ignoresSafeArea()
            ReviewBoardScreen(flow: $flow)
        }
    }
}
