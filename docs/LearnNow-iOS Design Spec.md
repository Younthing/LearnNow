# LearnNow iOS Design Spec（SwiftUI 实现规格文档）

- 文档版本：v1
- 文档状态：Draft / 可交接初版
- 适用端：iOS（SwiftUI）
- 设计来源：`原型-Neumorphism.html`
- 目标用途：从原型迁移到 SwiftUI，实现页面拆分、组件复用、状态定义与导航落地

---

## 0. 文档说明

### 0.1 文档目标

本文档用于将 LearnNow 原型转化为可交付给 iOS 客户端开发的实现规格，重点覆盖以下内容：

1. 定义 App 的页面结构与主流程。
2. 定义全局导航、页面入口与页面出口。
3. 定义各页面的核心模块、页面级状态与交互行为。
4. 定义组件体系与复用边界。
5. 定义与 SwiftUI 落地相关的命名、目录、状态与样式约束。

### 0.2 适用范围

本文档覆盖原型中已出现的 7 个核心视图：

- Home
- Routes
- Path
- Lesson
- Completion
- Anki
- Dashboard

本文档不覆盖以下内容：

- 后端接口协议细节
- 服务端学习算法与调度算法细节
- 埋点事件字典
- 商业化策略
- 运营规则
- Android 实现差异

### 0.3 读者对象

- iOS 客户端开发
- UI/UX 设计师
- 产品经理
- QA / 测试

### 0.4 文档优先级与冲突处理

当本文档不同章节出现描述冲突时，按以下优先级处理：

1. **设计 Token 与全局规范**
2. **组件规格**
3. **页面规格**
4. **示例说明 / 备注**

进一步说明：

- 颜色、圆角、阴影、间距冲突时，以第 6 章为准。
- 组件行为冲突时，以第 4 章为准。
- 页面流转冲突时，以第 2 章为准。
- 页面内示意文案与规则冲突时，以正文规则为准。

### 0.5 命名规范

#### 页面命名

文档中统一使用以下英文页面名，不混用同义词：

- `Home`
- `Routes`
- `Path`
- `Lesson`
- `Completion`
- `Anki`
- `Dashboard`

#### SwiftUI 命名

- 页面视图统一采用 `XxxView`
- 页面 ViewModel 统一采用 `XxxViewModel`
- 组件统一采用 `PascalCase`
- 枚举统一采用 `PascalCase`
- 状态值统一采用英文语义词

示例：

- `HomeView`
- `RoutesView`
- `PathNodeCard`
- `LessonPageState`

#### 状态命名

全局统一采用以下状态语义，不重复创造近义词：

- `idle`
- `loading`
- `loaded`
- `empty`
- `error`
- `selected`
- `disabled`
- `inProgress`
- `completed`
- `locked`

### 0.6 术语表

| 术语       | 含义                                     |
| ---------- | ---------------------------------------- |
| Route      | 学习路线，代表一个学习方向或课程域       |
| Path       | 某一条学习路线下的阶段性路径与节点结构   |
| Lesson     | 一个可学习的具体课时内容                 |
| Completion | Lesson 完成后的反馈与奖励页              |
| Anki       | 复习卡片执行页，采用翻卡 + 评分式交互    |
| Dashboard  | 学习数据概览页                           |
| Token      | 视觉基础变量，如颜色、圆角、阴影、间距等 |

---

## 1. 产品结构概览

### 1.1 App 核心目标

LearnNow 是一个以“学习路径 + 课程学习 + 间隔复习 + 数据反馈”为核心闭环的学习型 App。其目标是：

- 帮助用户快速进入当前学习任务。
- 通过路线与路径展示长期学习结构。
- 通过短节奏 Lesson 完成知识吸收。
- 通过 Completion 强化成就反馈。
- 通过 Anki 将知识转化为记忆卡片。
- 通过 Dashboard 让用户理解长期掌握趋势。

### 1.2 核心功能列表

1. 学习概览与今日学习状态展示
2. 学习路线浏览与选择
3. 路线内部学习路径展示
4. 课程分页学习与随堂小测
5. 完成结算与奖励反馈
6. 复习卡片翻转与记忆评分
7. 学习数据与掌握度展示

### 1.3 全局信息架构

```text
Home
├── Continue Learning → Lesson
├── Monthly Heatmap
└── Quick Status

Routes
└── Route Card → Path
    └── Path Node → Lesson
        └── Completion
            ├── Back to Path
            └── Go to Anki

Anki
└── Flashcard Review

Dashboard
└── Memory Curve + Knowledge Mastery
```

### 1.4 页面地图（Site Map）

| 页面       | 页面级别                | 入口               | 出口                   |
| ---------- | ----------------------- | ------------------ | ---------------------- |
| Home       | Tab 根页面              | App 默认首页 / Tab | Lesson / Home 内停留   |
| Routes     | Tab 根页面              | Tab                | Path                   |
| Path       | 二级页面                | Routes             | Lesson / 返回 Routes   |
| Lesson     | 二级流程页面            | Home 或 Path       | Completion / 返回 Path |
| Completion | 流程结果页              | Lesson             | Path / Anki            |
| Anki       | Tab 根页面 / 流程可直达 | Tab / Completion   | 下一张卡 / Tab 切换    |
| Dashboard  | Tab 根页面              | Tab                | Tab 切换               |

### 1.5 主要用户主流程

#### 主流程 A：从首页继续学习

`Home → Lesson → Completion → Path 或 Anki`

#### 主流程 B：从路线进入学习

`Routes → Path → Lesson → Completion → Path`

#### 主流程 C：复习闭环

`Completion → Anki → 下一张卡 → 返回 Tab`

#### 主流程 D：查看长期学习结果

`Dashboard → 查看记忆曲线与知识掌握度`

