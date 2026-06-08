//
//  LearnNowFlowState.swift
//  LearnNow
//
//  Created by Codex on 4/3/26.
//

import Foundation

enum LearnNowTab: String, CaseIterable, Equatable, Identifiable {
    case home
    case routes
    case anki
    case profile

    var id: Self { self }

    var title: String {
        switch self {
        case .home: "首页"
        case .routes: "路线"
        case .anki: "复习"
        case .profile: "我的"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .routes: "map"
        case .anki: "square.stack.3d.up"
        case .profile: "person.crop.circle"
        }
    }
}

enum LearnNowScreen: Equatable {
    case home
    case routes
    case anki
    case profile
}

enum LearnNowRoutesDestination: Equatable {
    case overview
    case path
    case lesson
    case completion
}

enum LearnNowReviewSheet: String, Equatable, Identifiable {
    case cardPool

    var id: String { rawValue }
}

enum LearnNowRouteTrack: String, CaseIterable, Equatable, Identifiable {
    case statistics
    case machineLearning
    case deepLearning

    var id: Self { self }

    var title: String {
        switch self {
        case .statistics: "统计基础"
        case .machineLearning: "机器学习"
        case .deepLearning: "深度学习"
        }
    }
}

enum LearnNowAccent: String, Equatable {
    case blue
    case pink
    case mint
    case purple
    case amber
}

enum LearnNowLessonAnswerState: Equatable {
    case unanswered
    case correct(optionID: String)
    case incorrect(optionID: String)
}

enum LearnNowLessonCallToAction: Equatable {
    case nextPage
    case retry
    case completeLesson

    var title: String {
        switch self {
        case .nextPage: "进入下一分页"
        case .retry: "重新思考"
        case .completeLesson: "完成通关"
        }
    }
}

enum LearnNowReviewRating: String, CaseIterable, Equatable, Identifiable {
    case again
    case hard
    case good
    case easy

    var id: Self { self }

    var title: String {
        switch self {
        case .again: "重来"
        case .hard: "困难"
        case .good: "良好"
        case .easy: "简单"
        }
    }

    var interval: String {
        switch self {
        case .again: "<1分钟"
        case .hard: "6分钟"
        case .good: "1天"
        case .easy: "4天"
        }
    }

    var accent: LearnNowAccent {
        switch self {
        case .again: .pink
        case .hard: .amber
        case .good: .mint
        case .easy: .blue
        }
    }
}

enum LearnNowReviewBucket: String, CaseIterable, Equatable, Identifiable {
    case new
    case reinforce
    case review

    var id: Self { self }

    var title: String {
        switch self {
        case .new: "新卡"
        case .reinforce: "巩固"
        case .review: "待复习"
        }
    }

    var accent: LearnNowAccent {
        switch self {
        case .new: .blue
        case .reinforce: .mint
        case .review: .pink
        }
    }
}

enum LearnNowReviewTimeFilter: String, CaseIterable, Equatable, Identifiable {
    case all
    case overdue
    case today
    case nextThreeDays
    case thisWeek

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "全部时间"
        case .overdue: "已到期"
        case .today: "今天"
        case .nextThreeDays: "3天内"
        case .thisWeek: "本周"
        }
    }
}

enum LearnNowReviewMasteryFilter: String, CaseIterable, Equatable, Identifiable {
    case all
    case masteredOnly
    case unmasteredOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "掌握状态"
        case .masteredOnly: "仅已掌握"
        case .unmasteredOnly: "仅未掌握"
        }
    }
}

enum LearnNowReviewFavoriteFilter: String, CaseIterable, Equatable, Identifiable {
    case all
    case favoritedOnly

    var id: Self { self }

    var title: String {
        switch self {
        case .all: "收藏状态"
        case .favoritedOnly: "仅已收藏"
        }
    }
}

struct LearnNowHeaderMetric: Identifiable, Equatable {
    let id: String
    let title: String
    let value: String
    let unit: String?
    let accent: LearnNowAccent
}

struct LearnNowRoute: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let progress: Double
    let accent: LearnNowAccent
    let cta: String
    let interactive: Bool
}

struct LearnNowPathNode: Identifiable, Equatable {
    enum Status: Equatable {
        case done
        case current
        case locked
    }

    let id: String
    let track: LearnNowRouteTrack
    let title: String
    let subtitle: String
    let status: Status
    let isInteractive: Bool
}

