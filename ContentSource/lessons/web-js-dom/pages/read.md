浏览器把 HTML 变成一棵可操作的节点树。脚本通过这棵树**找到元素、读取内容**。日常说的「操作 DOM」，入门就理解为：按选择方式找到页面节点。

「小记」要读留言框当前文字，脚本先找到那个输入元素，再读它的值。

## 先找到，再读取

```text
找到留言框节点
  ↓
读取其中的文字
  ↓
放入变量 count 的计算
```

找不到节点，后面一切都无从谈起——类似 CSS 选择器没命中。

## 与 CSS 选择器的亲戚关系

常按 `id`、类别等查找，和样式选择器思路相近，但目的不同：CSS 为了上样式，JS 为了读或改。

## 落到「小记」上

要读留言框当前文字，脚本必须先找到那个输入节点。找错成导航或提示文字，字数就会算到怪地方。

## 和 CSS 选择器的相似处

按 `id`、类别查找，思路相近：都是「对准目标」。目的不同——CSS 为了上样式，JS 为了读或改。

回到本页的目标：围绕「怎样读取和修改网页元素？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "先找到节点", tone: "information", accent: "mint") {
操作页面前，先稳定地找到目标元素；找不到就谈不上读和改。
}

@Quiz(id: "web-js-dom-page-read.quiz-1", kind: "singleChoice") {
字数统计一直是 0。排查发现脚本在「读取留言框」之前就失败了。最可能的原因是？

@Option(id: "web-js-dom-q1-miss", correct: true) {
没有正确找到留言框节点

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
找不到就读不到真实输入。
}
}

@Option(id: "web-js-dom-q1-margin") {
margin 设为 0
}

@Option(id: "web-js-dom-q1-dns") {
DNS 被关掉了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
读之前必须先命中节点。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
样式边距不会让「读取元素」这一步直接失败成这样。
}
}
