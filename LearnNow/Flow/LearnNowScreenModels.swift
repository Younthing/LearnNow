import Foundation

struct HomeScreenModel: Equatable {
    struct ContinueCard: Equatable {
        let badge: String
        let title: String
        let progress: Double
        let progressText: String
    }

    struct TodayStatusMetric: Identifiable, Equatable {
        let id: String
        let title: String
        let value: String
        let unit: String?
        let systemImage: String
        let accent: LearnNowAccent
    }

    struct KnowledgeTip: Equatable {
        let title: String
        let body: String
        let systemImage: String
        let accent: LearnNowAccent
    }

    let title: String
    let subtitle: String
    let todayStatusTitle: String
    let statusMetrics: [TodayStatusMetric]
    let continueSectionTitle: String
    let continueCard: ContinueCard
    let tipSectionTitle: String
    let knowledgeTip: KnowledgeTip
}

struct RoutesOverviewModel: Equatable {
    let title: String
    let subtitle: String
    let routes: [LearnNowRoute]
}

struct PathScreenModel: Equatable {
    struct TrackTab: Identifiable, Equatable {
        let track: LearnNowRouteTrack
        let title: String
        let isSelected: Bool

        var id: LearnNowRouteTrack { track }
    }

    struct Node: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String
        let status: LearnNowPathNode.Status
        let isInteractive: Bool
        let progress: Double?
    }

    let title: String
    let subtitle: String
    let trackTabs: [TrackTab]
    let selectedTrackTitle: String
    let selectedTrackSummary: String
    let nodes: [Node]
    let emptyStateTitle: String?
    let emptyStateMessage: String?
}

struct LessonScreenModel: Equatable {
    struct Callout: Equatable {
        let title: String
        let message: String
        let accent: LearnNowAccent
    }

    struct Option: Identifiable, Equatable {
        enum Presentation: Equatable {
            case normal
            case correct
            case incorrect
        }

        let id: String
        let badge: String
        let title: String
        let presentation: Presentation
        let isEnabled: Bool
    }

    struct CallToAction: Equatable {
        let kind: LearnNowLessonCallToAction
        let title: String
        let accent: LearnNowAccent?
    }

    struct Page: Identifiable, Equatable {
        let id: String
        let badge: String
        let accent: LearnNowAccent
        let title: String
        let summary: String
        let callout: Callout
        let codeSample: String?
        let questionPrompt: String
        let options: [Option]
        let feedback: LearnNowLessonFeedback?
        let callToAction: CallToAction?
    }

    let title: String
    let currentPageIndex: Int
    let pageCount: Int
    let pages: [Page]
}

struct CompletionScreenModel: Equatable {
    let title: String
    let streakDays: Int
    let gainedXPText: String
    let reviewCount: Int
    let reviewTags: [String]
    let reviewMessage: String
    let nextLessonTitle: String?
    let showsReviewAction: Bool
}

struct ReviewBoardModel: Equatable {
    struct Summary: Identifiable, Equatable {
        let bucket: LearnNowReviewBucket
        let count: Int

        var id: LearnNowReviewBucket { bucket }
    }

    struct Scope: Equatable {
        let current: Int
        let total: Int
        let title: String
        let subtitle: String
    }

    struct Card: Identifiable, Equatable {
        let id: String
        let topic: String
        let accent: LearnNowAccent
        let frontTitle: String
        let frontSubtitle: String?
        let backTitle: String
        let backBody: String
        let backHighlight: String
    }

    struct CardStage: Equatable {
        let scope: Scope
        let card: Card
        let isFlipped: Bool
        let showsRatingGrid: Bool
    }

    struct EmptyState: Equatable {
        let hasActiveFilters: Bool
        let title: String
        let message: String
        let actionTitle: String
        let actionAccent: LearnNowAccent
        let actionSystemImage: String
    }

    enum Stage: Equatable {
        case card(CardStage)
        case empty(EmptyState)
    }

    let title: String
    let activeFilterCount: Int
    let summaries: [Summary]
    let stage: Stage
}