struct LearnNowHeatCell: Identifiable, Equatable {
    let id: Int
    let level: Int?
}

struct LearnNowLessonOption: Identifiable, Equatable {
    let id: String
    let badge: String
    let title: String
}

struct LearnNowLessonQuestion: Equatable {
    let prompt: String
    let options: [LearnNowLessonOption]
    let correctOptionID: String
}

struct LearnNowLessonPage: Identifiable, Equatable {
    let id: String
    let badge: String
    let accent: LearnNowAccent
    let title: String
    let summary: String
    let calloutTitle: String
    let calloutBody: String
    let calloutAccent: LearnNowAccent
    let codeSample: String?
    let question: LearnNowLessonQuestion
    let successAction: LearnNowLessonCallToAction
    var answerState: LearnNowLessonAnswerState = .unanswered

    var callToAction: LearnNowLessonCallToAction? {
        switch answerState {
        case .unanswered:
            nil
        case .correct:
            successAction
        case .incorrect:
            .retry
        }
    }
}

struct LearnNowLessonFeedback: Equatable {
    let title: String
    let body: String
    let accent: LearnNowAccent
}

struct LearnNowReviewFilters: Equatable {
    var topics: Set<String> = []
    var moduleIDs: Set<String> = []
    var time: LearnNowReviewTimeFilter = .all
    var mastery: LearnNowReviewMasteryFilter = .all
    var favorite: LearnNowReviewFavoriteFilter = .all

    static let empty = Self()

    var isDefault: Bool {
        topics.isEmpty &&
        moduleIDs.isEmpty &&
        time == .all &&
        mastery == .all &&
        favorite == .all
    }

    var activeFilterCount: Int {
        topics.count +
        moduleIDs.count +
        (time == .all ? 0 : 1) +
        (mastery == .all ? 0 : 1) +
        (favorite == .all ? 0 : 1)
    }
}

struct LearnNowReviewFacet: Identifiable, Equatable, Hashable {
    let id: String
    let title: String
    let accent: LearnNowAccent
    let count: Int
}

struct LearnNowReviewCard: Identifiable, Equatable {
    let id: String
    let topic: String
    let moduleID: String
    let moduleTitle: String
    let bucket: LearnNowReviewBucket
    let accent: LearnNowAccent
    let frontTitle: String
    let frontSubtitle: String?
    let backTitle: String
    let backBody: String
    let backHighlight: String
    var dueAt: Date
    var isMastered: Bool
    var isFavorited: Bool
}

struct LearnNowKnowledgeMetric: Identifiable, Equatable {
    let id: String
    let title: String
    let progress: Double
    let accent: LearnNowAccent
}

struct LearnNowProfileFavoriteHighlight: Identifiable, Equatable {
    let id: String
    let title: String
    let subtitle: String
    let accent: LearnNowAccent
}

struct LearnNowModuleDefinition: Identifiable, Equatable {
    let id: String
    let track: LearnNowRouteTrack
    let title: String
    let subtitle: String
    let lessonTitle: String
    let lessonPages: [LearnNowLessonPage]
    let reviewTags: [String]
    let reviewMessage: String
}

struct LearnNowCompletionSummary: Equatable {
    let completedModuleTitle: String
    let reviewTags: [String]
    let reviewMessage: String
    let nextModuleTitle: String?
}

struct LearnNowFlowState: Equatable {
    static let modules = LearnNowFlowFixtures.modules

    var selectedTab: LearnNowTab = .home
    var currentScreen: LearnNowScreen = .home
    var routesDestination: LearnNowRoutesDestination = .overview
    var totalXP: Int = 1_240
    var streakDays: Int = 12
    var mastery: Double = 0.61
    var todayLabel: String = "星期五 · 四月三日"
    var routeCategoryTitle: String = "数据科学与人工智能"
    var selectedRouteTrack: LearnNowRouteTrack = .statistics
    var nextAvailableModuleIndex: Int = 2
    var loadedLessonModuleIndex: Int = 2
    var currentLessonPageIndex: Int = 0
    var lessonPages: [LearnNowLessonPage] = LearnNowFlowState.modules[2].lessonPages
    var completionSummary: LearnNowCompletionSummary?
    var reviewCards: [LearnNowReviewCard] = LearnNowFlowFixtures.makeReviewCards()
    var currentReviewCardIndex: Int = 0
    var isCurrentReviewCardFlipped = false
    var appliedReviewFilters: LearnNowReviewFilters = .empty
    var draftReviewFilters: LearnNowReviewFilters = .empty
    var activeReviewSheet: LearnNowReviewSheet?
    var didAwardCompletionXP = false
    var reminderTime = Self.defaultReminderTime()
    var remindersEnabled = true
    var isNightModeEnabled = false