---

## 2. 导航与路由规范

### 2.1 全局导航结构

底部全局导航采用 4 Tab 结构：

- `Home`
- `Routes`
- `Anki`
- `Dashboard`

### 2.2 路由层级定义

#### Tab 根页面

- `HomeView`
- `RoutesView`
- `AnkiView`
- `DashboardView`

#### 二级页面

- `PathView`
- `LessonView`
- `CompletionView`

### 2.3 页面进入规则

| 目标页面   | 允许入口                                      |
| ---------- | --------------------------------------------- |
| Home       | App 启动、Tab 切换                            |
| Routes     | Tab 切换                                      |
| Path       | 点击 RouteCard                                |
| Lesson     | Home 的 ContinueLearningCard；Path 的当前节点 |
| Completion | Lesson 完成                                   |
| Anki       | Tab 切换；Completion CTA                      |
| Dashboard  | Tab 切换                                      |

### 2.4 页面退出规则

| 当前页面   | 允许出口                           |
| ---------- | ---------------------------------- |
| Home       | Lesson；其他 Tab                   |
| Routes     | Path；其他 Tab                     |
| Path       | 返回 Routes；进入 Lesson；其他 Tab |
| Lesson     | 返回 Path；完成后进入 Completion   |
| Completion | 返回 Path；跳转 Anki               |
| Anki       | 下一张卡；其他 Tab                 |
| Dashboard  | 其他 Tab                           |

### 2.5 返回逻辑

1. `Path` 返回到 `Routes`。
2. `Lesson` 返回到 `Path`。
3. `Completion` 没有顶部返回按钮，主出口由 CTA 决定。
4. Tab 切换不保留视觉上的“返回关系”，但应保留页面状态恢复能力。

### 2.6 导航实现建议

#### NavigationStack

建议采用：

- `TabView` 承载 4 个根页面。
- 每个根页面内部使用独立 `NavigationStack`，或采用全局 Router 管理嵌套路径。

#### 路由枚举建议

```swift
enum AppRoute: Hashable {
    case path(routeID: String)
    case lesson(routeID: String, lessonID: String)
    case completion(routeID: String, lessonID: String)
}
```

### 2.7 深链预留

v1 不要求真实深链落地，但建议预留以下路由语义：

- `learnnow://home`
- `learnnow://routes`
- `learnnow://path/{routeID}`
- `learnnow://lesson/{lessonID}`
- `learnnow://anki`
- `learnnow://dashboard`

---

## 3. 页面规格

---

### 3.1 Home

#### 页面目标

让用户在最短时间内理解“今天该做什么”，并通过单一主入口进入当前学习内容。

#### 页面入口

- App 默认启动页
- 从底部 Tab 切回 Home

#### 页面出口

- 进入 `Lesson`
- 切换其他 Tab

#### 页面层级

- Tab 根页面

#### 页面结构

自上而下结构如下：

1. Header 区
2. 学习状态卡片
3. 今日学习统计
4. Continue Learning 区
5. 月度学习记录区
6. 底部浮动 TabBar

#### 核心模块

##### A. Header

包含：

- 页面标题“学习概览”
- 日期副标题
- 用户头像

##### B. StreakSummaryCard

展示：

- 当前状态文案
- 累计 XP
- 连胜天数

##### C. DailyStatsGrid

展示两个核心统计：

- 今日待复习卡片数
- 当前掌握度百分比

##### D. ContinueLearningCard

展示当前正在进行的课程：

- 单元与课时标签
- 课程标题
- 主 CTA（播放 / 继续学习）
- 完成进度条

##### E. MonthlyHeatmapCard

展示本月学习热力图，用于表现学习连续性。

#### 用户操作

- 点击 ContinueLearningCard 的主按钮进入 `Lesson`
- 查看本月学习记录
- 切换 Tab

#### 页面状态

- `loading`：数据加载中
- `loaded`：正常展示
- `empty`：无当前课程时，Continue 区显示空态
- `error`：数据加载失败

#### 异常状态 / 空状态

##### 无当前课程

- ContinueLearningCard 替换为空状态卡片
- CTA 改为“去选择学习路线”
- 跳转到 `Routes`

##### 无热力图数据

- 保留卡片容器
- 显示占位文案“本月尚无学习记录”

#### 导航行为

- `ContinueLearningCard` → `Lesson`

#### 依赖组件

- `HeaderBar`
- `AvatarView`
- `StreakSummaryCard`
- `DailyStatCard`
- `ContinueLearningCard`
- `HeatmapCard`
- `BottomTabBar`

#### 数据需求

- 当前日期文本
- 用户头像
- 总 XP
- 连胜天数
- 今日待复习数量
- 掌握度
- 当前 Lesson 标题
- 当前 Lesson 进度
- 月度热力图数据

#### SwiftUI 拆分建议

- `HomeView`
  - `HomeHeaderView`
  - `StreakSummaryCard`
  - `DailyStatsGrid`
  - `ContinueLearningCard`
  - `MonthlyHeatmapCard`

---

### 3.2 Routes

#### 页面目标

帮助用户浏览并选择一个学习方向，建立“学什么”的认知。

#### 页面入口

- 从底部 Tab 进入

#### 页面出口

- 进入 `Path`
- 切换其他 Tab

#### 页面层级

- Tab 根页面

#### 页面结构

1. Header 区
2. 路线卡片列表
3. 底部浮动 TabBar

#### 核心模块

##### A. Header

包含：

- 页面标题“学习路线”
- 副标题“选择你的探索方向”

##### B. RouteCardList

原型中至少包含 3 条路线：

1. 数据科学与人工智能
2. UI/UX 设计进阶
3. 全栈 Web 开发

##### C. RouteCard

每张卡片包含：

