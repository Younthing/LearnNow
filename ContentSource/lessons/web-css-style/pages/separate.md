把样式写在独立的 CSS 里（或独立区块），而不是把所有颜色塞进每个 HTML 标签，好处是：**同一套样子可以复用**，改一处顶改多处。

## 结构与外观分离

```text
HTML   稳定的内容骨架
CSS    可替换的外观说明
```

「小记」换皮肤时，优先换 CSS，而不是重写所有留言 HTML。

## 本单元路线

接下来会讲：怎样选中元素、盒模型、布局、不同屏幕适配。先记住分工：HTML 搭骨架，CSS 上外观。

## 落到「小记」上

留言列表的 HTML 可以长期稳定：永远是标题、列表、表单。变的是间距、字号、夜间模式——这些集中进 CSS 后，内容作者与样式调整可以分开进行。

## 分离不是「永远不许写在一起」

入门练习可以把一小段样式写在旁边，但心里要清楚：上线维护时，外观规则越集中越好。本课要立的是职责边界，不是某一家框架的文件布局教条。

回到本页的目标：围绕「CSS 怎样控制网页外观？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "换皮肤先换 CSS", tone: "information", accent: "mint") {
内容骨架宜稳定；外观规则集中管理，才方便整站统一调整。
}

@Quiz(id: "web-css-style-page-separate.quiz-1", kind: "singleChoice") {
产品希望「小记」一键换成深色外观。按分离思路，优先动哪里？

@Option(id: "web-css-style-q2-css", correct: true) {
调整 CSS 规则，尽量不动留言 HTML 结构

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
换肤＝换呈现规则。
}
}

@Option(id: "web-css-style-q2-rewrite") {
把每条留言改写成别的标签名
}

@Option(id: "web-css-style-q2-http") {
只改 HTTP 状态码
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
深色是外观，优先改 CSS。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
改标签名会动摇「是什么」，不是换肤的常规做法。
}
}
