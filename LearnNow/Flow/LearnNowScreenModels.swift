import Foundation
import LearnNowContentKit

struct HomeScreenModel: Equatable {
    struct KnowledgeTip: Equatable {
        let title: String
        let body: [InlineContent]
        let systemImage: String
        let accent: LearnNowAccent
    }

    let title: String
    let subtitle: String
    let streakDays: Int
    let statusMetrics: [LearnNowMetric]
    let continueSectionTitle: String
    let continueCard: LearnNowLearningSummary
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
        let id: String
        let title: String
        let isSelected: Bool
    }

    struct Node: Identifiable, Equatable {
        let id: String
        let title: String
        let subtitle: String
        let status: LearnNowPathNode.Status
        let isInteractive: Bool
        let progress: Double?
        let hasNewContent: Bool
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
    struct Option: Identifiable, Equatable {
        enum Presentation: Equatable {
            case normal
            case correct
            case incorrect
        }

        let id: String
        let badge: String
        let content: [InlineContent]
        let presentation: Presentation
        let isEnabled: Bool
    }

    struct Exercise: Identifiable, Equatable {
        let id: String
        let prompt: [InlineContent]
        let options: [Option]
        let feedback: LearnNowLessonFeedback?
        let showsRetry: Bool
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
        let blocks: [LessonContentBlock]
        let exercisesByID: [String: Exercise]
        let contentRootURL: URL?
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
        let backBody: [InlineContent]
        let backHighlight: [InlineContent]
    }

    struct CardStage: Equatable {
        let scope: Scope
        let card: Card
        let isFlipped: Bool
        let showsRatingGrid: Bool
        let ratingIntervals: [LearnNowReviewRating: String]
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
    enum EmptyState: Equatable {
        case noMatches
        case noCards
    }

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
        let frontTitle: String
        let moduleTitle: String
        let dueLabel: String
        let answerPreview: String
        let isFavorited: Bool
        let isMastered: Bool
    }

    let title: String
    let activeFilterCount: Int
    let canReset: Bool
    let timeOptions: [TimeOption]
    let topicOptions: [FacetOption]
    let moduleOptions: [FacetOption]
    let masteryOptions: [MasteryOption]
    let favoriteOptions: [FavoriteOption]
    let resultCount: Int
    let emptyState: EmptyState?
    let resultCards: [ResultCard]
}

extension LearnNowFlowState {
    var currentLearningSummary: LearnNowLearningSummary {
        let safePageIndex = min(currentLessonPageIndex, max(lessonPages.count - 1, 0))
        let currentPage = lessonPages.indices.contains(safePageIndex) ? lessonPages[safePageIndex] : nil

        return LearnNowLearningSummary(
            badge: "第\(loadedLessonModuleIndex + 1)单元 · 课时\(safePageIndex + 1)",
            title: currentPage?.title ?? currentLessonTitle,
            progress: lessonPages.isEmpty ? 0 : Double(safePageIndex) / Double(lessonPages.count),
            progressText: lessonPages.isEmpty
                ? "尚未开始"
                : "完成 \(Int((Double(safePageIndex) / Double(lessonPages.count)) * 100))%"
        )
    }

    var streakMetric: LearnNowMetric {
        LearnNowMetric(
            id: "streak",
            title: "连续学习",
            value: "\(streakDays)",
            unit: "天",
            systemImage: "flame.fill",
            accent: .amber
        )
    }

    var xpMetric: LearnNowMetric {
        LearnNowMetric(
            id: "xp",
            title: "经验",
            value: "\(totalXP)",
            unit: "XP",
            systemImage: "bolt.fill",
            accent: .purple
        )
    }

    var reviewDueMetric: LearnNowMetric {
        LearnNowMetric(
            id: "review",
            title: "待复习卡片",
            value: "\(reviewCardsDueTodayCount)",
            unit: "张",
            systemImage: "calendar.badge.clock",
            accent: .blue
        )
    }

    var masteryMetric: LearnNowMetric {
        LearnNowMetric(
            id: "mastery",
            title: "掌握度",
            value: "\(Int(mastery * 100))%",
            unit: nil,
            systemImage: nil,
            accent: .mint
        )
    }

    var favoritesMetric: LearnNowMetric {
        LearnNowMetric(
            id: "favorites",
            title: "已收藏",
            value: "\(favoritedReviewCardsCount)",
            unit: "张",
            systemImage: nil,
            accent: .pink
        )
    }

