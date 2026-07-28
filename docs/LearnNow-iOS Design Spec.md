# LearnNow iOS Design Spec（SwiftUI 实现规格文档）

- 文档版本：v2.1
- 文档状态：Draft / 可交接修订版
- 适用端：iOS（SwiftUI）
- 最低部署目标：iOS 26.2（与当前工程配置一致，默认采用现代 SwiftUI / Observation）
- 文档性质：LearnNow iOS 设计与 SwiftUI 实现的唯一事实来源
- 目标用途：统一产品、设计、开发与测试的实现口径

---

## 0. 文档说明

### 0.1 文档目标

本文档是 LearnNow iOS 客户端的唯一事实来源，重点覆盖以下内容：

1. 定义 App 的页面结构与主流程。
2. 定义全局导航、页面入口与页面出口。
3. 定义各页面的核心模块、页面级状态与交互行为。
4. 定义组件体系与复用边界。
5. 定义与 SwiftUI 落地相关的命名、目录、状态与样式约束。

### 0.2 适用范围

本文档覆盖 LearnNow iOS 当前确认的 7 个核心视图：

- Home
- Routes
- Path
- Lesson
- Completion
- Anki
- Dashboard

本文档不覆盖以下内容：

- 后端接口协议细节
- CloudKit Public Database、内容管理后台与服务端调度器
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
- 若代码实现、demo、口头约定或评审结论与本文档冲突，以本文档为准。

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
- 页面级引用类型状态容器不强制使用 ViewModel 命名；优先采用 `XxxStore` / `XxxModel`
- 仅在存在明显异步编排、副作用协调或持久化桥接时，再使用 `XxxViewModel`
- 组件统一采用 `PascalCase`
- 枚举统一采用 `PascalCase`
- 状态值统一采用英文语义词

示例：

- `HomeView`
- `RoutesView`
- `HomeStore`
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
| Anki       | 复习卡片执行页；保持翻卡 + 评分主循环，并支持轻入口进入卡池浏览态 |
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
| Completion | 流程结果页              | Lesson             | 下一章节 Lesson / Path / Anki |
| Anki       | Tab 根页面 / 流程可直达 | Tab / Completion   | 下一张卡 / Tab 切换    |
| Dashboard  | Tab 根页面              | Tab                | Tab 切换               |

实现层说明：

- `Path`、`Lesson`、`Completion` 统一归属 `Routes` Tab 的 `NavigationStack`
- `Home` 的 Continue Learning 属于跨 Tab 触发行为，不单独拥有二级页面栈

### 1.5 主要用户主流程

#### 主流程 A：从首页继续学习

`Home → 切换至 Routes 栈中的 Lesson → Completion → 下一章节 Lesson / Path / Anki`

#### 主流程 B：从路线进入学习

`Routes → Path → Lesson → Completion → 下一章节 Lesson / Path / Anki`

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
| Lesson     | Home 的 ContinueLearningCard；Path 的当前节点；Completion 的继续学习 CTA |
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
| Completion | 进入下一 Lesson；返回 Path；跳转 Anki |
| Anki       | 下一张卡；其他 Tab                 |
| Dashboard  | 其他 Tab                           |

### 2.5 返回逻辑

1. `Path` 返回到 `Routes` 根页面。
2. `Lesson` 返回到所属 `Path`。
3. `Completion` 没有顶部返回按钮，主出口由 CTA 决定。
4. Tab 切换应保留各自独立的栈历史，不因切换而清空 `NavigationPath`。

### 2.6 导航实现规范

#### App Shell

- 根层由 `AppShellView` 持有 `TabView(selection:)`
- 底部导航视觉上采用浮动玻璃胶囊样式，但应由 App Shell 统一提供 `FloatingTabBar`
- `FloatingTabBar` 只负责展示与切换 `selectedTab`，不直接持有页面业务状态

#### NavigationStack

- 每个 Tab 使用独立 `NavigationStack`
- `Home`、`Anki`、`Dashboard` 各自拥有根级页面
- `Routes` 的栈统一承载 `RoutesView → PathView → LessonView → CompletionView`
- `Home` 的 Continue Learning 通过切换到 `Routes` Tab，并恢复或构造对应的路由链进入 `Lesson`

#### 路由与 Tab 定义

```swift
enum AppTab: Hashable {
    case home
    case routes
    case anki
    case dashboard
}

enum RoutesRoute: Hashable {
    case path(routeID: String, stageID: String? = nil)
    case lesson(routeID: String, lessonID: String)
    case completion(routeID: String, lessonID: String)
}
```

#### Router 约束

- 每个 Tab 拥有独立 Router / `NavigationPath`
- 仅 `Routes` Router 需要承载 `Path`、`Lesson`、`Completion`
- 深链和 Home continue 行为都应写入 Router，而不是通过全局 `currentScreen` 枚举切屏

### 2.7 深链语义

统一使用以下路由语义：

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

说明：

- 底部浮动 TabBar 由 `AppShellView` 提供，不属于 `HomeView` 内部层级

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

- 点击 ContinueLearningCard 的主按钮，切换到 `Routes` Tab 并进入当前 `Lesson`
- 查看本月学习记录
- 切换 Tab

#### 页面状态

- 整页：`loading` / `loaded` / `error`
- 区块：`continueSectionState` 可为 `loaded` / `empty` / `error`
- 区块：`heatmapSectionState` 可为 `loaded` / `empty` / `error`

#### 异常状态 / 空状态

##### 无当前课程

- ContinueLearningCard 替换为空状态卡片
- CTA 改为“去选择学习路线”
- 跳转到 `Routes`

##### 无热力图数据

- 保留卡片容器
- 显示占位文案“本月尚无学习记录”

#### 导航行为

- `ContinueLearningCard` → 切换 `Routes` Tab → push `Lesson`

#### 依赖组件

- `HeaderBar`
- `AvatarView`
- `StreakSummaryCard`
- `DailyStatCard`
- `ContinueLearningCard`
- `HeatmapCard`

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

#### SwiftUI 视图拆分

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

说明：

- 底部浮动 TabBar 由 `AppShellView` 提供，不属于 `RoutesView` 内部层级

#### 核心模块

##### A. Header

包含：

- 页面标题“学习路线”
- 副标题“选择你的探索方向”

##### B. RouteCardList

当前路线列表固定包含 3 条路线：

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

#### 数据需求

- 路线 ID
- 路线图标
- 路线名称
- 副标题 / 子主题
- 完成进度
- 状态文案
- 是否可继续学习

#### SwiftUI 视图拆分

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

阶段 Tab 固定为 3 项：

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

#### SwiftUI 视图拆分

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

用于表示 Lesson 内部 slide 进度。当前 Lesson 固定为 2 段。

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
- 中断后重新进入 Lesson 时，恢复到上次停留的 slide
- 完成所有 slide 后进入 `Completion`

