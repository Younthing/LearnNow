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

enum LearnNowRouteTrack: String, CaseIterable, Codable, Equatable, Identifiable, Sendable {
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

enum LearnNowAccent: String, Codable, Equatable, Sendable {
    case blue
    case pink
    case mint
    case purple
    case amber
}

enum LearnNowLessonAnswerState: Equatable, Sendable {
    case unanswered
    case correct(optionID: String)
    case incorrect(optionID: String)
}

enum LearnNowLessonCallToAction: Equatable, Sendable {
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

enum LearnNowReviewRating: String, CaseIterable, Equatable, Hashable, Identifiable, Sendable {
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

struct LearnNowMetric: Identifiable, Equatable {
    let id: String
    let title: String
    let value: String
    let unit: String?
    let systemImage: String?
    let accent: LearnNowAccent
}

struct LearnNowLearningSummary: Equatable {
    let badge: String
    let title: String
    let progress: Double
    let progressText: String
}

struct LearnNowRoute: Identifiable, Equatable, Sendable {
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

struct LearnNowLessonOption: Identifiable, Equatable, Sendable {
    let id: String
    let badge: String
    let title: String
}

struct LearnNowLessonQuestion: Equatable, Sendable {
    let prompt: String
    let options: [LearnNowLessonOption]
    let correctOptionID: String
}

struct LearnNowLessonPage: Identifiable, Equatable, Sendable {
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

struct LearnNowReviewCard: Identifiable, Equatable, Sendable {
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
    var retrievability: Double = 0
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

struct LearnNowModuleDefinition: Identifiable, Equatable, Sendable {
    let id: String
    let track: LearnNowRouteTrack
    let title: String
    let subtitle: String
    let lessonTitle: String
    let lessonPages: [LearnNowLessonPage]
    let reviewTags: [String]
    let reviewMessage: String
    let prerequisiteModuleIDs: [String]
    let completionXP: Int
    let reviewCardIDs: [String]

    init(
        id: String,
        track: LearnNowRouteTrack,
        title: String,
        subtitle: String,
        lessonTitle: String,
        lessonPages: [LearnNowLessonPage],
        reviewTags: [String],
        reviewMessage: String,
        prerequisiteModuleIDs: [String] = [],
        completionXP: Int = 15,
        reviewCardIDs: [String] = []
    ) {
        self.id = id
        self.track = track
        self.title = title
        self.subtitle = subtitle
        self.lessonTitle = lessonTitle
        self.lessonPages = lessonPages
        self.reviewTags = reviewTags
        self.reviewMessage = reviewMessage
        self.prerequisiteModuleIDs = prerequisiteModuleIDs
        self.completionXP = completionXP
        self.reviewCardIDs = reviewCardIDs
    }
}

struct LearnNowCompletionSummary: Equatable {
    let completedModuleTitle: String
    let reviewTags: [String]
    let reviewMessage: String
    let nextModuleTitle: String?
}

struct LearnNowFlowState: Equatable {
    var catalog: CourseCatalog
    var modules: [LearnNowModuleDefinition]
    var completedLessonIDs: Set<String>
    var activityByLocalDay: [String: Int]
    var reviewMemoryByCardID: [String: ReviewMemorySnapshot]
    var profilePreference: ProfilePreference
    var memoryTrend: MemoryTrend
    var syncAvailability: LearnNowSyncAvailability
    var activeCloudSyncEnabled: Bool
    var desiredCloudSyncEnabled: Bool
    var reviewIntervalTextByRating: [LearnNowReviewRating: String]
    var selectedTab: LearnNowTab = .home
    var currentScreen: LearnNowScreen = .home
    var routesDestination: LearnNowRoutesDestination = .overview
    var totalXP: Int
    var streakDays: Int
    var todayLabel: String
    var selectedRouteTrack: LearnNowRouteTrack = .statistics
    var nextAvailableModuleIndex: Int
    var loadedLessonModuleIndex: Int
    var currentLessonPageIndex: Int = 0
    var lessonPages: [LearnNowLessonPage]
    var completionSummary: LearnNowCompletionSummary?
    var reviewCards: [LearnNowReviewCard]
    var currentReviewCardIndex: Int = 0
    var isCurrentReviewCardFlipped = false
    var appliedReviewFilters: LearnNowReviewFilters = .empty
    var draftReviewFilters: LearnNowReviewFilters = .empty
    var activeReviewSheet: LearnNowReviewSheet?
    var didAwardCompletionXP = false
    var reminderTime: Date
    var remindersEnabled: Bool
    var isNightModeEnabled: Bool

