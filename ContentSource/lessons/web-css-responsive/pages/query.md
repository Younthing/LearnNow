常用手段是**媒体查询**：当屏幕宽度跨过某个阈值，启用另一组 CSS 规则。

```text
默认：单栏（适合窄屏）
  ↓ 宽度够大
启用：主栏 + 侧栏
```

也可以反过来：默认两栏，窄屏时改单栏。入门推荐**窄屏优先**：先让手机好用，再增强宽屏。

## 阈值是判断线

阈值不是魔法数教条，而是你为「小记」选定的分界。跨过它，布局规则切换。

| 思路 | 做法 |
| --- | --- |
| 窄屏优先 | 默认单栏，变宽再加侧栏 |
| 只调字号 | 往往不够，布局也要跟着变 |

## 媒体查询在干什么

它是一组「如果宽度满足某条件，就启用这些规则」的开关。跨过你选的阈值，布局可以从单栏变为两栏。

```text
宽度 < 阈值：单栏
宽度 ≥ 阈值：主栏 + 侧栏
```

## 窄屏优先怎么落地

先写让手机好用的默认样式，再在更宽时「加料」。这样即使用户窗口很窄，也不会落到「未定义」的尴尬布局。

## 阈值不是玄学

为「小记」选一条分界，用真机或缩窗口检查：按钮是否可点、是否出现横滑。不合适就改阈值，而不是怪用户屏幕。

@Callout(title: "宽度变，规则变", tone: "information", accent: "mint") {
媒体查询让 CSS 在不同宽度启用不同规则；先保证窄屏可用。
}

@Quiz(id: "web-css-responsive-page-query.quiz-1", kind: "singleChoice") {
团队决定「小记」采用窄屏优先。这意味着什么？

@Option(id: "web-css-responsive-q2-mobile", correct: true) {
默认样式先服务窄屏，宽度变大再增强布局

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
先可用，再增强。
}
}

@Option(id: "web-css-responsive-q2-desktop") {
只做宽屏，手机以后再说
}

@Option(id: "web-css-responsive-q2-no-css") {
不再需要 CSS
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
窄屏优先＝默认按窄屏写，再逐步增强。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
若默认只服务宽屏，就不是窄屏优先。
}
}