#### 页面状态

页面级状态：

- `loading`
- `loaded`
- `error`

Lesson 过程状态：

- `currentSlideIndex`
- `lastVisitedSlideIndex`
- `quizAnswerStates`
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
- 最近停留的 slide 索引（用于恢复）

#### SwiftUI 视图拆分

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

在 Lesson 完成后立即给予结果反馈、奖励反馈与下一步引导，形成学习正反馈，并优先把用户送往下一章节而不是结束流程。

#### 页面入口

- `Lesson` 完成后自动进入

#### 页面出口

- 进入下一个可学习章节的 `Lesson`
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

说明：

- XP、连胜、奖励文案由 Catalog 与个人事件记录派生
- 不依赖服务端奖励计算结果

##### C. GeneratedFlashcardsCard

展示：

- 已提炼的记忆卡数量
- 卡片标签
- 调度说明

##### D. CompletionActionGroup

采用“续学优先、结束次之、复习降级”的 CTA 层级。

结构：

- 第一行双按钮布局
- 第二行轻量辅助动作

第一行双按钮布局：

- 左侧 `2/3` 宽度主按钮：学习下一章节
- 右侧 `1/3` 宽度次按钮：完成学习

第二行轻量辅助动作：

- 去复习看板看看（进入 `Anki`）

规则：

- `学习下一章节` 是 Completion 页默认主操作，视觉权重最高，应直接进入同一路径下一个可学习 `Lesson`
- `完成学习` 仅用于结束本轮学习并返回 `Path`，视觉上必须明显弱于 `学习下一章节`
- `去复习看板看看` 不得与第一行 CTA 同权展示，应以下一行低强调文字动作或轻量胶囊动作呈现
- 仅当本节实际生成可复习卡片时，才展示或强调 `去复习看板看看`
- 若当前路径不存在下一可学习章节，第一行应退化为单个全宽 `完成学习`，复习入口继续保持低强调

#### 用户操作

- 查看本次学习奖励
- 查看生成的知识标签
- 学习下一章节
- 完成本轮学习并返回路径
- 在有复习价值时进入 Anki 复习

#### 页面状态

- `loading`
- `loaded`
- `error`

区块状态：

- `rewardSectionState`
- `generatedFlashcardsSectionState`

#### 异常状态 / 空状态

##### 无记忆卡片生成结果

- 仍展示 Completion 页面
- GeneratedFlashcardsCard 改为“本节暂无可提炼卡片”
- `去复习看板看看` 默认隐藏，不单独制造分流噪音

#### 导航行为

- Primary CTA `学习下一章节` → 同一路径下一个可学习 `Lesson`
- Secondary CTA `完成学习` → `Path`
- Tertiary CTA `去复习看板看看` → `Anki`
- 若不存在下一可学习章节，则 Primary CTA 位置退化为 `完成学习` 返回 `Path`

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
- 是否存在下一可学习章节
- 下一章节标题
- 生成卡片数
- 卡片标签
- 调度提示文案

数据规则：

- Completion 展示数据来自 SwiftData 个人记录与 Catalog 内容，不使用运行时 mock
- 完成状态与 XP 事件在同一次本地保存中写入；`eventKey` 保证重复完成不重复奖励
- 下一章节 CTA 由 Catalog 先修关系和已完成课程集合派生，不依赖服务端即时编排

#### SwiftUI 视图拆分

- `CompletionView`
  - `CompletionHeroView`
  - `RewardSummaryCard`
  - `GeneratedFlashcardsCard`
  - `CompletionActionGroup`

---

### 3.6 Anki

#### 页面目标

执行记忆复习任务时保持“翻卡—回忆—评分—进入下一张”的单任务循环，并通过轻入口进入卡池浏览态，完成按主题、时间、课程模块与卡片状态的过滤，再回到执行态按当前范围继续复习。

#### 页面入口

- 底部 Tab
- `Completion` 页面 CTA
- 页面右上角轻入口打开卡池浏览态

#### 页面出口

- 继续下一张卡
- 打开 / 关闭卡池浏览态
- 按当前过滤范围开始复习
- 切换其他 Tab

#### 页面层级

- Tab 根页面
- 卡池浏览态以 sheet / overlay 形式覆盖在 `AnkiView` 之上，不新增底部 Tab 层级

#### 页面结构

执行态：

1. 顶部标题区
2. 卡片类型统计标签
3. 当前复习进度与范围摘要文案
4. 中央 Flashcard 区
5. 翻面后评分按钮区

浏览态（Card Pool Sheet）：

1. Sheet Header
2. 当前过滤摘要
3. Topic 过滤区
4. 时间过滤区
5. 课程模块过滤区
6. 卡片状态过滤区（已掌握 / 已收藏）
7. 过滤结果列表
8. 底部主 CTA

说明：

- 底部浮动 TabBar 由 `AppShellView` 提供，不属于 `AnkiView` 内部层级

#### 核心模块

##### A. Header

包含：

- 居中标题“复习卡片”
- 右上角轻量入口按钮，用于打开卡池浏览态
- 当存在激活中的过滤条件时，入口按钮显示过滤数量或高亮状态

##### B. ReviewSummaryPills

展示：

- 新卡数量
- 巩固数量
- 待复习数量

说明：

- 默认展示当前复习范围内的数量
- 当启用过滤范围时，Pill 反映过滤后的队列结果，而非全量卡池总数

##### C. ReviewScopeCaption

展示：

- 当前进度，例如“第 3 / 18 张”
- 当前范围摘要，例如“假设检验 · 今日到期”
- 当前卡片所属模块或到期信息的辅助信息

##### D. FlashcardView

采用双面卡片翻转：

- Front：术语 / 问题
- Back：解释 / 规则 / 提示 / 高亮记忆点

执行态卡片优化规则：

- Front 顶部仅显示 `topic` 作为轻量上下文提示
- Front 中心保留单一主问题 / 主术语，避免与辅助信息竞争
- Front 底部仅保留低强调翻转提示，不出现与评分同层级的噪音动作
- Back 以“答案标题 + 答案正文 + 重点高亮”三段式组织内容
- 执行态卡片不承载“收藏 / 已掌握”等管理动作，保持翻卡心流完整

##### E. ReviewRatingGrid

四档评分：

- 重来
- 困难
- 良好
- 简单

说明：

- 四档评分由本地 FSRS-6 调度器实时预览，间隔文案展示本次卡片的真实计算结果
- 目标记忆率为 0.90；学习步骤为 1m / 10m，重学步骤为 10m
- 评分按钮区仅在翻到背面后出现，继续保持单任务心流
- 每个评分按钮同时展示间隔说明，避免用户在记忆判断时额外猜测调度结果

##### F. CardPoolSheet

作用：

- 承担浏览态卡池能力，不打断执行态主循环

包含：