struct ReviewFiltersSheetModel: Equatable {
    struct TimeOption: Identifiable, Equatable {
        let filter: LearnNowReviewTimeFilter
        let title: String
        let isSelected: Bool

        var id: LearnNowReviewTimeFilter { filter }
    }

    struct MasteryOption: Identifiable, Equatable {
        let filter: LearnNowReviewMasteryFilter
        let title: String
        let isSelected: Bool

        var id: LearnNowReviewMasteryFilter { filter }
    }

    struct FavoriteOption: Identifiable, Equatable {
        let filter: LearnNowReviewFavoriteFilter
        let title: String
        let isSelected: Bool

        var id: LearnNowReviewFavoriteFilter { filter }
    }

    struct FacetOption: Identifiable, Equatable, Hashable {
        let id: String
        let title: String
        let accent: LearnNowAccent
        let count: Int
        let isSelected: Bool
    }

    struct ResultCard: Identifiable, Equatable {
        let id: String
        let topic: String
        let topicAccent: LearnNowAccent
        let bucketTitle: String
        let bucketAccent: LearnNowAccent
        let frontTitle: String
        let moduleTitle: String
        let dueLabel: String
        let highlight: String
        let isFavorited: Bool
        let isMastered: Bool
    }

    let title: String
    let subtitle: String
    let stagedResultSummary: String
    let activeFilterCount: Int
    let summaryMessage: String
    let canReset: Bool
    let timeOptions: [TimeOption]
    let topicOptions: [FacetOption]
    let moduleOptions: [FacetOption]
    let masteryOptions: [MasteryOption]
    let favoriteOptions: [FavoriteOption]
    let resultsTitle: String
    let emptyResultsTitle: String
    let emptyResultsMessage: String
    let resultCards: [ResultCard]
    let footerCountText: String
    let footerSummary: String
    let applyButtonTitle: String
    let canApply: Bool
}

struct ProfileScreenModel: Equatable {
    struct OverviewCTA: Equatable {
        let badge: String
        let title: String
        let subtitle: String
        let progress: Double
        let progressText: String
        let xpText: String
        let heatmap: [LearnNowHeatCell]
        let metrics: [LearnNowHeaderMetric]
    }

    struct FavoriteSummary: Equatable {
        let countText: String
        let masteredText: String
        let highlights: [LearnNowProfileFavoriteHighlight]
        let actionTitle: String
    }

    let title: String
    let subtitle: String
    let profileName: String
    let profileHeadline: String
    let profileLevel: String
    let overviewCTA: OverviewCTA
    let favoritesTitle: String
    let favoritesSubtitle: String
    let favoriteSummary: FavoriteSummary
    let retentionTitle: String
    let primarySeries: [Double]
    let baselineSeries: [Double]
    let knowledgeTitle: String
    let knowledgeMetrics: [LearnNowKnowledgeMetric]
    let settingsTitle: String
    let settingsSubtitle: String
    let reminderTitle: String
    let reminderSubtitle: String
    let reminderTimeText: String
    let remindersEnabled: Bool
    let appearanceTitle: String
    let appearanceSubtitle: String
    let isNightModeEnabled: Bool
}

extension LearnNowFlowState {
    var homeScreenModel: HomeScreenModel {
        let safePageIndex = min(currentLessonPageIndex, max(lessonPages.count - 1, 0))
        let currentPage = lessonPages.indices.contains(safePageIndex) ? lessonPages[safePageIndex] : nil
        let currentLessonBadge = "第\(loadedLessonModuleIndex + 1)单元 · 课时\(safePageIndex + 1)"
        let currentLessonTitle = currentPage?.title ?? self.currentLessonTitle

        return HomeScreenModel(
            title: "今日学习",
            subtitle: todayLabel,
            todayStatusTitle: "今日状态",
            statusMetrics: [
                .init(
                    id: "streak",
                    title: "持续时间",
                    value: "\(streakDays)",
                    unit: "天",
                    systemImage: "flame.fill",
                    accent: .amber
                ),
                .init(
                    id: "xp",
                    title: "经验",
                    value: "\(totalXP)",
                    unit: "XP",
                    systemImage: "sparkles",
                    accent: .purple
                ),
                .init(
                    id: "review",
                    title: "待复习",
                    value: "\(reviewCardsDueTodayCount)",
                    unit: "张",
                    systemImage: "rectangle.stack.fill",
                    accent: .blue
                ),
            ],
            continueSectionTitle: "继续学习",
            continueCard: .init(
                badge: currentLessonBadge,
                title: currentLessonTitle,
                progress: 0.40,
                progressText: "完成 40%"
            ),
            tipSectionTitle: "今日知识点 Tips",
            knowledgeTip: .init(
                title: "p 值不是「原假设为真的概率」",
                body: "它表示：在 H0 成立时，观察到当前结果或更极端结果的概率。",
                systemImage: "lightbulb",
                accent: .amber
            )
        )
    }