- 领域图标
- 路线名称
- 子主题说明
- 完成状态文案
- 进度条
- 右侧行动语义（继续学习 / 开始探索）

#### 用户操作

- 点击 RouteCard 进入对应 `Path`
- 切换 Tab

#### 页面状态

- `loading`
- `loaded`
- `empty`
- `error`

#### 异常状态 / 空状态

##### 路线为空

- 展示空列表占位页
- CTA：“稍后再试”或“刷新”

#### 导航行为

- 点击任一路线 → `Path`

#### 依赖组件

- `HeaderBar`
- `RouteCard`
- `ProgressBar`
- `BottomTabBar`

#### 数据需求

- 路线 ID
- 路线图标
- 路线名称
- 副标题 / 子主题
- 完成进度
- 状态文案
- 是否可继续学习

#### SwiftUI 拆分建议

- `RoutesView`
  - `RoutesHeaderView`
  - `RouteCardList`
  - `RouteCard`

---

### 3.3 Path

#### 页面目标

让用户理解某条学习路线内部的阶段结构、当前所处位置以及后续可解锁内容。

#### 页面入口

- 从 `Routes` 进入

#### 页面出口

- 返回 `Routes`
- 进入 `Lesson`
- 切换其他 Tab

#### 页面层级

- 二级页面

#### 页面结构

1. 顶部返回 Header
2. 横向阶段 Tab
3. 路径时间线
4. 节点列表

#### 核心模块

##### A. PathHeader

包含：

- 返回按钮
- 页面标题“学习路径”
- 当前路线名称

##### B. PathStageTabs

原型包含 3 个阶段 Tab：

- 统计基础
- 机器学习
- 深度学习

##### C. PathTimeline

采用纵向路径线展示节点关系。

##### D. PathNode

节点状态分为：

- `completed`
- `inProgress`
- `locked`

##### E. CurrentPathNodeCard

当前学习节点视觉突出，包含：

- 节点标题
- 课时数量
- 进行中状态
- 进度条

#### 用户操作

- 点击顶部返回按钮回到 `Routes`
- 切换阶段 Tab
- 点击当前进行中节点进入 `Lesson`
- 查看未解锁节点状态

#### 页面状态

- `loading`
- `loaded`
- `error`

页面内部业务状态：

- `selectedStage`
- `nodeStatus`

#### 异常状态 / 空状态

##### 路径节点为空

- 以空态说明替代时间线
- 显示文案“当前阶段尚无可展示内容”

##### 当前阶段全锁定

- 展示锁定说明
- 不允许进入 `Lesson`

#### 导航行为

- Back → `Routes`
- 当前 `inProgress` 节点 → `Lesson`

#### 依赖组件

- `BackButton`
- `PathHeader`
- `PillTabBar`
- `PathTimeline`
- `PathNodeItem`
- `PathCurrentNodeCard`

#### 数据需求

- 当前 route 标题
- 阶段 Tab 数据
- 节点列表
- 节点状态
- 当前节点进度

#### SwiftUI 拆分建议

- `PathView`
  - `PathHeaderView`
  - `PathStageTabBar`
  - `PathTimelineView`
  - `PathNodeRow`
  - `PathCurrentNodeCard`

---

### 3.4 Lesson

#### 页面目标

承载正式学习行为，通过“短内容 + 随堂小测 + 即时反馈”的方式完成单次知识吸收。

#### 页面入口

- `Home` 的 ContinueLearningCard
- `Path` 的当前学习节点

#### 页面出口

- 返回 `Path`
- 完成后进入 `Completion`

#### 页面层级

- 二级流程页面

#### 页面结构

1. 顶部返回 Header
2. 分段进度条
3. 横向分页内容区
4. 每一页内的内容块与小测块

#### 核心模块

##### A. LessonHeader

包含：

- 返回按钮
- 当前 Lesson 标题

##### B. SegmentProgressBar

用于表示 Lesson 内部 slide 进度。原型为 2 段。

##### C. LessonSlider

横向滑动容器，采用分页结构。

##### D. LessonSlide

每个 slide 包含：

- 小节标签
- 标题
- 正文说明
- 提示 / Callout
- 代码块（部分 slide）
- 随堂练习
- 反馈区域
- 下一步 CTA

##### E. InlineQuiz

每题包含：

- 题干
- 两个选项
- 选择反馈
- 下一步按钮

#### 用户操作

- 点击返回按钮回到 `Path`
- 横向滑动切换 slide
- 点击进度段跳转指定 slide
- 选择题目选项
- 查看即时反馈
- 进入下一 slide
- 完成所有 slide 后进入 `Completion`

#### 页面状态

页面级状态：

- `loading`
- `loaded`
- `error`
- `completed`

Lesson 过程状态：

- `currentSlideIndex`
- `quizAnswerState`
- `isSlidePassed`
- `isReadyForNextSlide`

#### 异常状态 / 空状态

##### Lesson 数据缺失

- 展示整页错误态
- CTA：“返回路径”

##### Slide 内容为空

- 跳过空 slide，不展示空白页

#### 导航行为

- Back → `Path`
- 全部 slide 完成 → `Completion`

#### 依赖组件

- `LessonHeader`
- `SegmentProgressBar`
- `LessonSlideView`
- `CalloutCard`
- `CodeBlockView`
- `QuizOptionCard`
- `QuizFeedbackCard`
- `PrimaryButton`

#### 数据需求

- Lesson 标题
- slide 列表
- slide 内容块
- quiz 题目与选项
- 正确答案
- 反馈文案
- 完成条件

#### SwiftUI 拆分建议

- `LessonView`
  - `LessonHeaderView`
  - `SegmentProgressBar`
  - `LessonSliderView`
  - `LessonSlideView`
  - `InlineQuizView`
  - `QuizOptionCard`
  - `QuizFeedbackView`