- 过滤摘要区
- Topic 多选过滤
- 时间过滤
- 课程模块多选过滤
- 状态过滤（仅看已掌握 / 仅看未掌握 / 仅看已收藏）
- 结果列表与底部 CTA

默认规则：

- 默认按 `dueAt` 升序排序，同优先级时按模块分组
- 点击底部主 CTA 后，以当前过滤结果重新构建本轮复习队列并回到执行态
- 关闭 Sheet 但未点击主 CTA 时，不修改当前执行队列

#### 用户操作

- 点击卡片进行翻转
- 翻转后出现评分区
- 点击评分进入下一张卡
- 点击 Header 轻入口打开卡池浏览态
- 在卡池浏览态中设置 / 清除过滤条件
- 使用当前过滤结果开始一轮定向复习
- 在卡池浏览态中切换“收藏 / 已掌握”状态
- 切换其他 Tab

#### 页面状态

页面级状态：

- `loading`
- `loaded`
- `empty`
- `error`

执行态卡片状态：

- `front`
- `back`
- `submitted`

浏览态状态：

- `hidden`
- `presented`
- `filtering`
- `emptyResults`

#### 异常状态 / 空状态

##### 无卡片可复习

- 中央区域显示空态卡片
- 文案：“今日复习已完成”
- CTA 可引导回 `Home` 或 `Dashboard`

##### 过滤后无结果

- 保持卡池浏览态结构不塌陷
- 结果区显示“当前筛选下暂无卡片”
- 提供 `清除筛选` 或 `返回全部卡池` 动作

#### 导航行为

- 执行态内部无二级 push 跳转
- 卡池浏览态通过 sheet / overlay 呈现，不引入新的底部层级
- 通过评分推进卡片队列
- 应用过滤后，执行态从过滤结果的第一张卡开始，默认重置为 `front`

#### 依赖组件

- `HeaderBar`
- `SummaryPill`
- `ReviewScopeCaption`
- `FlashcardView`
- `ReviewRatingButton`
- `ReviewRatingGrid`
- `CardPoolSheet`
- `CardPoolFilterSection`
- `CardPoolListItem`

#### 数据需求

- 当前卡片正面文案
- 当前卡片主题 / 所属模块
- 当前卡片背面文案
- 当前卡片高亮记忆点
- 调度区间文案
- 当前进度与当前范围总量
- 新卡 / 巩固 / 待复习数量
- 卡池中的 `dueAt` / 时间分桶信息
- `isMastered` / `isFavorited` 状态
- 过滤后的卡片结果集
- 下一张卡信息

数据规则：

- 评分按钮间隔由本地 FSRS-6 动态计算，卡片队列由 Catalog、完成状态与复习日志派生
- 第一阶段不依赖远程课程接口或服务端调度器
- 过滤条件仅作用于本地卡池派生结果，不直接改写原始卡池数据
- 卡池浏览态默认不提供自由文本搜索，优先使用结构化过滤

#### SwiftUI 视图拆分

- `AnkiView`
  - `AnkiHeaderView`
  - `ReviewSummaryPills`
  - `ReviewScopeCaption`
  - `FlashcardView`
  - `ReviewRatingGrid`
  - `CardPoolSheet`
    - `CardPoolHeader`
    - `CardPoolFilterSection`
    - `CardPoolResultList`
    - `CardPoolListItem`

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

说明：

- 底部浮动 TabBar 由 `AppShellView` 提供，不属于 `DashboardView` 内部层级

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

- 整页：`loading` / `loaded` / `error`
- 区块：`memoryCurveSectionState` 可为 `loaded` / `empty` / `error`
- 区块：`knowledgeSectionState` 可为 `loaded` / `empty` / `error`

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

#### 数据需求

- 记忆曲线数据点
- 知识点列表
- 各知识点掌握度百分比

#### SwiftUI 视图拆分

- `DashboardView`
  - `DashboardHeaderView`
  - `MemoryCurveCard`
  - `KnowledgeMasteryList`
  - `MasteryProgressRow`

---

## 4. 组件体系规格

### 4.1 组件分层说明

组件分为四层：

#### A. App Shell Components

由 App 根壳层统一持有，不下沉到页面内部。

示例：

- `FloatingTabBar`

#### B. Foundation Components

最小基础组件，不直接承载完整业务语义。

示例：

- `PrimaryButton`
- `SecondaryButton`
- `IconButton`
- `ProgressBar`
- `PillTag`
- `CardContainer`

#### C. Shared Business Components

跨页面复用，具备明确业务语义。

示例：

- `HeaderBar`
- `RouteCard`
- `ContinueLearningCard`
- `MasteryProgressRow`
- `FlashcardView`

#### D. Composite Page Components

偏页面场景的复合模块，仅在一到两个页面复用。

示例：

- `StreakSummaryCard`
- `PathCurrentNodeCard`
- `GeneratedFlashcardsCard`
- `MemoryCurveCard`

### 4.2 全局通用组件清单

| 组件名          | 类型       | 主要用途                               | 复用页面                                         |
| --------------- | ---------- | -------------------------------------- | ------------------------------------------------ |
| FloatingTabBar  | AppShell   | App 壳层主导航；维护 `selectedTab` 展示 | AppShell                                         |
| HeaderBar       | Shared     | 页面顶部标题区域                       | Home / Routes / Path / Lesson / Anki / Dashboard |
| PrimaryButton   | Foundation | 强主操作按钮                           | Lesson / Completion / Empty State                |
| SecondaryButton | Foundation | 次级按钮                               | Completion / Empty State                         |
| IconButton      | Foundation | 返回、播放等图标型按钮                 | Home / Path / Lesson                             |
| ProgressBar     | Foundation | 一般进度展示                           | Home / Routes / Path / Dashboard                 |
| PillTag         | Foundation | 轻量标签                               | Home / Lesson / Completion / Anki                |
| CardContainer / SoftCard / InsetCard | Foundation | 双主题玻璃卡片底座（外凸 / 内陷）     | 全局                                             |

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
| CompletionActionGroup   | Completion | 续学优先的 CTA 分流  |
| FlashcardView           | Anki       | 翻转卡片             |
| ReviewScopeCaption      | Anki       | 当前复习进度与范围摘要 |
| ReviewRatingGrid        | Anki       | 评分按钮组           |
| CardPoolSheet           | Anki       | 浏览态卡池与过滤容器 |
| CardPoolListItem        | Anki       | 卡池浏览态单卡摘要行 |
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

##### SwiftUI 实现约束

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

提供前后翻转式记忆卡体验，在不打断心流的前提下承载主题上下文、答案正文与重点提示。

##### 输入参数

- `topic`
- `frontTitle`
- `frontSubtitle`
- `backTitle`
- `backContent`
- `backHighlight`
- `isFlipped`

##### 输出事件