    var routes: [LearnNowRoute] {
        let primaryProgress = min(0.2 + (Double(nextAvailableModuleIndex) / Double(Self.modules.count)) * 0.45, 0.95)

        return [
            LearnNowRoute(
                id: "datascience",
                title: "数据科学与人工智能",
                subtitle: "统计 · 机器学习 · 深度学习",
                progress: primaryProgress,
                accent: .blue,
                cta: "继续学习",
                interactive: true
            ),
            LearnNowRoute(
                id: "design",
                title: "UI/UX 设计进阶",
                subtitle: "色彩体系 · 组件化设计 · 交互",
                progress: 0,
                accent: .pink,
                cta: "开始探索",
                interactive: false
            ),
            LearnNowRoute(
                id: "web",
                title: "全栈 Web 开发",
                subtitle: "React · Node.js · 数据库架构",
                progress: 0.10,
                accent: .mint,
                cta: "继续学习",
                interactive: false
            ),
        ]
    }

    var routeTracks: [LearnNowRouteTrack] {
        LearnNowRouteTrack.allCases
    }

    var pathNodes: [LearnNowPathNode] {
        Self.modules.enumerated().map { index, module in
            let status: LearnNowPathNode.Status

            if index < nextAvailableModuleIndex {
                status = .done
            } else if index == nextAvailableModuleIndex {
                status = .current
            } else {
                status = .locked
            }

            return LearnNowPathNode(
                id: module.id,
                track: module.track,
                title: module.title,
                subtitle: pathNodeSubtitle(for: index, baseSubtitle: module.subtitle, status: status),
                status: status,
                isInteractive: isLessonAvailable(for: index)
            )
        }
    }

    var visiblePathNodes: [LearnNowPathNode] {
        pathNodes.filter { $0.track == selectedRouteTrack }
    }

    var selectedRouteTrackTitle: String {
        selectedRouteTrack.title
    }

    var heatmap: [LearnNowHeatCell] {
        let activeDays: Set<Int> = [2, 3, 4, 6, 7, 9, 10, 11, 12, 14, 15, 16, 18, 19, 20, 21, 23, 24, 25, 26, 27, 28, 29, 30]

        return (1...35).map { day in
            if day > 31 {
                return LearnNowHeatCell(id: day, level: nil)
            }
            guard activeDays.contains(day) else {
                return LearnNowHeatCell(id: day, level: 0)
            }
            let level = day > 25 ? 3 : (day.isMultiple(of: 2) ? 1 : 2)
            return LearnNowHeatCell(id: day, level: level)
        }
    }

    var knowledgeMetrics: [LearnNowKnowledgeMetric] {
        [
            LearnNowKnowledgeMetric(id: "desc", title: "描述统计", progress: 0.92, accent: .mint),
            LearnNowKnowledgeMetric(id: "test", title: "假设检验", progress: mastery, accent: .blue),
            LearnNowKnowledgeMetric(id: "reg", title: "回归算法", progress: 0.25, accent: .pink),
        ]
    }

    var favoritedReviewCardsCount: Int {
        reviewCards.filter(\.isFavorited).count
    }

    var masteredFavoritedReviewCardsCount: Int {
        reviewCards.filter { $0.isFavorited && $0.isMastered }.count
    }

    var profileFavoriteHighlights: [LearnNowProfileFavoriteHighlight] {
        reviewCards
            .filter(\.isFavorited)
            .sorted(by: Self.reviewSort)
            .prefix(3)
            .map {
                LearnNowProfileFavoriteHighlight(
                    id: $0.id,
                    title: $0.frontTitle,
                    subtitle: $0.moduleTitle,
                    accent: $0.accent
                )
            }
    }

    var retentionSeries: [Double] {
        [1.0, 0.85, 0.78, 0.82, 0.75, 0.80, 0.78]
    }

    var baselineSeries: [Double] {
        [1.0, 0.33, 0.28, 0.25, 0.23, 0.21, 0.20]
    }