---

### 3.5 Completion

#### 页面目标

在 Lesson 完成后立即给予结果反馈、奖励反馈与下一步引导，形成学习正反馈。

#### 页面入口

- `Lesson` 完成后自动进入

#### 页面出口

- 返回 `Path`
- 进入 `Anki`

#### 页面层级

- 流程结果页

#### 页面结构

1. 完成图标 Hero 区
2. 课程完成标题
3. 奖励结算区
4. 记忆卡片生成区
5. CTA 按钮区

#### 核心模块

##### A. CompletionHero

包含：

- 完成图标
- 完成标题“课程通关”
- 入场动效

##### B. RewardSummaryCard

展示：

- 连胜保持
- XP 增长

##### C. GeneratedFlashcardsCard

展示：

- 已提炼的记忆卡数量
- 卡片标签
- 调度说明

##### D. CompletionActionGroup

包含两个 CTA：

- 完成学习（返回 `Path`）
- 去复习看板看看（进入 `Anki`）

#### 用户操作

- 查看本次学习奖励
- 查看生成的知识标签
- 返回路径继续学习
- 进入 Anki 复习

#### 页面状态

- `loaded`

若奖励计算异步化，允许扩展：

- `loading`
- `loaded`
- `error`

#### 异常状态 / 空状态

##### 无记忆卡片生成结果

- 仍展示 Completion 页面
- GeneratedFlashcardsCard 改为“本节暂无可提炼卡片”

#### 导航行为

- Primary CTA → `Path`
- Secondary CTA → `Anki`

#### 依赖组件

- `CompletionHero`
- `RewardStatCard`
- `GeneratedFlashcardsCard`
- `PrimaryButton`
- `SecondaryButton`

#### 数据需求

- 完成标题
- XP 增量
- 连胜天数
- 生成卡片数
- 卡片标签
- 调度提示文案

#### SwiftUI 拆分建议

- `CompletionView`
  - `CompletionHeroView`
  - `RewardSummaryCard`
  - `GeneratedFlashcardsCard`
  - `CompletionActionGroup`

---

### 3.6 Anki

#### 页面目标

执行记忆复习任务，让用户聚焦于“翻卡—回忆—评分—进入下一张”的单任务循环。

#### 页面入口

- 底部 Tab
- `Completion` 页面 CTA

#### 页面出口

- 继续下一张卡
- 切换其他 Tab

#### 页面层级

- Tab 根页面

#### 页面结构

1. 顶部标题区
2. 卡片类型统计标签
3. 中央 Flashcard 区
4. 评分按钮区
5. 底部浮动 TabBar

#### 核心模块

##### A. Header

包含：

- 居中标题“复习卡片”

##### B. ReviewSummaryPills

展示：

- 新卡数量
- 巩固数量
- 待复习数量

##### C. FlashcardView

采用双面卡片翻转：

- Front：术语 / 问题
- Back：解释 / 规则 / 提示

##### D. ReviewRatingButtonRow

四档评分：

- 重来
- 困难
- 良好
- 简单

#### 用户操作

- 点击卡片进行翻转
- 翻转后出现评分区
- 点击评分进入下一张卡
- 切换其他 Tab

#### 页面状态

页面级状态：

- `loading`
- `loaded`
- `empty`
- `error`

卡片状态：

- `front`
- `back`
- `submitted`

#### 异常状态 / 空状态

##### 无卡片可复习

- 中央区域显示空态卡片
- 文案：“今日复习已完成”
- CTA 可引导回 `Home` 或 `Dashboard`

#### 导航行为

- 无二级页面跳转
- 通过评分推进卡片队列

#### 依赖组件

- `HeaderBar`
- `SummaryPill`
- `FlashcardView`
- `ReviewRatingButton`
- `ReviewRatingButtonRow`
- `BottomTabBar`

#### 数据需求

- 当前卡片正面文案
- 当前卡片背面文案
- 调度区间文案
- 新卡/巩固/待复习数量
- 下一张卡信息

#### SwiftUI 拆分建议

- `AnkiView`
  - `AnkiHeaderView`
  - `ReviewSummaryPills`
  - `FlashcardContainerView`
  - `FlashcardView`
  - `ReviewRatingButtonRow`

---

### 3.7 Dashboard

#### 页面目标

以长期视角展示学习效果，帮助用户理解自己的掌握水平与遗忘趋势。

#### 页面入口

- 底部 Tab

#### 页面出口

- 切换其他 Tab

#### 页面层级

- Tab 根页面

#### 页面结构

1. Header 区
2. 记忆曲线卡片
3. 知识图谱 / 掌握度列表
4. 底部浮动 TabBar

#### 核心模块

##### A. Header

包含：

- 页面标题“学习数据”
- 副标题“你的进步雷达”

##### B. MemoryCurveCard

展示记忆曲线图表容器。

##### C. KnowledgeMasteryCard

展示多个知识点掌握度进度行。

#### 用户操作

- 查看图表
- 查看各知识点掌握度
- 切换 Tab

#### 页面状态

- `loading`
- `loaded`
- `empty`
- `error`

#### 异常状态 / 空状态

##### 无学习数据

- 图表区域显示占位说明
- 掌握度列表显示空状态

#### 导航行为

- 无页面内深层跳转

#### 依赖组件

- `HeaderBar`
- `MemoryCurveCard`
- `MasteryProgressRow`
- `BottomTabBar`

#### 数据需求

- 记忆曲线数据点
- 知识点列表
- 各知识点掌握度百分比

#### SwiftUI 拆分建议

- `DashboardView`
  - `DashboardHeaderView`
  - `MemoryCurveCard`
  - `KnowledgeMasteryList`
  - `MasteryProgressRow`

---

