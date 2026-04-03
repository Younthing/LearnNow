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
    case dash

    var id: Self { self }

    var title: String {
        switch self {
        case .home: "概览"
        case .routes: "路线"
        case .anki: "复习"
        case .dash: "数据"
        }
    }

    var systemImage: String {
        switch self {
        case .home: "house"
        case .routes: "map"
        case .anki: "square.stack.3d.up"
        case .dash: "chart.pie"
        }
    }
}

enum LearnNowScreen: Equatable {
    case home
    case routes
    case path
    case lesson
    case completion
    case anki
    case dash
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
    let title: String
    let subtitle: String
    let status: Status
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

struct LearnNowReviewCard: Identifiable, Equatable {
    let id: String
    let topic: String
    let frontTitle: String
    let frontSubtitle: String
    let backTitle: String
    let backBody: String
    let backHighlight: String
}

struct LearnNowKnowledgeMetric: Identifiable, Equatable {
    let id: String
    let title: String
    let progress: Double
    let accent: LearnNowAccent
}

struct LearnNowFlowState: Equatable {
    var selectedTab: LearnNowTab = .home
    var currentScreen: LearnNowScreen = .home
    var totalXP: Int = 1_240
    var streakDays: Int = 12
    var dailyReviewCount: Int = 25
    var mastery: Double = 0.61
    var todayLabel: String = "星期五 · 四月三日"
    var routeCategoryTitle: String = "数据科学与人工智能"
    var routeTabs: [String] = ["统计基础", "机器学习", "深度学习"]
    var currentLessonPageIndex: Int = 0
    var lessonPages: [LearnNowLessonPage] = LearnNowFlowState.makeLessonPages()
    var generatedReviewTags: [String] = ["t 检验", "P值定义", "数据稳健性"]
    var reviewCards: [LearnNowReviewCard] = LearnNowFlowState.makeReviewCards()
    var currentReviewCardIndex: Int = 0
    var isCurrentReviewCardFlipped = false
    private var didAwardCompletionXP = false