    var routesOverviewModel: RoutesOverviewModel {
        RoutesOverviewModel(
            title: "学习路线",
            subtitle: "选择你的探索方向",
            routes: routes
        )
    }

    var pathScreenModel: PathScreenModel {
        let visibleNodes = visiblePathNodes

        return PathScreenModel(
            title: "\(routeCategoryTitle)路线",
            subtitle: "切换课程查看章节",
            trackTabs: routeTracks.map {
                .init(track: $0, title: $0.title, isSelected: $0 == selectedRouteTrack)
            },
            selectedTrackTitle: selectedRouteTrackTitle,
            selectedTrackSummary: visibleNodes.isEmpty
                ? "当前课程暂无章节"
                : "共 \(visibleNodes.count) 个章节",
            nodes: visibleNodes.map { node in
                PathScreenModel.Node(
                    id: node.id,
                    title: node.title,
                    subtitle: node.subtitle,
                    status: node.status,
                    isInteractive: node.isInteractive,
                    progress: node.status == .current ? 0.40 : nil
                )
            },
            emptyStateTitle: visibleNodes.isEmpty ? "\(selectedRouteTrackTitle) 即将开放" : nil,
            emptyStateMessage: visibleNodes.isEmpty ? "这一门课程还没有填充章节数据，后续会在这里展示完整章节路线。" : nil
        )
    }

    var lessonScreenModel: LessonScreenModel {
        LessonScreenModel(
            title: currentLessonTitle,
            currentPageIndex: currentLessonPageIndex,
            pageCount: lessonPages.count,
            pages: lessonPages.map { page in
                LessonScreenModel.Page(
                    id: page.id,
                    badge: page.badge,
                    accent: page.accent,
                    title: page.title,
                    summary: page.summary,
                    callout: .init(
                        title: page.calloutTitle,
                        message: page.calloutBody,
                        accent: page.calloutAccent
                    ),
                    codeSample: page.codeSample,
                    questionPrompt: page.question.prompt,
                    options: page.question.options.map { option in
                        LessonScreenModel.Option(
                            id: option.id,
                            badge: option.badge,
                            title: option.title,
                            presentation: optionPresentation(for: option.id, answerState: page.answerState),
                            isEnabled: isOptionEnabled(for: page.answerState)
                        )
                    },
                    feedback: Self.feedback(for: page),
                    callToAction: page.callToAction.map {
                        .init(
                            kind: $0,
                            title: $0.title,
                            accent: $0 == .retry ? nil : .blue
                        )
                    }
                )
            }
        )
    }

    var completionScreenModel: CompletionScreenModel {
        CompletionScreenModel(
            title: "课程通关！",
            streakDays: streakDays,
            gainedXPText: "+15",
            reviewCount: generatedReviewCount,
            reviewTags: generatedReviewTags,
            reviewMessage: completionReviewMessage,
            nextLessonTitle: nextLessonTitle,
            showsReviewAction: generatedReviewCount > 0
        )
    }