## 4. 组件体系规格

### 4.1 组件分层说明

组件分为三层：

#### A. Foundation Components

最小基础组件，不直接承载完整业务语义。

示例：

- `PrimaryButton`
- `SecondaryButton`
- `IconButton`
- `ProgressBar`
- `PillTag`
- `CardContainer`

#### B. Shared Business Components

跨页面复用，具备明确业务语义。

示例：

- `HeaderBar`
- `BottomTabBar`
- `RouteCard`
- `ContinueLearningCard`
- `MasteryProgressRow`
- `FlashcardView`

#### C. Composite Page Components

偏页面场景的复合模块，仅在一到两个页面复用。

示例：

- `StreakSummaryCard`
- `PathCurrentNodeCard`
- `GeneratedFlashcardsCard`
- `MemoryCurveCard`

### 4.2 全局通用组件清单

| 组件名          | 类型       | 主要用途               | 复用页面                                         |
| --------------- | ---------- | ---------------------- | ------------------------------------------------ |
| HeaderBar       | Shared     | 页面顶部标题区域       | Home / Routes / Path / Lesson / Anki / Dashboard |
| BottomTabBar    | Shared     | 底部主导航             | Home / Routes / Anki / Dashboard                 |
| PrimaryButton   | Foundation | 强主操作按钮           | Lesson / Completion / Empty State                |
| SecondaryButton | Foundation | 次级按钮               | Completion / Empty State                         |
| IconButton      | Foundation | 返回、播放等图标型按钮 | Home / Path / Lesson                             |
| ProgressBar     | Foundation | 一般进度展示           | Home / Routes / Path / Dashboard                 |
| PillTag         | Foundation | 轻量标签               | Home / Lesson / Completion / Anki                |
| CardContainer   | Foundation | 新拟态卡片底座         | 全局                                             |

### 4.3 页面复合组件清单

| 组件名                  | 所属页面   | 用途                 |
| ----------------------- | ---------- | -------------------- |
| StreakSummaryCard       | Home       | 展示 XP 与连胜状态   |
| DailyStatsGrid          | Home       | 展示今日学习统计     |
| ContinueLearningCard    | Home       | 当前课程继续学习入口 |
| HeatmapCard             | Home       | 月度学习记录         |
| RouteCard               | Routes     | 单条学习路线展示     |
| PathStageTabBar         | Path       | 阶段切换             |
| PathNodeRow             | Path       | 学习节点展示         |
| PathCurrentNodeCard     | Path       | 当前节点强调态       |
| SegmentProgressBar      | Lesson     | Lesson 内 slide 进度 |
| LessonSlideView         | Lesson     | 单页学习内容容器     |
| InlineQuizView          | Lesson     | 题目 + 反馈          |
| RewardSummaryCard       | Completion | 奖励展示             |
| GeneratedFlashcardsCard | Completion | 记忆卡生成结果       |
| FlashcardView           | Anki       | 翻转卡片             |
| ReviewRatingButtonRow   | Anki       | 评分按钮组           |
| MemoryCurveCard         | Dashboard  | 图表卡片             |
| MasteryProgressRow      | Dashboard  | 单条知识点掌握度     |

### 4.4 高优先级组件规格

#### 4.4.1 HeaderBar

##### 组件目标

提供统一顶部标题区域，支持标题、副标题、头像或返回按钮。

##### 使用场景

- 大部分页面顶部

##### 不适用场景

- Completion 全屏结果页

##### 输入参数

- `title: String`
- `subtitle: String?`
- `leading: HeaderLeadingType?`
- `trailing: HeaderTrailingType?`
- `alignment: HeaderAlignment`

##### 输出事件

- `onTapBack`
- `onTapTrailing`

##### 变体

- 标准标题型
- 返回标题型
- 居中标题型

##### SwiftUI 实现建议

使用统一 `HeaderBar` 组件，通过插槽或枚举控制 leading / trailing 区域。

#### 4.4.2 ContinueLearningCard

##### 组件目标

提供单一主入口，让用户继续当前 Lesson。

##### 使用场景

- Home

##### 不适用场景

- Routes 路线选择
- Path 节点列表

##### 输入参数

- `unitLabel`
- `lessonTitle`
- `progressValue`
- `actionTitle`
- `isPlayable`

##### 输出事件

- `onTapPrimaryAction`

##### 内部状态

- `normal`
- `disabled`

##### 复用页面

- Home

#### 4.4.3 RouteCard

##### 组件目标

展示单条学习路线的摘要信息与进入入口。

##### 使用场景

- Routes

##### 不适用场景

- Path 节点展示

##### 输入参数

- `icon`
- `title`
- `subtitle`
- `progressValue`
- `statusText`
- `actionText`
- `accentStyle`

##### 输出事件

- `onTap`

##### 变体

- `inProgress`
- `notStarted`
- `lowProgress`

#### 4.4.4 PathNodeRow

##### 组件目标

用于展示路径中的单个学习节点。

##### 输入参数

- `title`
- `desc`
- `status: PathNodeStatus`
- `progressValue: Double?`

##### 状态

- `completed`
- `inProgress`
- `locked`

##### 交互规则

- 仅 `inProgress` 可点击进入 `Lesson`
- `locked` 不可点击

#### 4.4.5 LessonSlideView

##### 组件目标

承载单页学习内容。

##### 输入参数

- `sectionLabel`
- `title`
- `bodyBlocks`
- `callout`
- `codeSnippet`
- `quiz`

##### 输出事件

- `onAnswerQuiz`
- `onTapNext`

##### 复用页面

- Lesson

#### 4.4.6 FlashcardView

##### 组件目标

提供前后翻转式记忆卡体验。

##### 输入参数

- `frontTitle`
- `frontSubtitle`
- `backContent`
- `isFlipped`

