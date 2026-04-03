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

struct LearnNowModuleDefinition: Identifiable, Equatable {
    let id: String
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
    private static let modules = makeModules()

    var selectedTab: LearnNowTab = .home
    var currentScreen: LearnNowScreen = .home
    var totalXP: Int = 1_240
    var streakDays: Int = 12
    var dailyReviewCount: Int = 25
    var mastery: Double = 0.61
    var todayLabel: String = "星期五 · 四月三日"
    var routeCategoryTitle: String = "数据科学与人工智能"
    var routeTabs: [String] = ["统计基础", "机器学习", "深度学习"]
    var nextAvailableModuleIndex: Int = 2
    var loadedLessonModuleIndex: Int = 2
    var currentLessonPageIndex: Int = 0
    var lessonPages: [LearnNowLessonPage] = LearnNowFlowState.modules[2].lessonPages
    var completionSummary: LearnNowCompletionSummary?
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
                title: module.title,
                subtitle: pathNodeSubtitle(for: index, baseSubtitle: module.subtitle, status: status),
                status: status,
                isInteractive: isLessonAvailable(for: index)
            )
        }
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
        guard nextAvailableModuleIndex < Self.modules.count else { return }

        if loadedLessonModuleIndex != nextAvailableModuleIndex {
            loadLesson(for: nextAvailableModuleIndex)
        }

        selectedTab = .routes
        currentScreen = .lesson
    }

    mutating func openLesson(moduleID: String) {
        guard let moduleIndex = Self.modules.firstIndex(where: { $0.id == moduleID }) else { return }
        guard isLessonAvailable(for: moduleIndex) else { return }

        loadLesson(for: moduleIndex)
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

        let completedModule = Self.modules[loadedLessonModuleIndex]
        let upcomingIndex = loadedLessonModuleIndex + 1
        let nextModuleTitle = upcomingIndex < Self.modules.count ? Self.modules[upcomingIndex].lessonTitle : nil

        completionSummary = LearnNowCompletionSummary(
            completedModuleTitle: completedModule.title,
            reviewTags: completedModule.reviewTags,
            reviewMessage: completedModule.reviewMessage,
            nextModuleTitle: nextModuleTitle
        )

        nextAvailableModuleIndex = min(upcomingIndex, Self.modules.count)
        currentScreen = .completion
        selectedTab = .routes
    }

    mutating func openNextLesson() {
        guard hasNextLesson else {
            finishLearning()
            return
        }

        openLesson()
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

    private func pathNodeSubtitle(
        for index: Int,
        baseSubtitle: String,
        status: LearnNowPathNode.Status
    ) -> String {
        switch status {
        case .done:
            return "\(baseSubtitle) · 已掌握"
        case .current:
            return "\(baseSubtitle) · 进行中"
        case .locked:
            return "\(baseSubtitle) · 未解锁"
        }
    }

    private func isLessonAvailable(for moduleIndex: Int) -> Bool {
        guard Self.modules.indices.contains(moduleIndex) else { return false }
        return moduleIndex <= nextAvailableModuleIndex && !Self.modules[moduleIndex].lessonPages.isEmpty
    }

    private mutating func loadLesson(for moduleIndex: Int) {
        guard Self.modules.indices.contains(moduleIndex) else { return }

        loadedLessonModuleIndex = moduleIndex
        lessonPages = Self.modules[moduleIndex].lessonPages
        currentLessonPageIndex = 0
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

    private static func makeModules() -> [LearnNowModuleDefinition] {
        [
            LearnNowModuleDefinition(
                id: "stats",
                title: "描述统计与数据探索",
                subtitle: "6课时",
                lessonTitle: "描述统计与数据探索",
                lessonPages: [],
                reviewTags: ["均值", "方差", "分布偏态"],
                reviewMessage: "本章的基础统计概念已归档到复习池。"
            ),
            LearnNowModuleDefinition(
                id: "probability",
                title: "概率论基础",
                subtitle: "8课时",
                lessonTitle: "概率论基础",
                lessonPages: [],
                reviewTags: ["条件概率", "贝叶斯", "随机变量"],
                reviewMessage: "概率基础卡片会在后续复习中与统计推断一起混编出现。"
            ),
            LearnNowModuleDefinition(
                id: "hypothesis",
                title: "假设检验",
                subtitle: "10课时",
                lessonTitle: "假设检验",
                lessonPages: makeHypothesisLessonPages(),
                reviewTags: ["t 检验", "P值定义", "数据稳健性"],
                reviewMessage: "智能调度系统已将考点放入你的明日复习池中。"
            ),
            LearnNowModuleDefinition(
                id: "regression",
                title: "线性回归模型",
                subtitle: "12课时",
                lessonTitle: "线性回归模型",
                lessonPages: makeRegressionLessonPages(),
                reviewTags: ["回归系数", "残差", "R²"],
                reviewMessage: "回归模型的关键概念会在你下一轮复习里与假设检验交替出现。"
            ),
        ]
    }

    private static func makeHypothesisLessonPages() -> [LearnNowLessonPage] {
        [
            LearnNowLessonPage(
                id: "hypothesis-page-1",
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
                id: "hypothesis-page-2",
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

    private static func makeRegressionLessonPages() -> [LearnNowLessonPage] {
        [
            LearnNowLessonPage(
                id: "regression-page-1",
                badge: "小节 1 / 2",
                accent: .purple,
                title: "回归系数的方向",
                summary: "在线性回归里，系数的正负先回答的是“方向”，即自变量变化时因变量是上升还是下降。",
                calloutTitle: "阅读顺序",
                calloutBody: "先看系数符号，再看绝对值大小，最后再结合显著性判断它是否值得相信。",
                calloutAccent: .blue,
                codeSample: """
                # 线性回归
                model.fit(X, y)
                print(model.coef_, model.intercept_)
                """,
                question: LearnNowLessonQuestion(
                    prompt: "如果某个特征的回归系数为 -2.1，最先可以确定的结论是什么？",
                    options: [
                        LearnNowLessonOption(id: "reg-negative-direction", badge: "A", title: "该特征增加时，目标值整体倾向下降"),
                        LearnNowLessonOption(id: "reg-strong-causality", badge: "B", title: "它一定会强力导致目标值下降"),
                    ],
                    correctOptionID: "reg-negative-direction"
                ),
                successAction: .nextPage
            ),
            LearnNowLessonPage(
                id: "regression-page-2",
                badge: "小节 2 / 2",
                accent: .amber,
                title: "R² 的边界",
                summary: "R² 衡量的是模型解释方差的能力，不是预测一定准确的保证，更不是因果强度证明。",
                calloutTitle: "常见误解",
                calloutBody: "高 R² 只能说明训练集上的拟合程度较高，仍需结合残差、验证集与业务语境一起判断。",
                calloutAccent: .pink,
                codeSample: nil,
                question: LearnNowLessonQuestion(
                    prompt: "当一个模型的 R² = 0.82 时，最稳妥的理解是什么？",
                    options: [
                        LearnNowLessonOption(id: "r2-variance-explained", badge: "A", title: "模型解释了约 82% 的目标波动"),
                        LearnNowLessonOption(id: "r2-perfect-prediction", badge: "B", title: "模型对新样本一定有 82% 的预测准确率"),
                    ],
                    correctOptionID: "r2-variance-explained"
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
