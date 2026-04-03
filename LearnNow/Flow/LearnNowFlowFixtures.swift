import Foundation

enum LearnNowFlowFixtures {
    static let modules = makeModules()

    static func makeReviewCards() -> [LearnNowReviewCard] {
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)

        return [
            LearnNowReviewCard(
                id: "mean",
                topic: "描述统计",
                moduleID: "stats",
                moduleTitle: "描述统计与数据探索",
                bucket: .new,
                accent: .mint,
                frontTitle: "均值",
                frontSubtitle: "平均数的中心位置",
                backTitle: "核心定义",
                backBody: "均值是所有样本值之和除以样本个数，用来描述一组数据的平均中心。",
                backHighlight: "极端值会显著拉动均值，偏态分布下要搭配中位数一起看。",
                dueAt: startOfToday.addingTimeInterval(-3_600),
                isMastered: false,
                isFavorited: false
            ),
            LearnNowReviewCard(
                id: "variance",
                topic: "描述统计",
                moduleID: "stats",
                moduleTitle: "描述统计与数据探索",
                bucket: .reinforce,
                accent: .mint,
                frontTitle: "方差",
                frontSubtitle: "波动程度的平方度量",
                backTitle: "理解方式",
                backBody: "方差衡量样本与均值的偏离程度，值越大说明整体离散程度越高。",
                backHighlight: "标准差 = 方差的平方根，更适合与原始数据量纲一起理解。",
                dueAt: startOfToday.addingTimeInterval(60 * 60 * 2),
                isMastered: false,
                isFavorited: true
            ),
            LearnNowReviewCard(
                id: "bayes",
                topic: "条件概率",
                moduleID: "probability",
                moduleTitle: "概率论基础",
                bucket: .new,
                accent: .purple,
                frontTitle: "贝叶斯公式",
                frontSubtitle: "先验 × 似然 / 证据",
                backTitle: "应用视角",
                backBody: "贝叶斯公式用于在新证据出现后，动态更新事件发生的后验概率。",
                backHighlight: "先验不是偏见，而是更新前的初始信息；关键是证据到来后持续修正。",
                dueAt: startOfToday.addingTimeInterval(60 * 60 * 18),
                isMastered: false,
                isFavorited: false
            ),
            LearnNowReviewCard(
                id: "p-value",
                topic: "假设检验",
                moduleID: "hypothesis",
                moduleTitle: "假设检验",
                bucket: .review,
                accent: .blue,
                frontTitle: "P值",
                frontSubtitle: "原假设为真时的极端性概率",
                backTitle: "解析",
                backBody: "P 值表示在原假设成立时，观测到当前统计结果或更极端结果的概率。",
                backHighlight: "p < 0.05 常用于拒绝原假设，但并不代表原假设只有 5% 的概率为真。",
                dueAt: startOfToday.addingTimeInterval(-60 * 60 * 10),
                isMastered: false,
                isFavorited: true
            ),
            LearnNowReviewCard(
                id: "type-one-error",
                topic: "统计推断",
                moduleID: "hypothesis",
                moduleTitle: "假设检验",
                bucket: .review,
                accent: .pink,
                frontTitle: "第一类错误",
                frontSubtitle: "弃真错误",
                backTitle: "解析",
                backBody: "第一类错误指原假设其实为真，但你却错误地拒绝了它。",
                backHighlight: "显著性水平 α 控制的就是第一类错误的长期上限风险。",
                dueAt: startOfToday.addingTimeInterval(60 * 60 * 6),
                isMastered: true,
                isFavorited: false
            ),
            LearnNowReviewCard(
                id: "regression-coef",
                topic: "线性回归",
                moduleID: "regression",
                moduleTitle: "线性回归模型",
                bucket: .reinforce,
                accent: .purple,
                frontTitle: "回归系数",
                frontSubtitle: "先看方向，再看大小",
                backTitle: "阅读顺序",
                backBody: "回归系数的正负决定变量与目标值变化的方向，绝对值描述影响幅度。",
                backHighlight: "方向不等于因果，显著性与业务语境必须一起看。",
                dueAt: calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now,
                isMastered: false,
                isFavorited: false
            ),
            LearnNowReviewCard(
                id: "r2",
                topic: "线性回归",
                moduleID: "regression",
                moduleTitle: "线性回归模型",
                bucket: .review,
                accent: .amber,
                frontTitle: "R²",
                frontSubtitle: "解释方差，不是预测准确率",
                backTitle: "常见误解",
                backBody: "R² 衡量模型解释目标变量波动的能力，不直接代表新样本预测准确率。",
                backHighlight: "高 R² 也可能过拟合，仍需结合残差与验证集表现判断。",
                dueAt: calendar.date(byAdding: .day, value: 3, to: startOfToday) ?? now,
                isMastered: true,
                isFavorited: true
            ),
        ]
    }

    private static func makeModules() -> [LearnNowModuleDefinition] {
        [
            LearnNowModuleDefinition(
                id: "stats",
                track: .statistics,
                title: "描述统计与数据探索",
                subtitle: "6课时",
                lessonTitle: "描述统计与数据探索",
                lessonPages: [],
                reviewTags: ["均值", "方差", "分布偏态"],
                reviewMessage: "本章的基础统计概念已归档到复习池。"
            ),
            LearnNowModuleDefinition(
                id: "probability",
                track: .statistics,
                title: "概率论基础",
                subtitle: "8课时",
                lessonTitle: "概率论基础",
                lessonPages: [],
                reviewTags: ["条件概率", "贝叶斯", "随机变量"],
                reviewMessage: "概率基础卡片会在后续复习中与统计推断一起混编出现。"
            ),
            LearnNowModuleDefinition(
                id: "hypothesis",
                track: .statistics,
                title: "假设检验",
                subtitle: "10课时",
                lessonTitle: "假设检验",
                lessonPages: makeHypothesisLessonPages(),
                reviewTags: ["t 检验", "P值定义", "数据稳健性"],
                reviewMessage: "智能调度系统已将考点放入你的明日复习池中。"
            ),
            LearnNowModuleDefinition(
                id: "regression",
                track: .machineLearning,
                title: "线性回归模型",
                subtitle: "12课时",
                lessonTitle: "线性回归模型",
                lessonPages: makeRegressionLessonPages(),
                reviewTags: ["回归系数", "残差", "R²"],
                reviewMessage: "回归模型的关键概念会在你下一轮复习里与假设检验交替出现。"
            ),
            LearnNowModuleDefinition(
                id: "confidence-intervals",
                track: .statistics,
                title: "置信区间、抽样误差与样本量估计",
                subtitle: "14课时",
                lessonTitle: "置信区间、抽样误差与样本量估计",
                lessonPages: makePlaceholderLessonPages(
                    moduleID: "confidence-intervals",
                    title: "置信区间、抽样误差与样本量估计",
                    accent: .mint
                ),
                reviewTags: ["置信区间", "抽样误差", "样本量"],
                reviewMessage: "这一章目前是示例课程，用来观察长标题在路线页中的排版效果。"
            ),
            LearnNowModuleDefinition(
                id: "anova",
                track: .statistics,
                title: "方差分析（ANOVA）与多组均值比较",
                subtitle: "9课时",
                lessonTitle: "方差分析（ANOVA）与多组均值比较",
                lessonPages: makePlaceholderLessonPages(
                    moduleID: "anova",
                    title: "方差分析（ANOVA）与多组均值比较",
                    accent: .blue
                ),
                reviewTags: ["ANOVA", "组间差异", "均值比较"],
                reviewMessage: "这一章目前是示例课程，用来观察中长标题在路线页中的对齐表现。"
            ),
            LearnNowModuleDefinition(
                id: "experiment-design",
                track: .statistics,
                title: "实验设计：随机化、分层与 A/B 测试入门",
                subtitle: "11课时",
                lessonTitle: "实验设计：随机化、分层与 A/B 测试入门",
                lessonPages: makePlaceholderLessonPages(
                    moduleID: "experiment-design",
                    title: "实验设计：随机化、分层与 A/B 测试入门",
                    accent: .purple
                ),
                reviewTags: ["随机化", "分层", "A/B 测试"],
                reviewMessage: "这一章目前是示例课程，用来验证多行标题和副标题的节奏是否稳定。"
            ),
            LearnNowModuleDefinition(
                id: "modeling-hypothesis",
                track: .statistics,
                title: "从业务问题到统计建模假设的完整推导",
                subtitle: "7课时",
                lessonTitle: "从业务问题到统计建模假设的完整推导",
                lessonPages: makePlaceholderLessonPages(
                    moduleID: "modeling-hypothesis",
                    title: "从业务问题到统计建模假设的完整推导",
                    accent: .amber
                ),
                reviewTags: ["业务问题", "建模假设", "推导链路"],
                reviewMessage: "这一章目前是示例课程，用来覆盖更长中文标题的视觉情况。"
            ),
        ]
    }

    private static func makePlaceholderLessonPages(
        moduleID: String,
        title: String,
        accent: LearnNowAccent
    ) -> [LearnNowLessonPage] {
        [
            LearnNowLessonPage(
                id: "\(moduleID)-page-1",
                badge: "示例 1 / 1",
                accent: accent,
                title: title,
                summary: "这是用于观察 Path 页面课程列表排版的占位章节。标题长度和换行方式会更接近真实课程场景。",
                calloutTitle: "当前用途",
                calloutBody: "这里保留最小可用课程内容，方便你直接在真实运行链路里查看标题长短不一时的对齐表现。",
                calloutAccent: .amber,
                codeSample: nil,
                question: LearnNowLessonQuestion(
                    prompt: "这个示例章节目前最主要的作用是什么？",
                    options: [
                        LearnNowLessonOption(
                            id: "\(moduleID)-layout",
                            badge: "A",
                            title: "验证课程标题在路径页中的排版、换行与对齐"
                        ),
                        LearnNowLessonOption(
                            id: "\(moduleID)-replace",
                            badge: "B",
                            title: "直接替代正式课程内容，不再需要后续补充"
                        ),
                    ],
                    correctOptionID: "\(moduleID)-layout"
                ),
                successAction: .completeLesson
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
}