##### 输出事件

- `onTapFlip`

##### 内部状态

- `front`
- `back`

##### 交互规则

- 首次进入默认展示 `front`
- 翻转到 `back` 后才显示评分按钮区

### 4.5 组件状态规范

#### 可点击态

- 组件视觉为外凸态
- 允许触发点击反馈

#### 激活态

- 视觉可切为内凹态或强调色
- 适用于 Tab、Segment、选项卡等

#### 禁用态

- 降低对比度
- 禁止交互

#### 完成态

- 用成功色 / 勾选图标表达

#### 锁定态

- 降低透明度
- 使用锁图标

### 4.6 组件复用矩阵

| 组件               | Home | Routes | Path | Lesson | Completion | Anki | Dashboard |
| ------------------ | ---- | ------ | ---- | ------ | ---------- | ---- | --------- |
| HeaderBar          | ✓    | ✓      | ✓    | ✓      |            | ✓    | ✓         |
| BottomTabBar       | ✓    | ✓      |      |        |            | ✓    | ✓         |
| ProgressBar        | ✓    | ✓      | ✓    | ✓      |            |      | ✓         |
| PillTag            | ✓    |        | ✓    | ✓      | ✓          | ✓    |           |
| PrimaryButton      |      |        |      | ✓      | ✓          |      |           |
| IconButton         | ✓    |        | ✓    | ✓      |            |      |           |
| FlashcardView      |      |        |      |        |            | ✓    |           |
| MasteryProgressRow |      |        |      |        |            |      | ✓         |

---

## 5. 数据与状态模型

### 5.1 页面级状态定义

| 页面       | 页面状态                                     |
| ---------- | -------------------------------------------- |
| Home       | `loading` / `loaded` / `empty` / `error`     |
| Routes     | `loading` / `loaded` / `empty` / `error`     |
| Path       | `loading` / `loaded` / `error`               |
| Lesson     | `loading` / `loaded` / `completed` / `error` |
| Completion | `loaded`                                     |
| Anki       | `loading` / `loaded` / `empty` / `error`     |
| Dashboard  | `loading` / `loaded` / `empty` / `error`     |

### 5.2 组件级状态定义

| 组件               | 组件状态                                                 |
| ------------------ | -------------------------------------------------------- |
| BottomTabBarItem   | `normal` / `active`                                      |
| RouteCard          | `inProgress` / `notStarted` / `completed`                |
| PathNodeRow        | `completed` / `inProgress` / `locked`                    |
| QuizOptionCard     | `normal` / `selected` / `correct` / `wrong` / `disabled` |
| FlashcardView      | `front` / `back`                                         |
| ReviewRatingButton | `normal` / `pressed` / `disabled`                        |

### 5.3 业务实体模型建议

#### UserLearningSummary

```swift
struct UserLearningSummary {
    let totalXP: Int
    let streakDays: Int
    let reviewCountToday: Int
    let masteryPercent: Int
}
```

#### LearningRoute

```swift
struct LearningRoute: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let iconName: String
    let progress: Double
    let status: RouteStatus
}
```

#### PathNode

```swift
struct PathNode: Identifiable {
    let id: String
    let title: String
    let lessonCount: Int
    let status: PathNodeStatus
    let progress: Double?
}
```

#### LessonContent

```swift
struct LessonContent: Identifiable {
    let id: String
    let label: String
    let title: String
    let blocks: [LessonBlock]
    let quiz: Quiz?
}
```

#### Flashcard

```swift
struct Flashcard: Identifiable {
    let id: String
    let frontTitle: String
    let frontSubtitle: String?
    let backContent: String
}
```

#### MasteryTopic

```swift
struct MasteryTopic: Identifiable {
    let id: String
    let title: String
    let percent: Int
}
```

### 5.4 UI 状态枚举建议

```swift
enum LoadableState {
    case idle
    case loading
    case loaded
    case empty
    case error(message: String)
}

enum PathNodeStatus {
    case completed
    case inProgress
    case locked
}

enum QuizOptionState {
    case normal
    case selected
    case correct
    case wrong
    case disabled
}

enum FlashcardFace {
    case front
    case back
}
```

### 5.5 状态流转规则

#### Lesson

1. 页面载入完成后进入 `loaded`
2. 用户选择答案后更新选项状态
3. 显示反馈文案
4. Slide 达到通过条件后允许进入下一页
5. 最后一页完成后进入 `Completion`

#### Anki

1. 默认显示 `front`
2. 点击翻转到 `back`
3. 展示评分按钮
4. 点击评分后提交结果
5. 加载下一张卡
6. 若无下一张卡，进入 `empty`

### 5.6 异常与空状态规范

#### 统一异常页要求

- 顶部保留页面标题
- 中央展示错误说明
- 底部提供主 CTA

#### 统一空状态要求

- 保留页面基础布局
- 提供可理解的文案
- 不出现无意义空白区域

---

## 6. 视觉与交互规范

### 6.1 设计语言概述

整体视觉语言为：

- 新拟态（Neumorphism / Soft UI）
- 柔和粉彩配色
- 大圆角卡片
- 外凸与内凹并存的层级关系
- 轻量动效与柔和反馈

### 6.2 颜色 Token

以下颜色来自原型：

| Token           | 值        | 用途       |
| --------------- | --------- | ---------- |
| `bgBase`        | `#E8F0FE` | 全局背景   |
| `brandBlue`     | `#A1C4FD` | 主品牌浅蓝 |
| `brandBlueDark` | `#8AACEC` | 主强调蓝   |
| `brandPink`     | `#FFCCD5` | 粉色强调   |
| `brandPinkDark` | `#FFAAC3` | 深粉强调   |
| `brandMint`     | `#C2E9D2` | 薄荷绿     |
| `brandPurple`   | `#DBCDF0` | 紫色辅助   |
| `textMain`      | `#5C6B89` | 正文       |
| `textHeading`   | `#3B4A6B` | 标题       |
| `textMuted`     | `#8E9EBC` | 次级文字   |
| `textLight`     | `#A4B2CD` | 弱化文字   |
| `shadowDark`    | `#CDD9ED` | 阴影暗面   |
| `shadowLight`   | `#FFFFFF` | 阴影亮面   |