- `onTapFlip`

##### 内部状态

- `front`
- `back`

##### 交互规则

- 首次进入默认展示 `front`
- 翻转到 `back` 后才显示评分按钮区
- 执行态不放置卡片管理动作，避免与评分按钮争夺主操作层级

#### 4.4.7 CardPoolSheet

##### 组件目标

承载复习卡池的浏览与过滤能力，并在确认后将当前过滤结果应用到执行态。

##### 输入参数

- `cards`
- `selectedTopics`
- `selectedModules`
- `selectedTimeFilter`
- `masteryFilter`
- `favoriteFilter`
- `sortMode: FlashcardSortMode`

##### 输出事件

- `onUpdateFilters`
- `onResetFilters`
- `onApplyFilteredQueue`
- `onDismiss`
- `onToggleMastered`
- `onToggleFavorited`

##### 内部状态

- `presented`
- `filtering`
- `emptyResults`

##### 交互规则

- 打开时继承当前 `activeReviewScope` 与已选过滤条件
- 任一过滤条件变化后，结果列表即时刷新
- 点击主 CTA 才真正应用过滤结果并重建执行队列
- 关闭、下滑 dismiss 或点按遮罩仅关闭浏览态，不改动当前执行队列

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

- 用 `brand`（翡翠）+ 勾选图标共同表达，不得仅靠颜色

#### 锁定态

- 降低透明度
- 使用锁图标

### 4.6 组件复用矩阵

说明：

- AppShell 级组件不进入页面复用矩阵，`FloatingTabBar` 统一由根壳层持有

| 组件               | Home | Routes | Path | Lesson | Completion | Anki | Dashboard |
| ------------------ | ---- | ------ | ---- | ------ | ---------- | ---- | --------- |
| HeaderBar          | ✓    | ✓      | ✓    | ✓      |            | ✓    | ✓         |
| ProgressBar        | ✓    | ✓      | ✓    | ✓      |            |      | ✓         |
| PillTag            | ✓    |        | ✓    | ✓      | ✓          | ✓    |           |
| PrimaryButton      |      |        |      | ✓      | ✓          |      |           |
| IconButton         | ✓    |        | ✓    | ✓      |            |      |           |
| FlashcardView      |      |        |      |        |            | ✓    |           |
| ReviewScopeCaption |      |        |      |        |            | ✓    |           |
| CardPoolSheet      |      |        |      |        |            | ✓    |           |
| MasteryProgressRow |      |        |      |        |            |      | ✓         |

---

## 5. 数据与状态模型

### 5.0 数据边界与启动状态

- 课程作者源为受限 Markdown/YAML，经 `learnnow-content` 编译为强类型
  `CatalogV2.json`；App 优先加载已验证的 last-known-good，缺失时使用 Bundle 基线。
- 内容更新使用签名 manifest、完整文件 SHA-256 校验和原子切换；远程内容只能组合 App
  已发布的白名单 capability，不能下发脚本或新组件代码。
- 个人进度、XP 事件、复习日志和卡片偏好由 SwiftData 保存；在有效云同步订阅且用户打开偏好后，同步到 Private CloudKit（`activeCloudSync = preference && isSubscribed`）。未订阅时设置页仅显示升级入口；课程 / 复习 / 路径本身保持免费。
- `ReviewScheduleCacheRecord` 仅是本地派生缓存；`ReviewLogRecord` 是复习调度的真相源。
- 主题和提醒偏好保存在设备 `UserDefaults` / `AppStorage` 边界，不参与 CloudKit 同步。
- 云同步偏好默认关闭；关闭或订阅过期后下次启动不再挂接 CloudKit，不删除本机与云端已有记录。
- 启动状态明确区分 `loading`、`ready`、`catalogError` 和 `persistenceError`；iCloud 不可用时进入“仅本机”，不阻塞学习。
- CloudKit 实体不使用唯一约束或持久化对象关系，重复记录在读取快照时按业务规则确定性合并。

### 5.1 页面级状态定义

页面级状态仅用于“整页无法渲染主要内容”的场景。局部卡片、图表或热力图是否为空，应由 section state 表达，而不是把整页统一打成 `empty`。

| 页面       | 整页状态                                 | 关键区块 / 过程状态                                                  |
| ---------- | ---------------------------------------- | -------------------------------------------------------------------- |
| Home       | `loading` / `loaded` / `error`           | `continueSectionState` / `heatmapSectionState`                       |
| Routes     | `loading` / `loaded` / `empty` / `error` | 无                                                                   |
| Path       | `loading` / `loaded` / `error`           | `selectedStage` / `timelineSectionState`                             |
| Lesson     | `loading` / `loaded` / `error`           | `currentSlideIndex` / `lastVisitedSlideIndex` / `quizAnswerStates` / `isReadyForNextSlide` |
| Completion | `loading` / `loaded` / `error`           | `rewardSectionState` / `generatedFlashcardsSectionState`             |
| Anki       | `loading` / `loaded` / `empty` / `error` | `currentFace` / `cardPoolPresentationState` / `activeReviewScope` / `selectedCardFilters` |
| Dashboard  | `loading` / `loaded` / `error`           | `memoryCurveSectionState` / `knowledgeSectionState`                  |

### 5.2 组件级状态定义

| 组件               | 组件状态                                                 |
| ------------------ | -------------------------------------------------------- |
| FloatingTabBarItem | `normal` / `active`                                      |
| RouteCard          | `inProgress` / `notStarted` / `completed`                |
| PathNodeRow        | `completed` / `inProgress` / `locked`                    |
| QuizOptionCard     | `normal` / `selected` / `correct` / `wrong` / `disabled` |
| FlashcardView      | `front` / `back`                                         |
| ReviewRatingButton | `normal` / `pressed` / `disabled`                        |
| ReviewScopeCaption | `default` / `filtered`                                   |
| CardPoolFilterChip | `default` / `selected`                                   |
| CardPoolListItem   | `default` / `mastered` / `favorited`                     |

### 5.3 业务实体模型

#### 持久化实体