    var reminderTimeText: String {
        Self.timeFormatter.string(from: reminderTime)
    }

    var currentLessonPage: LearnNowLessonPage {
        lessonPages[currentLessonPageIndex]
    }

    var activeReviewCards: [LearnNowReviewCard] {
        filteredReviewCards(using: appliedReviewFilters)
    }

    var stagedReviewCards: [LearnNowReviewCard] {
        filteredReviewCards(using: draftReviewFilters)
    }

    var currentReviewCard: LearnNowReviewCard? {
        let cards = activeReviewCards
        guard !cards.isEmpty else { return nil }
        return cards[min(currentReviewCardIndex, cards.count - 1)]
    }

    var currentReviewPosition: Int {
        guard !activeReviewCards.isEmpty else { return 0 }
        return min(currentReviewCardIndex + 1, activeReviewCards.count)
    }

    var currentLessonTitle: String {
        Self.modules[loadedLessonModuleIndex].lessonTitle
    }

    var generatedReviewTags: [String] {
        completionSummary?.reviewTags ?? Self.modules[loadedLessonModuleIndex].reviewTags
    }

    var generatedReviewCount: Int {
        generatedReviewTags.count
    }

    var completionReviewMessage: String {
        completionSummary?.reviewMessage ?? Self.modules[loadedLessonModuleIndex].reviewMessage
    }

    var nextLessonTitle: String? {
        completionSummary?.nextModuleTitle
    }

    var hasNextLesson: Bool {
        nextLessonTitle != nil
    }

    var reviewCardsDueTodayCount: Int {
        let calendar = Calendar.current
        return reviewCards.filter { card in
            card.dueAt < calendar.startOfDay(for: Date()) || calendar.isDateInToday(card.dueAt)
        }.count
    }

    var reviewScopeTitle: String {
        guard !appliedReviewFilters.isDefault else { return "全卡池复习" }

        var labels: [String] = []
        if !appliedReviewFilters.topics.isEmpty {
            labels.append("\(appliedReviewFilters.topics.count) 个主题")
        }
        if !appliedReviewFilters.moduleIDs.isEmpty {
            labels.append("\(appliedReviewFilters.moduleIDs.count) 个模块")
        }
        if appliedReviewFilters.time != .all {
            labels.append(appliedReviewFilters.time.title)
        }
        if appliedReviewFilters.mastery != .all {
            labels.append(appliedReviewFilters.mastery.title)
        }
        if appliedReviewFilters.favorite == .favoritedOnly {
            labels.append("已收藏")
        }
        return labels.joined(separator: " · ")
    }

    var reviewScopeSubtitle: String {
        guard let currentReviewCard else {
            return "当前范围暂无可复习卡片"
        }

        let dueLabel = Self.dueLabel(for: currentReviewCard.dueAt)
        return "\(currentReviewCard.moduleTitle) · \(dueLabel)"
    }

    var reviewFilterBadgeCount: Int {
        appliedReviewFilters.activeFilterCount
    }

    var stagedFilterBadgeCount: Int {
        draftReviewFilters.activeFilterCount
    }

    var reviewSummaryByBucket: [LearnNowReviewBucket: Int] {
        Dictionary(grouping: activeReviewCards, by: \.bucket).mapValues(\.count)
    }

    var reviewTopicFacets: [LearnNowReviewFacet] {
        facets(
            groupedBy: \.topic,
            title: \.topic
        )
    }

    var reviewModuleFacets: [LearnNowReviewFacet] {
        facets(
            groupedBy: \.moduleID,
            title: \.moduleTitle
        )
    }

    var stagedResultSummary: String {
        if stagedReviewCards.isEmpty {
            return "当前筛选下暂无卡片"
        }

        if draftReviewFilters.isDefault {
            return "全部卡池 · \(stagedReviewCards.count) 张卡片"
        }

        return "筛选结果 · \(stagedReviewCards.count) 张卡片"
    }

    var applyFiltersCTA: String {
        stagedReviewCards.isEmpty ? "当前范围暂无可复习卡片" : "按当前筛选开始复习"
    }
}

private extension LearnNowFlowState {
    static func defaultReminderTime() -> Date {
        let calendar = Calendar.current
        let now = Date()
        return calendar.date(
            bySettingHour: 20,
            minute: 30,
            second: 0,
            of: now
        ) ?? now
    }

    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
}