### 6.3 字体 Token

原型使用 `Nunito` 风格。SwiftUI 落地时建议优先映射为系统字体权重层级，除非项目要求接入自定义字体。

建议层级：

| Token       | 建议字号 | 建议字重 | 用途            |
| ----------- | -------- | -------- | --------------- |
| `displayXL` | 28       | heavy    | Completion 标题 |
| `titleL`    | 26       | bold     | 主页面标题      |
| `titleM`    | 22       | bold     | 次级页面标题    |
| `headingM`  | 18       | bold     | 区块标题        |
| `bodyM`     | 16       | semibold | 正文            |
| `bodyS`     | 14       | semibold | 说明文字        |
| `caption`   | 12       | bold     | 标签、辅助信息  |
| `micro`     | 10       | bold     | 极小标签        |

### 6.4 圆角 Token

| Token        | 值  |
| ------------ | --- |
| `radiusS`    | 8   |
| `radiusM`    | 16  |
| `radiusL`    | 24  |
| `radiusXL`   | 32  |
| `radiusPill` | 999 |

### 6.5 阴影 Token

#### 外凸态

- `neuOutSm`: `4 / 4 / 8` + `-4 / -4 / 8`
- `neuOut`: `8 / 8 / 16` + `-8 / -8 / 16`
- `neuOutLg`: `12 / 12 / 24` + `-12 / -12 / 24`

#### 内凹态

- `neuInSm`: `inset 3 / 3 / 6` + `inset -3 / -3 / 6`
- `neuIn`: `inset 6 / 6 / 12` + `inset -6 / -6 / 12`

### 6.6 间距 Token

建议映射：

| Token     | 值  |
| --------- | --- |
| `space4`  | 4   |
| `space8`  | 8   |
| `space12` | 12  |
| `space16` | 16  |
| `space20` | 20  |
| `space24` | 24  |
| `space32` | 32  |
| `space40` | 40  |

### 6.7 图标规范

- 线性图标为主
- 强调图标可辅以 fill 态
- 图标应统一在柔和风格下使用，不使用过重描边
- 建议统一由 `IconToken` 管理尺寸与颜色

### 6.8 动效规范

#### 页面切换

- 使用轻量淡入模糊过渡
- 不使用强烈位移动效

#### 按钮点击

- 轻微缩放
- 从外凸态切入内凹态

#### Completion 入场

- Hero 图标允许使用放大弹出动效
- 结果卡片采用顺序淡入上移动效

#### Anki 翻卡

- 使用 3D 翻转
- 翻转后再渐显评分区

### 6.9 反馈规范

#### 正确反馈

- 使用成功色
- 可配合轻微庆祝动效

#### 错误反馈

- 使用暖色或粉色提示
- 不使用高压警示风格

#### 加载反馈

- 轻量 Spinner 或骨架屏
- 保持整体柔和风格一致

---

## 7. SwiftUI 实现建议

### 7.1 工程目录建议

```text
App/
├── AppEntry/
├── Navigation/
├── DesignSystem/
│   ├── Tokens/
│   ├── Modifiers/
│   ├── Foundation/
│   └── Shared/
├── Features/
│   ├── Home/
│   ├── Routes/
│   ├── Path/
│   ├── Lesson/
│   ├── Completion/
│   ├── Anki/
│   └── Dashboard/
├── Models/
├── Mock/
└── Resources/
```

### 7.2 View 拆分策略

原则：

- 页面只负责布局与路由触发
- 组件负责稳定复用
- 业务状态从页面 ViewModel 向下传递

#### 示例：Home

```text
HomeView
├── HomeHeaderView
├── StreakSummaryCard
├── DailyStatsGrid
├── ContinueLearningCard
└── MonthlyHeatmapCard
```

#### 示例：Lesson

```text
LessonView
├── LessonHeaderView
├── SegmentProgressBar
└── LessonSliderView
    ├── LessonSlideView
    └── InlineQuizView
```

### 7.3 状态管理建议

#### 页面级状态

建议由 `ObservableObject` 或新式 Observation 持有，例如：

- `HomeViewModel`
- `RoutesViewModel`
- `LessonViewModel`

#### 组件级瞬时状态

建议由局部 `@State` 管理，例如：

- 卡片翻转
- 选项点击反馈显示
- Segment 当前索引

#### 跨页面导航状态

建议由统一 Router 或路径容器管理。

### 7.4 组件封装策略

#### 不要在组件内部写死业务文案

组件接收文案参数，避免只能复用于单一页面。

#### 不要在页面中重复 new 样式

新拟态样式统一封装为：

- `NeuCardModifier`
- `NeuInsetModifier`
- `NeuButtonStyle`

#### 不要将复杂业务判断放进纯展示组件

如：

- 路线是否可点击
- 卡片是否显示空态
- Lesson 是否可进入下一页

这些判断应由页面层或 ViewModel 层先完成。

### 7.5 Preview 策略

每个页面和关键组件都应提供 Preview。

至少覆盖：

- 正常态
- 空态
- 错误态
- 长文案态
- 深色模式兼容预览（即便 v1 不主打 Dark Mode，也建议预检）

### 7.6 主题与 Token 落地方式

建议通过以下结构承载 Token：

```swift
enum LNColorToken { }
enum LNRadiusToken { }
enum LNShadowToken { }
enum LNSpacingToken { }
```