    var homeMetrics: [LearnNowHeaderMetric] {
        [
            LearnNowHeaderMetric(
                id: "review",
                title: "今日待复习",
                value: "\(dailyReviewCount)",
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
        ]
    }

    var routes: [LearnNowRoute] {
        [
            LearnNowRoute(
                id: "datascience",
                title: "数据科学与人工智能",
                subtitle: "统计 · 机器学习 · 深度学习",
                progress: 0.35,
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

    var pathNodes: [LearnNowPathNode] {
        [
            LearnNowPathNode(id: "stats", title: "描述统计与数据探索", subtitle: "6课时 · 已掌握", status: .done),
            LearnNowPathNode(id: "probability", title: "概率论基础", subtitle: "8课时 · 已掌握", status: .done),
            LearnNowPathNode(id: "hypothesis", title: "假设检验", subtitle: "10课时 · 进行中", status: .current),
            LearnNowPathNode(id: "regression", title: "线性回归模型", subtitle: "12课时 · 未解锁", status: .locked),
        ]
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

    var retentionSeries: [Double] {
        [1.0, 0.85, 0.78, 0.82, 0.75, 0.80, 0.78]
    }

    var baselineSeries: [Double] {
        [1.0, 0.33, 0.28, 0.25, 0.23, 0.21, 0.20]
    }

    var currentLessonPage: LearnNowLessonPage {
        lessonPages[currentLessonPageIndex]
    }

    var currentReviewCard: LearnNowReviewCard {
        reviewCards[currentReviewCardIndex]
    }

    mutating func selectTab(_ tab: LearnNowTab) {
        selectedTab = tab

        switch tab {
        case .home:
            currentScreen = .home
        case .routes:
            currentScreen = .routes
        case .anki:
            currentScreen = .anki
        case .dash:
            currentScreen = .dash
        }
    }

    mutating func showRoutes() {
        selectedTab = .routes
        currentScreen = .routes
    }

    mutating func openPath() {
        selectedTab = .routes
        currentScreen = .path
    }

    mutating func openLesson() {
        selectedTab = .routes
        currentScreen = .lesson
    }

    mutating func answerCurrentLesson(with optionID: String) {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard case .unanswered = lessonPages[currentLessonPageIndex].answerState else { return }

        let correctOptionID = lessonPages[currentLessonPageIndex].question.correctOptionID
        if optionID == correctOptionID {
            lessonPages[currentLessonPageIndex].answerState = .correct(optionID: optionID)
        } else {
            lessonPages[currentLessonPageIndex].answerState = .incorrect(optionID: optionID)
        }
    }

    mutating func retryCurrentLessonQuestion() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard case .incorrect = lessonPages[currentLessonPageIndex].answerState else { return }
        lessonPages[currentLessonPageIndex].answerState = .unanswered
    }

    mutating func advanceLesson() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard lessonPages[currentLessonPageIndex].callToAction == .nextPage else { return }
        currentLessonPageIndex = min(currentLessonPageIndex + 1, lessonPages.count - 1)
    }

    mutating func completeLesson() {
        guard lessonPages.indices.contains(currentLessonPageIndex) else { return }
        guard lessonPages[currentLessonPageIndex].callToAction == .completeLesson else { return }

        if !didAwardCompletionXP {
            totalXP += 15
            mastery = 0.68
            didAwardCompletionXP = true
        }

        currentScreen = .completion
        selectedTab = .routes
    }

    mutating func finishLearning() {
        openPath()
    }

    mutating func openReviewBoard() {
        selectTab(.anki)
    }

    mutating func flipCurrentReviewCard() {
        isCurrentReviewCardFlipped = true
    }

    mutating func rateCurrentReviewCard(_ rating: LearnNowReviewRating) {
        _ = rating
        isCurrentReviewCardFlipped = false
        currentReviewCardIndex = (currentReviewCardIndex + 1) % reviewCards.count
    }

    static func feedback(for page: LearnNowLessonPage) -> LearnNowLessonFeedback? {
        switch page.answerState {
        case .unanswered:
            nil
        case .correct:
            LearnNowLessonFeedback(
                title: "漂亮，概念抓得很准。",
                body: "继续保持这个判断标准，下一页会把 P 值的真实含义彻底钉牢。",
                accent: .mint
            )
        case .incorrect:
            LearnNowLessonFeedback(
                title: "思路有点绕进去了。",
                body: "这是初学者最常见的坑，回看上方提示后再做一次会更稳。",
                accent: .pink
            )
        }
    }

    private static func makeLessonPages() -> [LearnNowLessonPage] {
        [
            LearnNowLessonPage(
                id: "lesson-page-1",
                badge: "小节 1 / 2",
                accent: .blue,
                title: "t检验与小样本",
                summary: "t检验是比较均值差异的核心工具。它基于 t 分布，专为小样本且总体方差未知的场景设计。",
                calloutTitle: "核心认知",
                calloutBody: "理论上 t检验要求数据接近正态分布，但在实际测算里它通常很稳健。只要偏态不极端，直接使用往往也是安全的。",
                calloutAccent: .amber,
                codeSample: """
                // 独立样本检验 - Python
                from scipy import stats

                t, p = stats.ttest_ind(a, b, equal_var=False)
                print(f"P值: {p:.4f}")
                """,
                question: LearnNowLessonQuestion(
                    prompt: "如果我手头只有 25 个样本数据，且总体方差未知，但数据只是轻微左偏，我可以直接尝试 t检验 吗？",
                    options: [
                        LearnNowLessonOption(id: "strict-normality", badge: "A", title: "绝对不行，必须严格正态分布"),
                        LearnNowLessonOption(id: "t-test-robust", badge: "B", title: "可以，t检验对此具备稳健性"),
                    ],
                    correctOptionID: "t-test-robust"
                ),
                successAction: .nextPage
            ),
            LearnNowLessonPage(
                id: "lesson-page-2",
                badge: "小节 2 / 2",
                accent: .pink,
                title: "P值 的终极意义",
                summary: "P值是我们做出假设检验判断时最核心的依据，但它经常被误解成“原假设为真的概率”。",
                calloutTitle: "避坑提示",
                calloutBody: "P值真正的潜台词是：如果原假设成立，那么观测到当前这组数据或更极端数据的概率有多低。",
                calloutAccent: .mint,
                codeSample: nil,
                question: LearnNowLessonQuestion(
                    prompt: "如果你运行代码得到 p = 0.01，这严格意味着什么？",
                    options: [
                        LearnNowLessonOption(id: "null-hypothesis-probability", badge: "A", title: "原假设有 1% 的概率是正确的"),
                        LearnNowLessonOption(id: "p-value-meaning", badge: "B", title: "若原假设成立，出现当前数据的概率只有 1%"),
                    ],
                    correctOptionID: "p-value-meaning"
                ),
                successAction: .completeLesson
            ),
        ]
    }

    private static func makeReviewCards() -> [LearnNowReviewCard] {
        [
            LearnNowReviewCard(
                id: "p-value",
                topic: "假设检验",
                frontTitle: "P值",
                frontSubtitle: "(p-value)",
                backTitle: "解析",
                backBody: "在原假设为真时，观测到当前统计结果的概率。",
                backHighlight: "p < 0.05 → 拒绝原假设"
            ),
            LearnNowReviewCard(
                id: "type-one-error",
                topic: "统计推断",
                frontTitle: "Type I Error",
                frontSubtitle: "(第一类错误)",
                backTitle: "解析",
                backBody: "弃真错误。原假设为真，但被错误地拒绝了。",
                backHighlight: "牢记：拒真不等于原假设本来就是错的。"
            ),
        ]
    }
}
