import Foundation

struct HomeScreenModel: Equatable {
    struct ContinueCard: Equatable {
        let badge: String
        let title: String
        let progress: Double
        let progressText: String
    }

    let title: String
    let subtitle: String
    let totalXPText: String
    let streakDays: Int
    let metrics: [LearnNowHeaderMetric]
    let continueSectionTitle: String
    let continueCard: ContinueCard
    let studyRecordTitle: String
    let heatmap: [LearnNowHeatCell]
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

struct DashboardScreenModel: Equatable {
    let title: String
    let subtitle: String
    let retentionTitle: String
    let primarySeries: [Double]
    let baselineSeries: [Double]
    let knowledgeTitle: String
    let knowledgeMetrics: [LearnNowKnowledgeMetric]
}

extension LearnNowFlowState {
    var homeScreenModel: HomeScreenModel {
        let safePageIndex = min(currentLessonPageIndex, max(lessonPages.count - 1, 0))
        let currentLessonBadge = "第\(loadedLessonModuleIndex + 1)单元 · 课时\(safePageIndex + 1)"
        let currentLessonTitle = lessonPages.isEmpty ? self.currentLessonTitle : lessonPages[safePageIndex].title

        return HomeScreenModel(
            title: "学习概览",
            subtitle: todayLabel,
            totalXPText: "累计获得 \(totalXP) XP",
            streakDays: streakDays,
            metrics: homeMetrics,
            continueSectionTitle: "继续学习",
            continueCard: .init(
                badge: currentLessonBadge,
                title: currentLessonTitle,
                progress: 0.40,
                progressText: "完成 40%"
            ),
            studyRecordTitle: "本月学习记录",
            heatmap: heatmap
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
            subtitle: "按主题、时间与模块收窄范围，再开始这一轮复习。",
            stagedResultSummary: stagedResultSummary,
            activeFilterCount: stagedFilterBadgeCount,
            summaryMessage: draftReviewFilters.isDefault
                ? "未启用筛选时，将按全部卡池的默认顺序开始复习。"
                : "筛选只在你点击主按钮后生效；直接关闭不会改动当前复习队列。",
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
            resultsTitle: "筛选结果",
            emptyResultsTitle: "当前筛选下暂无卡片",
            emptyResultsMessage: "可以放宽时间窗口，或取消主题 / 模块限制。",
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
            footerSummary: draftReviewFilters.isDefault ? "将从全部卡池开始" : "仅应用到本轮复习",
            applyButtonTitle: applyFiltersCTA,
            canApply: !stagedReviewCards.isEmpty
        )
    }

    var dashboardScreenModel: DashboardScreenModel {
        DashboardScreenModel(
            title: "学习数据",
            subtitle: "你的进步雷达",
            retentionTitle: "艾宾浩斯记忆曲线",
            primarySeries: retentionSeries,
            baselineSeries: baselineSeries,
            knowledgeTitle: "知识图谱",
            knowledgeMetrics: knowledgeMetrics
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