    var reviewBoardModel: ReviewBoardModel {
        let currentCardModel = currentReviewCard.map {
            ReviewBoardModel.Card(
                id: $0.id,
                topic: $0.topic,
                accent: $0.accent,
                frontTitle: $0.frontTitle,
                frontSubtitle: $0.frontSubtitle,
                backTitle: $0.backTitle,
                backBody: $0.backBody,
                backHighlight: $0.backHighlight
            )
        }

        let stage: ReviewBoardModel.Stage

        if let currentCardModel {
            stage = .card(
                .init(
                    scope: .init(
                        current: currentReviewPosition,
                        total: activeReviewCards.count,
                        title: reviewScopeTitle,
                        subtitle: reviewScopeSubtitle
                    ),
                    card: currentCardModel,
                    isFlipped: isCurrentReviewCardFlipped,
                    showsRatingGrid: isCurrentReviewCardFlipped
                )
            )
        } else {
            stage = .empty(
                .init(
                    hasActiveFilters: reviewFilterBadgeCount > 0,
                    title: reviewFilterBadgeCount > 0 ? "当前筛选下暂无卡片" : "今日复习已完成",
                    message: reviewFilterBadgeCount > 0
                        ? "可以清空筛选条件，回到全卡池继续复习。"
                        : "今天的复习范围已经处理完成，可以回到概览继续学习。",
                    actionTitle: reviewFilterBadgeCount > 0 ? "清除筛选" : "返回概览",
                    actionAccent: reviewFilterBadgeCount > 0 ? .amber : .blue,
                    actionSystemImage: reviewFilterBadgeCount > 0 ? "line.3.horizontal.decrease.circle" : "house.fill"
                )
            )
        }

        return ReviewBoardModel(
            title: "复习卡片",
            activeFilterCount: reviewFilterBadgeCount,
            summaries: LearnNowReviewBucket.allCases.map {
                ReviewBoardModel.Summary(bucket: $0, count: reviewSummaryByBucket[$0, default: 0])
            },
            stage: stage
        )
    }

    var reviewFiltersSheetModel: ReviewFiltersSheetModel {
        ReviewFiltersSheetModel(
            title: "卡池浏览",
            subtitle: "先浏览这一轮卡池，再按需收窄范围。",
            stagedResultSummary: stagedResultSummary,
            activeFilterCount: stagedFilterBadgeCount,
            summaryMessage: draftReviewFilters.isDefault
                ? "你现在看到的是全部卡池，可以直接浏览，或先用时间范围快速收窄。"
                : "结果会即时刷新；只有点击底部主按钮后，才会真正替换当前复习队列。",
            canReset: stagedFilterBadgeCount > 0,
            timeOptions: LearnNowReviewTimeFilter.allCases.map {
                .init(filter: $0, title: $0.title, isSelected: draftReviewFilters.time == $0)
            },
            topicOptions: reviewTopicFacets.map {
                .init(
                    id: $0.id,
                    title: $0.title,
                    accent: $0.accent,
                    count: $0.count,
                    isSelected: draftReviewFilters.topics.contains($0.id)
                )
            },
            moduleOptions: reviewModuleFacets.map {
                .init(
                    id: $0.id,
                    title: $0.title,
                    accent: $0.accent,
                    count: $0.count,
                    isSelected: draftReviewFilters.moduleIDs.contains($0.id)
                )
            },
            masteryOptions: LearnNowReviewMasteryFilter.allCases.map {
                .init(filter: $0, title: $0.title, isSelected: draftReviewFilters.mastery == $0)
            },
            favoriteOptions: LearnNowReviewFavoriteFilter.allCases.map {
                .init(filter: $0, title: $0.title, isSelected: draftReviewFilters.favorite == $0)
            },
            resultsTitle: "卡片浏览",
            emptyResultsTitle: "当前筛选下暂无卡片",
            emptyResultsMessage: "可以放宽时间窗口，或展开高级筛选取消主题 / 模块限制。",
            resultCards: stagedReviewCards.map {
                .init(
                    id: $0.id,
                    topic: $0.topic,
                    topicAccent: $0.accent,
                    bucketTitle: $0.bucket.title,
                    bucketAccent: $0.bucket.accent,
                    frontTitle: $0.frontTitle,
                    moduleTitle: $0.moduleTitle,
                    dueLabel: Self.dueLabel(for: $0.dueAt),
                    highlight: $0.backHighlight,
                    isFavorited: $0.isFavorited,
                    isMastered: $0.isMastered
                )
            },
            footerCountText: stagedReviewCards.isEmpty ? "暂无结果" : "\(stagedReviewCards.count) 张卡片",
            footerSummary: draftReviewFilters.isDefault ? "将按当前卡池开始" : "仅应用到本轮复习",
            applyButtonTitle: applyFiltersCTA,
            canApply: !stagedReviewCards.isEmpty
        )
    }