并通过统一扩展映射到 SwiftUI：

```swift
extension Color {
    static let lnBackground = ...
}
```

### 7.7 图表实现建议

Dashboard 中的记忆曲线建议：

- v1 可先使用静态 mock 数据
- 采用 Swift Charts 或第三方轻量图表库
- 外层卡片由新拟态样式包裹，图表区域保持简洁

### 7.8 热力图实现建议

Home 的月度学习记录：

- v1 可采用固定网格
- 单元格根据学习强度区分填充深度
- 点击行为在 v1 可不开放，仅作为展示

---

## 8. 开发边界与待确认项

### 8.1 本期实现范围

v1 建议实现以下内容：

- 全部 7 个页面
- Tab 导航
- Routes → Path → Lesson → Completion 主流程
- Anki 翻卡与评分交互
- Dashboard 图表与掌握度展示
- 新拟态基础 Design System

### 8.2 后续扩展预留

以下能力可在后续版本补充：

- 路线搜索
- 课程收藏
- 学习提醒与通知
- 复习历史记录
- Dashboard 维度扩展
- 真实深链
- 后端数据接入与缓存恢复

### 8.3 待确认事项

1. Lesson 是否需要支持中断恢复到具体 slide。
2. Completion 的 XP 与连胜是否为真实后端数据。
3. Anki 的评分区间是否由服务端返回。
4. Heatmap 是否支持点击查看某日详情。
5. Dashboard 图表是否需要时间范围切换。
6. Routes 是否需要支持多个状态筛选。

### 8.4 风险与假设

#### 风险

- 新拟态风格在不同设备与深色模式下可能存在对比度问题。
- 多层阴影会增加视觉实现成本。
- Lesson 横向分页与内嵌交互可能增加状态同步复杂度。

#### 假设

- v1 以视觉还原与流程跑通为优先。
- 数据层可先使用 mock。
- 业务规则中未在原型中出现的部分，以最小可用策略处理。

---

## 9. 附录

### 9.1 页面与 SwiftUI 命名对照表

| 页面中文名 | 页面英文名 | SwiftUI View     | 路由标识     |
| ---------- | ---------- | ---------------- | ------------ |
| 学习概览   | Home       | `HomeView`       | `home`       |
| 学习路线   | Routes     | `RoutesView`     | `routes`     |
| 学习路径   | Path       | `PathView`       | `path`       |
| 课程学习   | Lesson     | `LessonView`     | `lesson`     |
| 完成反馈   | Completion | `CompletionView` | `completion` |
| 复习卡片   | Anki       | `AnkiView`       | `anki`       |
| 学习数据   | Dashboard  | `DashboardView`  | `dashboard`  |

### 9.2 页面 - 组件映射表

| 页面       | 核心组件                                                                                                       |
| ---------- | -------------------------------------------------------------------------------------------------------------- |
| Home       | `HeaderBar` / `StreakSummaryCard` / `DailyStatsGrid` / `ContinueLearningCard` / `HeatmapCard`                  |
| Routes     | `HeaderBar` / `RouteCard` / `ProgressBar`                                                                      |
| Path       | `PathHeader` / `PathStageTabBar` / `PathTimeline` / `PathNodeRow` / `PathCurrentNodeCard`                      |
| Lesson     | `LessonHeader` / `SegmentProgressBar` / `LessonSlideView` / `CalloutCard` / `CodeBlockView` / `InlineQuizView` |
| Completion | `CompletionHero` / `RewardSummaryCard` / `GeneratedFlashcardsCard` / `PrimaryButton`                           |
| Anki       | `HeaderBar` / `ReviewSummaryPills` / `FlashcardView` / `ReviewRatingButtonRow`                                 |
| Dashboard  | `HeaderBar` / `MemoryCurveCard` / `MasteryProgressRow`                                                         |

### 9.3 页面 - 状态映射表

| 页面       | 页面级状态                                   | 关键过程状态                            |
| ---------- | -------------------------------------------- | --------------------------------------- |
| Home       | `loading` / `loaded` / `empty` / `error`     | 无                                      |
| Routes     | `loading` / `loaded` / `empty` / `error`     | 无                                      |
| Path       | `loading` / `loaded` / `error`               | `selectedStage`                         |
| Lesson     | `loading` / `loaded` / `completed` / `error` | `currentSlideIndex` / `quizAnswerState` |
| Completion | `loaded`                                     | 无                                      |
| Anki       | `loading` / `loaded` / `empty` / `error`     | `front` / `back` / `submitted`          |
| Dashboard  | `loading` / `loaded` / `empty` / `error`     | 无                                      |

### 9.4 Token 快速索引

| 类别 | Token                                                           |
| ---- | --------------------------------------------------------------- |
| 颜色 | `bgBase` / `brandBlue` / `brandPink` / `brandMint` / `textMain` |
| 圆角 | `radiusS` / `radiusM` / `radiusL` / `radiusXL` / `radiusPill`   |
| 阴影 | `neuOutSm` / `neuOut` / `neuOutLg` / `neuInSm` / `neuIn`        |
| 间距 | `space4` ~ `space40`                                            |

### 9.5 v1 结论

当前 v1 已形成一份可用于 SwiftUI 交接的 Design Spec 初版，具备以下交付价值：

1. 页面边界明确。
2. 导航关系明确。
3. 组件复用边界明确。
4. 状态命名统一。
5. 视觉 Token 已可映射为 Design System。
6. SwiftUI 工程拆分建议已给出。

后续建议在此基础上继续补两份增强文档：

- `Component Spec v2`：展开每个组件的参数与交互状态。
- `SwiftUI Architecture v2`：补充 Router、ViewModel、Mock Data、Preview 方案。