    var homeScreenModel: HomeScreenModel {
        let learningSummary = currentLearningSummary
        let tip = rotatingKnowledgeTip

        return HomeScreenModel(
            title: "今天快乐",
            subtitle: todayLabel,
            streakDays: streakDays,
            statusMetrics: [streakMetric, xpMetric, reviewDueMetric],
            continueSectionTitle: "继续学习",
            continueCard: learningSummary,
            tipSectionTitle: "Tips",
            knowledgeTip: .init(
                title: tip?.title ?? "开始今天的学习",
                body: tip?.body ?? [
                    .text("完成一个课程模块后，相关知识卡片会自动进入复习池。"),
                ],
                systemImage: tip?.systemImage ?? "lightbulb",
                accent: tip?.accent ?? .amber
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
                .init(id: $0.id, title: $0.title, isSelected: $0.id == selectedRouteTrackID)
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
                    progress: node.status == .current ? 0.40 : nil,
                    hasNewContent: node.hasNewContent
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
            pages: lessonPages.enumerated().map { pageIndex, page in
                LessonScreenModel.Page(
                    id: page.id,
                    badge: "小节 \(pageIndex + 1) / \(lessonPages.count)",
                    accent: page.accent,
                    title: page.title,
                    blocks: page.blocks,
                    exercisesByID: Dictionary(
                        uniqueKeysWithValues: page.exercises.map { exercise in
                            let exerciseID = exercise.id
                            let answerState = page.answerState(for: exerciseID)
                            return (
                                exerciseID,
                                LessonScreenModel.Exercise(
                                    id: exerciseID,
                                    prompt: exercise.prompt,
                                    options: exercise.options.enumerated().map { optionIndex, option in
                                        LessonScreenModel.Option(
                                            id: option.id,
                                            badge: Self.optionBadge(for: optionIndex),
                                            content: option.content,
                                            presentation: optionPresentation(
                                                for: option.id,
                                                answerState: answerState
                                            ),
                                            isEnabled: isOptionEnabled(for: answerState)
                                        )
                                    },
                                    feedback: feedback(for: exercise, answerState: answerState),
                                    showsRetry: {
                                        if case .incorrect = answerState { return true }
                                        return false
                                    }()
                                )
                            )
                        }
                    ),
                    contentRootURL: catalog.contentRootURL,
                    callToAction: (page.isReadyToAdvance ? page.successAction : nil).map {
                        .init(
                            kind: $0,
                            title: $0.title,
                            accent: .blue
                        )
                    }
                )
            }
        )
    }

    var completionScreenModel: CompletionScreenModel {
        let gainedXP = modules.indices.contains(loadedLessonModuleIndex)
            ? modules[loadedLessonModuleIndex].completionXP
            : 0
        return CompletionScreenModel(
            title: "课程通关！",
            streakDays: streakDays,
            gainedXPText: "+\(gainedXP)",
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
                    showsRatingGrid: isCurrentReviewCardFlipped,
                    ratingIntervals: reviewIntervalTextByRating
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
        let stagedCards = stagedReviewCards

        return ReviewFiltersSheetModel(
            title: "卡池浏览",
            activeFilterCount: stagedFilterBadgeCount,
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
            resultCount: stagedCards.count,
            emptyState: stagedCards.isEmpty
                ? (reviewCards.isEmpty ? .noCards : .noMatches)
                : nil,
            resultCards: stagedCards.map {
                .init(
                    id: $0.id,
                    topic: $0.topic,
                    topicAccent: $0.accent,
                    frontTitle: $0.frontTitle,
                    moduleTitle: $0.moduleTitle,
                    dueLabel: Self.dueLabel(for: $0.dueAt),
                    answerPreview: $0.backHighlight.map(\.plainText).joined(),
                    isFavorited: $0.isFavorited,
                    isMastered: $0.isMastered
                )
            }
        )
    }

    var profileScreenModel: ProfileScreenModel {
        let completedCount = completedLessonIDs.count
        let totalCount = modules.count
        let reviewedMemories = reviewMemoryByCardID.values.filter { $0.reps > 0 }
        let reviewedMastery = reviewedMemories.isEmpty
            ? nil
            : reviewedMemories.map(\.retrievability).reduce(0, +) / Double(reviewedMemories.count)
        let settings = settingsScreenModel
        let memoryValues = memoryTrend.points.map(\.retrievability)
        let currentMemoryText = memoryTrend.current.map {
            "\(Int(($0 * 100).rounded()))%"
        }
        let seventhDayMemoryText = memoryTrend.seventhDay.map {
            "\(Int(($0 * 100).rounded()))%"
        }

        return ProfileScreenModel(
            title: "我的",
            identity: .init(
                displayName: profilePreference.displayName,
                avatarID: profilePreference.avatarID,
                activityText: "\(streakDays) 天连续 · 累计 \(totalXP) XP"
            ),
            overview: .init(
                metrics: [
                    .init(
                        id: "completed",
                        title: "完成课时",
                        value: "\(completedCount)/\(totalCount)",
                        accent: .purple
                    ),
                    .init(
                        id: "review",
                        title: "待复习",
                        value: "\(reviewCardsDueTodayCount)",
                        accent: .blue
                    ),
                    .init(
                        id: "mastery",
                        title: "平均掌握",
                        value: reviewedMastery.map { "\(Int(($0 * 100).rounded()))%" } ?? "—",
                        accent: .mint
                    ),
                ],
                heatmap: rollingFourWeekHeatmap,
            ),
            memoryTrend: .init(
                values: memoryValues,
                currentText: currentMemoryText,
                seventhDayText: seventhDayMemoryText
            ),
            shortcuts: [
                .init(
                    kind: .career,
                    title: "学习生涯",
                    subtitle: "\(routeCategoryTitle) · \(completedCount)/\(totalCount) 个节点",
                    systemImage: "map.fill",
                    accent: .mint
                ),
                .init(
                    kind: .favorites,
                    title: "收藏",
                    subtitle: "\(favoritedReviewCardsCount) 张卡片",
                    systemImage: "bookmark.fill",
                    accent: .pink
                ),
                .init(
                    kind: .settings,
                    title: "设置",
                    subtitle: settings.requiresRestart ? "重新打开 App 后生效" : settings.syncStatusText,
                    systemImage: "gearshape.fill",
                    accent: .blue
                ),
            ]
        )
    }

    var favoritesScreenModel: FavoritesScreenModel {
        let cards = reviewCards
            .filter(\.isFavorited)
            .sorted(by: Self.reviewSort)
            .map {
                FavoritesScreenModel.Item(
                    id: $0.id,
                    title: $0.frontTitle,
                    subtitle: $0.moduleTitle,
                    topic: $0.topic,
                    dueText: Self.dueLabel(for: $0.dueAt),
                    accent: $0.accent,
                    isMastered: $0.isMastered
                )
            }

        return FavoritesScreenModel(
            title: "收藏",
            countText: cards.isEmpty ? "还没有收藏" : "共 \(cards.count) 张卡片",
            items: cards
        )
    }

    var settingsScreenModel: SettingsScreenModel {
        let requiresRestart = activeCloudSyncEnabled != desiredCloudSyncEnabled
        let statusText: String
        if requiresRestart {
            statusText = desiredCloudSyncEnabled ? "等待开启" : "等待关闭"
        } else {
            statusText = syncAvailability.displayText
        }

        let detailText: String
        if requiresRestart {
            detailText = desiredCloudSyncEnabled
                ? "下次启动时连接 iCloud，并与本机学习记录合并。"
                : "下次启动后停止同步，本机和云端已有记录都不会被删除。"
        } else {
            switch syncAvailability {
            case .available:
                detailText = "学习进度、复习记录和个人资料正在通过 iCloud 同步。"
            case .disabled:
                detailText = "所有数据仅保存在本机；重新开启后可恢复合并。"
            case .localOnly:
                detailText = "当前无法连接 iCloud，学习数据仍会安全保存在本机。"
            case .restricted:
                detailText = "当前 iCloud 账号受限，学习数据暂时只保存在本机。"
            case .unknown:
                detailText = "正在检查 iCloud 账号与同步状态。"
            }
        }

        return SettingsScreenModel(
            title: "设置",
            syncStatusText: statusText,
            syncDetailText: detailText,
            desiredCloudSyncEnabled: desiredCloudSyncEnabled,
            requiresRestart: requiresRestart
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

    private var rotatingKnowledgeTip: CourseCatalog.KnowledgeTip? {
        let unlockedModuleIDs = Set(
            modules
                .filter {
                    completedLessonIDs.contains($0.id) ||
                        Set($0.prerequisiteModuleIDs).isSubset(of: completedLessonIDs)
                }
                .map(\.id)
        )
        let candidates = catalog.dailyTips
            .filter { tip in
                guard let moduleID = tip.moduleID else { return true }
                return unlockedModuleIDs.contains(moduleID)
            }
            .sorted { $0.id < $1.id }
        guard !candidates.isEmpty else { return nil }
        return candidates[tipRotationDayOrdinal % candidates.count]
    }

    private func feedback(
        for exercise: ExerciseDefinition,
        answerState: LearnNowLessonAnswerState
    ) -> LearnNowLessonFeedback? {
        let definition: FeedbackDefinition?
        switch answerState {
        case .unanswered:
            definition = nil
        case let .correct(optionID):
            definition = exercise.options.first(where: { $0.id == optionID })?.feedback
                ?? exercise.correctFeedback
        case let .incorrect(optionID):
            definition = exercise.options.first(where: { $0.id == optionID })?.feedback
                ?? exercise.incorrectFeedback
        }
        return definition.map {
            LearnNowLessonFeedback(
                title: $0.title,
                body: $0.body,
                accent: LearnNowAccent($0.accent)
            )
        }
    }

    private static func optionBadge(for index: Int) -> String {
        var number = index
        var badge = ""
        repeat {
            let scalar = UnicodeScalar(65 + (number % 26))!
            badge.insert(Character(scalar), at: badge.startIndex)
            number = (number / 26) - 1
        } while number >= 0
        return badge
    }
}