    init(
        catalog: CourseCatalog = LearnNowFlowFixtures.catalog,
        snapshot: LearningSnapshot? = nil,
        now: Date = Date(),
        activeCloudSyncEnabled: Bool = true,
        desiredCloudSyncEnabled: Bool? = nil
    ) {
        let isPreviewFixture = snapshot == nil
        let resolvedSnapshot = snapshot ?? LearnNowFlowFixtures.learningSnapshot
        let completedIDs = resolvedSnapshot.completedLessonIDs
        let firstAvailableIndex = catalog.modules.firstIndex { module in
            !completedIDs.contains(module.id) &&
            Set(module.prerequisiteModuleIDs).isSubset(of: completedIDs)
        } ?? catalog.modules.count
        let restoredIndex = resolvedSnapshot.lastVisitedLessonID.flatMap { lessonID in
            catalog.modules.firstIndex(where: { $0.id == lessonID })
        }
        let initialIndex = min(
            restoredIndex ?? firstAvailableIndex,
            max(catalog.modules.count - 1, 0)
        )
        let initialModule = catalog.modules.indices.contains(initialIndex) ? catalog.modules[initialIndex] : nil
        let restoredPageIndex = initialModule.flatMap { module in
            resolvedSnapshot.lastVisitedPageID.flatMap { pageID in
                module.lessonPages.firstIndex(where: { $0.id == pageID })
            }
        } ?? 0

        self.catalog = catalog
        self.modules = catalog.modules
        self.completedLessonIDs = completedIDs
        self.activityByLocalDay = resolvedSnapshot.activityByLocalDay
        self.reviewMemoryByCardID = resolvedSnapshot.reviewMemoryByCardID
        self.profilePreference = resolvedSnapshot.profilePreference
        self.memoryTrend = .empty
        self.syncAvailability = resolvedSnapshot.syncAvailability
        self.activeCloudSyncEnabled = activeCloudSyncEnabled
        self.desiredCloudSyncEnabled = desiredCloudSyncEnabled
            ?? LearnNowCloudSyncPreference.isEnabled()
        self.reviewIntervalTextByRating = Dictionary(
            uniqueKeysWithValues: LearnNowReviewRating.allCases.map { ($0, $0.interval) }
        )
        self.totalXP = resolvedSnapshot.totalXP
        self.streakDays = resolvedSnapshot.streakDays
        self.todayLabel = Self.todayFormatter.string(from: now)
        self.nextAvailableModuleIndex = firstAvailableIndex
        self.loadedLessonModuleIndex = initialIndex
        self.currentLessonPageIndex = restoredPageIndex
        self.lessonPages = initialModule?.lessonPages ?? []
        self.reviewCards = isPreviewFixture
            ? LearnNowFlowFixtures.makeReviewCards()
            : Self.makeReviewCards(catalog: catalog, snapshot: resolvedSnapshot, now: now)
        self.reminderTime = UserDefaults.standard.object(forKey: Self.reminderTimeKey) as? Date
            ?? Self.defaultReminderTime()
        self.remindersEnabled = UserDefaults.standard.object(forKey: Self.remindersEnabledKey) == nil
            ? true
            : UserDefaults.standard.bool(forKey: Self.remindersEnabledKey)
        self.isNightModeEnabled = UserDefaults.standard.bool(forKey: Self.nightModeKey)
    }

    var routeCategoryTitle: String {
        catalog.primaryRoute?.title ?? "学习路线"
    }

    var mastery: Double {
        guard !reviewCards.isEmpty else { return 0 }
        return reviewCards.map(\.retrievability).reduce(0, +) / Double(reviewCards.count)
    }

    var routes: [LearnNowRoute] {
        catalog.routes.map { route in
            let moduleIDs = catalog.moduleIDsByRouteID[route.id, default: []]
            let completedCount = moduleIDs.filter { completedLessonIDs.contains($0) }.count
            let progress = moduleIDs.isEmpty ? 0 : Double(completedCount) / Double(moduleIDs.count)
            return LearnNowRoute(
                id: route.id,
                title: route.title,
                subtitle: route.subtitle,
                progress: progress,
                accent: route.accent,
                cta: route.cta,
                interactive: route.interactive
            )
        }
    }

