P值经常被误解为原假设为真的概率，但它描述的是数据在假设下的极端程度。

@Callout(title: "避坑提示", tone: "warning", accent: "mint") {
如果原假设成立，P值衡量观察到当前结果或更极端结果的概率。
}

@Quiz(id: "hypothesis-page-2.quiz", kind: "singleChoice") {
得到 p = 0.01 时，最严谨的解释是什么？

@Option(id: "null-hypothesis-probability") {
原假设有 1% 的概率正确
}

@Option(id: "p-value-meaning", correct: true) {
若原假设成立，当前或更极端结果的概率为 1%
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
P 值以原假设成立为前提，描述当前或更极端数据出现的概率。
}

@Feedback(when: "incorrect", title: "注意条件方向", tone: "warning", accent: "amber") {
P 值不是原假设为真的概率；先把“原假设成立”放在条件一侧。
}
}