| 实体 | 职责 | 合并规则 |
| --- | --- | --- |
| `LessonProgressRecord` | 最后页面、最高页面、完成时间 | 完成优先、页序取最大 |
| `LearningEventRecord` | XP、连胜与热力图事件 | 按业务 `eventKey` 幂等聚合 |
| `ReviewLogRecord` | 评分及 FSRS 调度结果 | append-only，按时间与 UUID 确定顺序 |
| `CardPreferenceRecord` | 收藏与手动掌握 | 最后写入优先 |
| `ReviewScheduleCacheRecord` | FSRS 当前状态缓存 | 可由复习日志重建，仅本地保存 |

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
    let topic: String
    let moduleID: String
    let moduleTitle: String
    let bucket: FlashcardBucket
    let frontTitle: String
    let frontSubtitle: String?
    let backTitle: String
    let backContent: String
    let backHighlight: String?
    let dueAt: Date
    var isMastered: Bool
    var isFavorited: Bool
}
```

#### FlashcardFilterSet

```swift
struct FlashcardFilterSet {
    var topics: Set<String>
    var moduleIDs: Set<String>
    var time: FlashcardTimeFilter
    var mastery: FlashcardMasteryFilter
    var favorite: FlashcardFavoriteFilter
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

### 5.4 UI 状态枚举

```swift
enum ScreenLoadState {
    case loading
    case loaded
    case error(message: String)
}

enum SectionLoadState<Value> {
    case loading
    case loaded(Value)
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
    case submitted
}

enum CardPoolPresentationState {
    case hidden
    case presented
}

enum FlashcardBucket {
    case new
    case reinforce
    case review
}

enum FlashcardTimeFilter {
    case all
    case overdue
    case today
    case nextThreeDays
    case thisWeek
}

enum FlashcardMasteryFilter {
    case all
    case masteredOnly
    case unmasteredOnly
}

enum FlashcardFavoriteFilter {
    case all
    case favoritedOnly
}

enum FlashcardSortMode {
    case dueAtAscending
    case module
}

enum ActiveReviewScope {
    case fullDeck
    case filtered(FlashcardFilterSet)
}

struct LessonResumeState {
    let lessonID: String
    var lastVisitedSlideIndex: Int
}
```

### 5.5 状态流转规则

#### Lesson

1. 页面载入完成后进入 `loaded`
2. 若存在本地保存的 `lastVisitedSlideIndex`，进入时恢复到对应 slide
3. 用户选择答案后更新选项状态
4. 显示反馈文案
5. Slide 达到通过条件后允许进入下一页
6. 切换 slide 时更新本地恢复索引
7. 最后一页完成后 push 到 `Completion`，而不是在 `Lesson` 内停留 `completed`

#### Anki

1. 默认显示 `front`
2. 点击翻转到 `back`
3. 翻转后展示答案、高亮记忆点与评分按钮
4. 点击评分后提交结果
5. 加载当前范围内的下一张卡
6. 用户可随时打开卡池浏览态，调整 Topic / 时间 / 模块 / 状态过滤
7. 用户可在卡池浏览态切换 `收藏 / 已掌握` 状态
8. 点击“按当前筛选开始复习”后，更新 `activeReviewScope` 与执行队列，并回到第一张匹配卡
9. 若过滤后无结果，卡池浏览态进入 `emptyResults`
10. 若当前范围无下一张卡，执行态进入 `empty`

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

整体视觉语言定义为：

- 低饱和中性画布 + 单一品牌色低透明静谧光（主题品牌色驱动 Ambient Glow）
- 原生 `ultraThinMaterial` 毛玻璃表面
- 表面与文字保持中性、不带可感知色相；颜色只用于表达含义（品牌、状态、内容区分）
- **五套可切换主题**（清水翡翠 / 暖沙米白 / 墨青素笺 / 石墨素灰 / 柔陶暖灰），每套各自具备日间 / 夜间派生；日夜模式与主题选择独立
- 以弹簧为主的物理反馈交互
- 保留外凸 / 内陷层级关系，但不再依赖传统双向新拟态阴影

不再使用的旧规范：蓝 / 紫 / 薄荷三色 Ambient Glow、夜间电影感（Dark Cinematic）高饱和发光 accent，均已废弃。

### 6.2 主题模式策略

- App 主题由设置页 `selectedTheme`（`LearnNowTheme`）选择，持久化到 `UserDefaults`（`learnnow.settings.theme`），默认 `emerald`（清水翡翠）
- 夜间模式（`isNightModeEnabled`）独立于主题：每套主题都有 light / dark 两套 Token；夜间开关只切换 `preferredColorScheme`
- 颜色 Token 必须通过动态 provider 生成；实现采用 `Color.dynamic(light:dark:)` + `UIColor(dynamicProvider:)`
- 业务页继续消费 `LearnNowPalette` / `LearnNowSemanticRole`；二者从 `LearnNowThemeCatalog.tokens(for: LearnNowThemeStore.current)` 计算取值。主题切换时根视图以 `.id(selectedTheme)` 失效重绘，并由根同步 `LearnNowThemeStore`
- 非法 / 缺失的 theme raw value 回落 `emerald`
- 夜间主题目标为 Quiet Dark：近黑中性画布、半透明中性深色玻璃、克制的品牌色点缀
- 日间主题目标为 Light Glassmorphism：中性画布、低透明白色（或微暖 / 微冷）玻璃、安静低饱和的语义色

五套主题气质：

| ID | 名称 | 气质 | Brand 色相 |
| --- | --- | --- | --- |
| `emerald` | 清水翡翠 | 珍珠白 + 雾翡翠（默认） | 绿 |
| `sand` | 暖沙米白 | 米白纸感 + 软陶棕 | 暖棕琥珀 |
| `ink` | 墨青素笺 | 冷灰画布 + 青墨 | 低饱和青蓝（非系统蓝） |
| `graphite` | 石墨素灰 | 中性灰石 + 炭黑强调 | 冷灰 |
| `clay` | 柔陶暖灰 | 暖灰粉画布 + 陶土 | 低饱和陶红（非深红） |

### 6.3 颜色 Token

以下 Token 以 `LearnNowThemeCatalog` → `LearnNowPalette` / `LearnNowSemanticRole` 为事实标准。色板分为三层：中性基底、语义角色、内容色。下表以默认主题 **清水翡翠（`emerald`）** 为基准值；其余四套同结构，数值见 `LearnNowTheme.swift`。

#### 中性基底（文字与表面不带可感知色相）

| Token           | Light                       | Dark                        | 用途 |
| --------------- | --------------------------- | --------------------------- | ---- |
| `canvas`        | `#F4F6F5`                   | `#0B0D0C`                   | 全局画布底色 |
| `glassBase`     | `#FFFFFF @ 58%`            | `#181C1A @ 65%`            | 毛玻璃表面底漆 |
| `surfaceOpaque` | `#F9FBFA`                   | `#181C1A`                   | 无障碍降级用不透明表面 |
| `textPrimary`   | `#1E2522 @ 100%`           | `#F3F6F4 @ 95%`            | 标题、核心信息 |
| `textSecondary` | `#4A5551 @ 100%`           | `#C3CCC8 @ 100%`           | 说明文、次级正文 |
| `textMuted`     | `#7E8985 @ 100%`           | `#8B9691 @ 100%`           | 弱化标签、未选中状态 |
| `shadowDark`    | 中性灰黑                    | 中性灰黑                    | 深度阴影，仅微调不透明度 |
| `shadowLight`   | 中性白高光                  | 中性白高光                  | 保留给高光或极浅边缘 |

#### 品牌与语义角色（`LearnNowSemanticRole`）

语义角色为 `brand` / `warning` / `danger` / `neutral` 四种，每种角色提供 `foreground` / `softFill` / `onFill` / `stroke` 四个 Token。语义角色只服务 UI 自身决定的颜色（CTA、进度、状态），不进入内容协议。`warning` / `danger` 跨主题保持灰金 / 灰玫瑰，不跟 brand 抢戏。

| 角色      | Light（emerald）                              | Dark（emerald）               | 用途 |
| --------- | -------------------------------------------- | ----------------------------- | ---- |
| `brand`   | 前景 `#0B7A5C`；渐变 `#0B7A5C → #0D9A6B`；soft `#DEF2E9`；onBrand 白 | 前景 `#5FD3A6`；soft `#163529`；onBrand `#07110D` | 主行动 CTA、进度、正确 / 完成状态、品牌表达 |
| `warning` | 前景 `#8C6410`；soft `#F6EEDA`              | 前景 `#E0C06A`；soft `#2B2416` | 提醒、告警但非危险态（沙金） |
| `danger`  | 前景 `#B4434E`；soft `#F8E7E9`              | 前景 `#EC9AA2`；soft `#2F1D20` | 错误、答错反馈（灰玫瑰） |
| `neutral` | 复用中性文字 / 描边 Token                    | 复用中性文字 / 描边 Token      | 锁定、XP、普通信息 |

#### 内容色（`LearnNowPalette.color(for:)` 映射，安静但可分辨的 5 色相）

`ContentAccent` / `LearnNowAccent` 的 raw value（blue / pink / mint / purple / amber）保持不变以兼容既有内容，仅在映射层按主题换血：

| Raw value | 实际色相（emerald） | Light     | Dark      |
| --------- | -------- | --------- | --------- |
| `mint`    | 翡翠（与品牌同族） | `#0F7258` | `#66CDA8` |
| `blue`    | 青灰蓝   | `#4A7089` | `#8FB8CE` |
| `purple`  | 青瓷     | `#337873` | `#7CC7C0` |
| `amber`   | 沙金     | `#8C6410` | `#D9BC6E` |
| `pink`    | 灰玫瑰   | `#A4525C` | `#DA9AA3` |

补充规则：

- 颜色管道保持：ContentAccent（内容层）→ LearnNowAccent（UI 层）→ LearnNowPalette（唯一 hex 出口）。
- 表面与文字回归中性，不做全局品牌色浸染；颜色只用于表达含义。
- 不把 `ContentAccent` 当作 App 主题；App 主题只走 `LearnNowTheme`。
- 不再使用高饱和 `accentBlue` / `accentPink` / `accentPurple` 一类旧 accent 常量作为规范基准。
- 新增颜色应优先作为动态 Token 接入，不允许只定义单一模式颜色。
- 实施时以对比度校验结果微调 hex（正文 4.5:1、大字与 UI 部件 3:1），本表为基准值；用 `scripts/tmp_contrast_check.py` 覆盖 5 套 × light/dark。

### 6.4 字体 Token

全局统一使用系统圆角字形，即 `.system(..., design: .rounded)`；仅代码或数字密集区可使用 monospaced 变体。

| Token       | 字号 | 字重 | 用途 |
| ----------- | ---- | ---- | ---- |
| `displayXL` | 32       | black    | Completion 标题、核心 hero 数值 |
| `titleL`    | 26       | heavy    | 顶级页面标题 |
| `titleM`    | 20       | heavy    | 区块标题、重点卡片标题 |
| `headingM`  | 18       | heavy    | 页面导航标题、一级操作文案 |
| `bodyM`     | 16       | semibold | 标准正文、按钮标题 |
| `bodyS`     | 14       | bold     | 辅助说明、列表副文本 |
| `caption`   | 13       | bold     | 标签、状态说明、统计单位 |
| `micro`     | 10       | heavy    | 极小标签 |
| `codeS`     | 13       | medium   | 代码块、等宽信息 |

### 6.5 圆角 Token

| Token         | 值  | 典型用途 |
| ------------- | --- | -------- |
| `radiusXS`    | 11  | Heatmap 单元、微型状态点 |
| `radiusS`     | 18  | 小型按钮、紧凑卡片、Quiz 选项 |
| `radiusM`     | 22  | InsetCard、评分按钮、内陷区域 |
| `radiusL`     | 26  | 主卡片、SoftCard |
| `radiusXL`    | 32  | Flashcard、大尺寸 Hero 容器 |
| `radiusPill`  | 999 | Pill、Capsule、浮动 Tab Bar |

补充规则：

- 圆形按钮与圆形状态容器使用 `size / 2` 推导，不单独定义额外 token。
- 新组件优先复用现有半径层级，避免在 `20~28` 区间随意新增相邻值。

### 6.6 表面与材质规范

当前设计系统以“材质 + 深度 + 高光描边”替代旧式双阴影新拟态。

#### 外凸玻璃表面（`OuterSurface`）

- 底层使用 `glassBase`
- 背景默认使用系统 `.ultraThinMaterial`
- `Reduce Transparency` / `Increase Contrast` 时降级为不透明 `surfaceOpaque`（见 6.12）
- `Increase Contrast` 时叠加 `1pt`、对背景 ≥`3:1` 的中性描边（`textSecondary`）
- 默认态增加 `0.5pt` 白色至透明的对角渐变高光描边
- 使用单一纵向深度阴影：`radius 16 / y 8`
- 适用于主卡片、浮动 Tab Bar、未按下按钮、默认胶囊控件
- 底部操作条等通栏材质复用同一降级逻辑（`learnNowBarBackground` / `BarMaterialBackground`）

#### 内陷玻璃表面（`InsetSurface`）

- 背景使用低透明黑色底漆：夜间 `35%`，日间 `5%`
- 外层使用白色描边：夜间 `5%`，日间 `40%`
- 使用较轻的深度阴影：`radius 8 / y 4`
- 适用于选中态、输入态、按下态、进度轨道、内嵌槽位

#### 交互按压态（`SoftPressStyle`）

- 默认态为 `OuterSurface`
- 按下态切换为 `InsetSurface`
- 同步缩放到 `0.96`
- 同步透明度降到 `0.9`
- 目的是形成明显的确认感与阻尼回弹，而不是简单的透明度闪烁

### 6.7 背景与环境光规范

- 全局背景分为两层：底层 `canvas`，其上为 `BackgroundGlow`
- 环境光为当前主题 `brand` 前景色的低透明静谧光，由两层光斑组成，不透明度约 `0.10–0.16`
- 不再使用蓝 / 紫 / 薄荷三色漫游光球
- 动效采用 `withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true))`
- 环境光仅服务于氛围与层次，不应影响正文识别、点击反馈或可访问性对比度
- `Reduce Transparency` 时整体隐藏 `BackgroundGlow`（见 6.12）

### 6.8 间距 Token

标准映射：

| Token      | 值   | 用途 |
| ---------- | ---- | ---- |
| `space8`   | 8    | 紧凑元素间距 |
| `space12`  | 12   | 胶囊 / Tab Bar 内边距 |
| `space16`  | 16   | 小型操作组、图标与文字组合 |
| `space18`  | 18   | 页面内互动模块组 |
| `space20`  | 20   | InsetCard 内容内边距 |
| `space24`  | 24   | 页面横向边距、主卡片节奏 |
| `space32`  | 32   | 大区块分隔 |
| `space60`  | 60   | Scroll 内容底部呼吸区 |
| `space112` | 112  | 为浮动底栏预留的底部安全空间 |

### 6.9 图标规范

- 统一以 `SF Symbols` 为主
- 默认使用线性图标，关键操作与选中态可使用 `bold` 或 `fill` 倾向
- 未选中图标优先使用 `textMuted`
- 强调图标使用对应 accent 色，不使用单独的品牌金属色
- 图标按钮应优先放置在圆形玻璃表面中，以保证热区和视觉一致性

### 6.10 动效规范

#### 全局切换

- 页面或主屏切换优先使用弹簧：`.spring(response: 0.4, dampingFraction: 0.75)`
- 避免机械的线性过渡和大幅硬切位移

#### 按压反馈

- 按钮点击使用 `.spring(response: 0.3, dampingFraction: 0.6)`
- 结合 `scale 0.96`、透明度轻微下降和表面外凸 / 内陷切换

#### 环境光与列表入场

- 背景翡翠环境光使用 8 秒往返漫游，形成持续呼吸感
- 路径节点等序列化内容可使用 `delay(index * 0.1)` 的顺序弹入
- 节点弹入参数采用 `.spring(response: 0.5, dampingFraction: 0.8)`

#### 特殊场景

- Completion 可保留轻度庆祝性弹入，但避免粒子、旋转、缩放同时叠加
- Anki 翻卡继续使用 3D 翻转，评分区出现时配合短弹簧或淡入

### 6.11 反馈规范

#### 状态色语义

反馈状态统一映射到语义角色，不再使用旧 accent 常量：

- 正确 / 完成 = `brand`（翡翠）
- 错误 / 答错 = `danger`（灰玫瑰）
- 提醒 / 低风险告警 = `warning`（沙金）

#### 图标伴随规则

- 所有状态反馈必须伴随图标（如正确 / 完成用 `checkmark`、错误用 `xmark`、提醒用 `exclamationmark` 系），不得仅靠颜色表达状态
- 同为 `brand` 的“进行中”与“已完成”通过填充样式 + checkmark 图标区分，不引入第二个绿色

#### 正向反馈

- 成就类反馈使用 `brand` 或 `neutral` + 图标，不再使用粉色成就强调
- 反馈应体现“提升感”，避免使用过于廉价的闪烁效果

#### 错误与提醒反馈

- 不使用高压纯红警告风格，避免破坏整体高级感

#### 加载与占位反馈

- 加载状态优先保持当前玻璃容器稳定，只替换内部内容
- 可使用轻量 Spinner、骨架屏或渐隐占位，不应让背景层级发生突变

### 6.12 可访问性与适配规范

- Light / Dark 双主题均为正式交付范围，不能只校验单一模式
- 文本应优先映射系统 `TextStyle` 或结合 `@ScaledMetric`，避免依赖固定高度卡片承载多行文案
- 正文文本与背景对比度应以可读性优先；若玻璃材质导致对比不足，应优先提升底漆、描边或文字不透明度
- 所有可点击控件最小热区不小于 `44x44pt`
- 纯图标按钮必须提供 `accessibilityLabel`
- Progress、Flashcard 正反面、评分按钮应提供清晰的 VoiceOver 语义
- `Reduce Motion` 下应将环境光漫游、Completion 弹入、Anki 翻卡退化为淡入淡出或轻微缩放
- `Increase Contrast`（`colorSchemeContrast == .increased`）下：卡片与关键表面改用不透明表面 `surfaceOpaque`，并叠加对比度至少 `3:1` 的 `1pt` 边界描边
- `Reduce Transparency` 下：关闭毛玻璃模糊（材质降级为 `surfaceOpaque`）并关闭 `BackgroundGlow` 环境光

---

## 7. SwiftUI 实现规范

### 7.1 工程目录规范

```text
App/
├── AppEntry/
├── AppShell/
├── Navigation/
│   ├── AppTab/
│   ├── Routers/
│   └── Destinations/
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

### 7.2 View 拆分规则

原则：

- App Shell 负责 `selectedTab`、浮动 TabBar 和各 Tab 的 `NavigationStack`
- 页面只负责布局与路由触发
- 组件负责稳定复用
- 业务状态从 feature model / store 向下传递

#### App Shell

```text
AppShellView
├── TabView(selection:)
├── Home NavigationStack
├── Routes NavigationStack
│   ├── RoutesView
│   ├── PathView
│   ├── LessonView
│   └── CompletionView
├── Anki NavigationStack
├── Dashboard NavigationStack
└── FloatingTabBar
```

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

### 7.3 状态管理规范

#### 默认方案

当前工程最低版本为 iOS 26.2，采用新式 Observation：

- 根层使用 `@State` 持有 `@Observable LearnNowAppStore`
- `LearnNowAppStore` 只编排 Catalog 加载、仓库写入、FSRS 调度和用户动作
- `LearnNowRouter` 管理顶级 Tab 与 Routes 子流程跳转
- `CatalogRepository` 和 `LearningRepository` 隔离内容来源与 SwiftData 持久化
- ScreenModel 保持纯展示模型，视图不直接读取 SwiftData 实体
- 不使用 `ObservableObject` / `@EnvironmentObject`

#### 何时使用 ViewModel

仅在以下场景引入 `XxxViewModel`：

- 明确存在网络请求编排、取消、重试
- 需要桥接持久化 / 缓存层
- 需要聚合多个 service 的副作用

#### 组件级瞬时状态

以下瞬时状态由局部 `@State` 管理：

- 卡片翻转
- 选项点击反馈显示
- Segment 当前索引

#### 跨页面导航状态

跨页面导航状态由 `LearnNowRouter` 统一解释；当前稳定舞台式 App Shell 保留现有展示模型，后续迁移到独立 `NavigationStack` 时不改变仓库接口。

### 7.4 组件封装规范

#### 不要在组件内部写死业务文案

组件接收文案参数，避免只能复用于单一页面。

#### 不要在页面中重复拼装样式

玻璃表面样式统一封装为：

- `OuterSurface`
- `InsetSurface`
- `SoftPressStyle`
- `BackgroundGlow`

#### 不要将复杂业务判断放进纯展示组件

如：

- 路线是否可点击
- 卡片是否显示空态
- Lesson 是否可进入下一页

这些判断应由页面层或 feature model / store 层先完成。

### 7.5 Preview 策略

每个页面和关键组件都应提供 Preview。

至少覆盖：

- 正常态
- 空态
- 错误态
- 长文案态
- 日间 / 夜间双主题预检（必须）
- Dynamic Type 大字号预览
- Increased Contrast 预览
- Reduce Motion 预览

### 7.6 主题与 Token 落地

统一通过以下结构承载 Token：

```swift
enum LearnNowPalette { }
enum LNRadiusToken { }
enum LNSpacingToken { }
```

并通过统一扩展与样式层映射到 SwiftUI：

```swift
extension Color {
    static func dynamic(light: UInt, dark: UInt, lightOpacity: Double = 1.0, darkOpacity: Double = 1.0) -> Color
}
```

```swift
struct OuterSurface: ViewModifier { }
struct InsetSurface: ViewModifier { }
struct SoftPressStyle: ButtonStyle { }
struct BackgroundGlow: View { }
```

落地要求：

- 颜色来源统一收敛到 `LearnNowPalette`
- Light / Dark 差异统一由动态颜色处理，不在页面层写 `if dark { ... }`
- 卡片、按钮、Tab Bar 等表面系统统一复用 `OuterSurface` / `InsetSurface`
- 日间 / 夜间玻璃差异仅允许在 Design System 层处理

### 7.7 图表实现规范

Dashboard 中的记忆曲线遵循以下规则：

- 图表优先采用 `Swift Charts`
- 仅在需要完全自定义视觉表现且 `Swift Charts` 无法满足时，才允许自绘图形
- 外层卡片由玻璃表面样式包裹，图表区域保持简洁

### 7.8 热力图实现规范

Home 的月度学习记录遵循以下规则：

- 使用固定 7 列网格
- 单元格根据学习强度区分填充深度
- 当前不开放点击行为，仅作为展示

---

## 8. 实现边界

### 8.1 范围内

- 全部 7 个页面
- 四个顶级 Tab 与独立导航栈
- `Routes → Path → Lesson → Completion` 主流程
- `Completion → 下一 Lesson` 连续学习分流
- `Completion → Anki` 复习闭环
- Lesson 中断后恢复到具体 slide
- 版本化随包 Catalog 解码与完整性校验
- SwiftData 本地优先持久化与 Private CloudKit 最终一致同步
- Completion 完成状态与 XP 事件幂等写入
- FSRS-6 动态评分区间、复习日志和可重建本地缓存
- 卡片收藏、手动掌握、提醒和主题偏好恢复
- Dashboard 图表与掌握度展示
- 日间 / 夜间双主题玻璃化 Design System

### 8.2 范围外

- 路线搜索
- 课程收藏
- 系统通知授权与真正的定时通知投递（提醒偏好本身已保存）
- 复习历史明细页面（日志本身已完整保存）
- Dashboard 时间范围切换
- Heatmap 单日详情 drill-down
- Routes 状态筛选
- CloudKit Public Database、CMS 直连和 FSRS 参数训练器

### 8.3 已确定规则

1. Lesson 必须支持中断恢复到具体 slide，并以本地状态保存最近停留位置。
2. Completion 的 XP、连胜与奖励由 Catalog 和个人事件记录派生，不依赖后端返回。
3. Anki 的四档间隔由固定参数版本的 FSRS-6 本地计算；手动掌握标记不参与调度。
4. Heatmap 当前为只读展示，不提供点击进入日级详情。
5. Dashboard 当前不提供时间范围切换。
6. Routes 当前不提供筛选器。

### 8.4 风险

- 毛玻璃材质、环境光模糊与持续动画会增加渲染成本，需关注低端设备性能。
- Light / Dark 双主题下的文字对比与 accent 亮度需要逐页验收。
- Lesson 横向分页与内嵌交互可能增加状态同步复杂度。
- CloudKit 为最终一致同步，多设备刚完成操作时可能短暂显示不同快照；UI 不承诺即时同步完成。
- Catalog 的稳定 ID 发布后不可修改或复用，内容发布流程必须先运行目录校验测试。

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
| Completion | `CompletionHero` / `RewardSummaryCard` / `GeneratedFlashcardsCard` / `CompletionActionGroup`                   |
| Anki       | `HeaderBar` / `ReviewSummaryPills` / `ReviewScopeCaption` / `FlashcardView` / `ReviewRatingGrid` / `CardPoolSheet` |
| Dashboard  | `HeaderBar` / `MemoryCurveCard` / `MasteryProgressRow`                                                         |

### 9.3 页面 - 状态映射表

| 页面       | 页面级状态                                   | 关键过程状态                            |
| ---------- | -------------------------------------------- | --------------------------------------- |
| Home       | `loading` / `loaded` / `error`               | `continueSectionState` / `heatmapSectionState` |
| Routes     | `loading` / `loaded` / `empty` / `error`     | 无                                      |
| Path       | `loading` / `loaded` / `error`               | `selectedStage`                         |
| Lesson     | `loading` / `loaded` / `error`               | `currentSlideIndex` / `lastVisitedSlideIndex` / `quizAnswerStates` |
| Completion | `loading` / `loaded` / `error`               | `rewardSectionState` / `generatedFlashcardsSectionState` |
| Anki       | `loading` / `loaded` / `empty` / `error`     | `currentFace` / `cardPoolPresentationState` / `activeReviewScope` / `selectedCardFilters` |
| Dashboard  | `loading` / `loaded` / `error`               | `memoryCurveSectionState` / `knowledgeSectionState` |

### 9.4 Token 快速索引

| 类别 | Token |
| ---- | ----- |
| 颜色 | `canvas` / `glassBase` / `surfaceOpaque` / `textPrimary` / `textSecondary` / `textMuted` / 语义角色 `brand` / `warning` / `danger` / `neutral` / 内容色 `mint` / `blue` / `purple` / `amber` / `pink` |
| 圆角 | `radiusXS` / `radiusS` / `radiusM` / `radiusL` / `radiusXL` / `radiusPill` |
| 表面 | `OuterSurface` / `InsetSurface` / `SoftPressStyle` / `BackgroundGlow` |
| 间距 | `space8` / `space12` / `space16` / `space18` / `space20` / `space24` / `space32` / `space60` / `space112` |
| 动效 | `screenSpring` / `pressSpring` / `ambientGlow` / `staggeredReveal` |

### 9.5 文档维护规则

1. 所有影响页面结构、导航、视觉 Token、组件 API、状态模型的变更，必须先更新本文档，再更新实现。
2. 任意 demo、原型、截图或临时实现都只能用于探索，不能覆盖本文档定义。
3. 若代码实现与本文档不一致，应视为实现偏离规范，而不是文档自动失效。