    var profileScreenModel: ProfileScreenModel {
        let safePageIndex = min(currentLessonPageIndex, max(lessonPages.count - 1, 0))
        let currentLessonBadge = "第\(loadedLessonModuleIndex + 1)单元 · 课时\(safePageIndex + 1)"
        let currentLessonTitle = lessonPages.isEmpty ? self.currentLessonTitle : lessonPages[safePageIndex].title
        let level = max(1, totalXP / 200)

        return ProfileScreenModel(
            title: "我的",
            subtitle: "学习概览、收藏与偏好设置",
            profileName: "数据科学学徒",
            profileHeadline: "\(streakDays) 天连续学习 · 累计 \(totalXP) XP",
            profileLevel: "Lv.\(level)",
            overviewCTA: .init(
                badge: currentLessonBadge,
                title: currentLessonTitle,
                subtitle: "把原来的学习概览收进这里，作为你的个人学习驾驶舱。",
                progress: 0.40,
                progressText: "主线完成 40%",
                xpText: "累计获得 \(totalXP) XP",
                heatmap: heatmap,
                metrics: [
                    LearnNowHeaderMetric(
                        id: "review",
                        title: "今日待复习",
                        value: "\(reviewCardsDueTodayCount)",
                        unit: "卡",
                        accent: .blue
                    ),
                    LearnNowHeaderMetric(
                        id: "mastery",
                        title: "掌握度",
                        value: "\(Int(mastery * 100))%",
                        unit: nil,
                        accent: .mint
                    ),
                    LearnNowHeaderMetric(
                        id: "favorites",
                        title: "已收藏",
                        value: "\(favoritedReviewCardsCount)",
                        unit: "张",
                        accent: .pink
                    ),
                ]
            ),
            favoritesTitle: "收藏",
            favoritesSubtitle: "把重点卡片固定在一个入口，随时回看。",
            favoriteSummary: .init(
                countText: "\(favoritedReviewCardsCount) 张已收藏",
                masteredText: "\(masteredFavoritedReviewCardsCount) 张已掌握",
                highlights: profileFavoriteHighlights,
                actionTitle: "进入收藏复习"
            ),
            retentionTitle: "艾宾浩斯记忆曲线",
            primarySeries: retentionSeries,
            baselineSeries: baselineSeries,
            knowledgeTitle: "知识掌握",
            knowledgeMetrics: knowledgeMetrics,
            settingsTitle: "设置",
            settingsSubtitle: "提醒节奏和外观偏好都在这里统一管理。",
            reminderTitle: "提醒时间",
            reminderSubtitle: "每天固定一个轻提醒，把学习重新拉回你的日程里。",
            reminderTimeText: reminderTimeText,
            remindersEnabled: remindersEnabled,
            appearanceTitle: "外观模式",
            appearanceSubtitle: "一键切换白天 / 夜间模式，保持阅读舒适度。",
            isNightModeEnabled: isNightModeEnabled
        )
    }

    private func optionPresentation(
        for optionID: String,
        answerState: LearnNowLessonAnswerState
    ) -> LessonScreenModel.Option.Presentation {
        switch answerState {
        case .correct(let selectedID) where selectedID == optionID:
            .correct
        case .incorrect(let selectedID) where selectedID == optionID:
            .incorrect
        default:
            .normal
        }
    }

    private func isOptionEnabled(for answerState: LearnNowLessonAnswerState) -> Bool {
        if case .unanswered = answerState {
            true
        } else {
            false
        }
    }
}