    var routeTracks: [LearnNowRouteTrack] {
        LearnNowRouteTrack.allCases
    }

    var pathNodes: [LearnNowPathNode] {
        modules.enumerated().map { index, module in
            let status: LearnNowPathNode.Status

            if completedLessonIDs.contains(module.id) {
                status = .done
            } else if isLessonAvailable(for: index) {
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
        let calendar = Calendar.current
        let now = Date()
        let range = calendar.range(of: .day, in: .month, for: now) ?? 1..<32
        return (1...35).map { day in
            if !range.contains(day) {
                return LearnNowHeatCell(id: day, level: nil)
            }
            var components = calendar.dateComponents([.year, .month], from: now)
            components.day = day
            let date = calendar.date(from: components) ?? now
            let count = activityByLocalDay[Self.localDayFormatter.string(from: date), default: 0]
            return LearnNowHeatCell(id: day, level: min(count, 3))
        }
    }

    var rollingFourWeekHeatmap: [LearnNowHeatCell] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        return (-27...0).enumerated().map { index, dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today) ?? today
            let count = activityByLocalDay[Self.localDayFormatter.string(from: date), default: 0]
            return LearnNowHeatCell(id: index, level: min(count, 3))
        }
    }

    var knowledgeMetrics: [LearnNowKnowledgeMetric] {
        Dictionary(grouping: reviewCards, by: \.topic)
            .compactMap { topic, cards in
                guard let first = cards.first else { return nil }
                let progress = cards.map(\.retrievability).reduce(0, +) / Double(cards.count)
                return LearnNowKnowledgeMetric(id: topic, title: topic, progress: progress, accent: first.accent)
            }
            .sorted { $0.title < $1.title }
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
        if reviewCards.isEmpty { return Array(repeating: 0, count: 7) }
        let average = mastery
        return (0..<7).map { day in max(0, min(1, average * pow(0.96, Double(day)))) }
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
        modules.indices.contains(loadedLessonModuleIndex)
            ? modules[loadedLessonModuleIndex].lessonTitle
            : "课程"
    }

    var generatedReviewTags: [String] {
        completionSummary?.reviewTags ?? (modules.indices.contains(loadedLessonModuleIndex) ? modules[loadedLessonModuleIndex].reviewTags : [])
    }

    var generatedReviewCount: Int {
        generatedReviewTags.count
    }

    var completionReviewMessage: String {
        completionSummary?.reviewMessage ?? (modules.indices.contains(loadedLessonModuleIndex) ? modules[loadedLessonModuleIndex].reviewMessage : "")
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

}

private extension LearnNowFlowState {
    static let reminderTimeKey = "learnnow.settings.reminderTime"
    static let remindersEnabledKey = "learnnow.settings.remindersEnabled"
    static let nightModeKey = "learnnow.settings.nightMode"

    static let todayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEEE · M月d日"
        return formatter
    }()

    static let localDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func makeReviewCards(
        catalog: CourseCatalog,
        snapshot: LearningSnapshot,
        now: Date
    ) -> [LearnNowReviewCard] {
        catalog.reviewCards.compactMap { definition in
            guard let memory = snapshot.reviewMemoryByCardID[definition.id],
                  let module = catalog.module(id: definition.moduleID) else {
                return nil
            }
            let bucket: LearnNowReviewBucket
            if memory.reps == 0 {
                bucket = .new
            } else if memory.dueAt <= now {
                bucket = .review
            } else {
                bucket = .reinforce
            }
            return LearnNowReviewCard(
                id: definition.id,
                topic: definition.topic,
                moduleID: definition.moduleID,
                moduleTitle: module.title,
                bucket: bucket,
                accent: definition.accent,
                frontTitle: definition.frontTitle,
                frontSubtitle: definition.frontSubtitle,
                backTitle: definition.backTitle,
                backBody: definition.backBody,
                backHighlight: definition.backHighlight,
                dueAt: memory.dueAt,
                retrievability: memory.retrievability,
                isMastered: memory.isMastered,
                isFavorited: memory.isFavorited
            )
        }
    }

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
