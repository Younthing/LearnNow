贝叶斯公式把先验认识与新证据结合起来，得到更新后的后验概率。

@Callout(title: "应用视角", tone: "information", accent: "blue") {
先验不是固定偏见；它是证据到来前的信息状态，并会随着新证据持续更新。
}

@Quiz(id: "probability-page-1.quiz", kind: "singleChoice") {
贝叶斯公式最核心的用途是什么？

@Option(id: "bayes-update", correct: true) {
根据新证据更新概率
}

@Option(id: "bayes-certainty") {
把所有不确定性变成确定性
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
贝叶斯公式把先验和新证据结合起来，形成更新后的后验概率。
}

@Feedback(when: "incorrect", title: "保留不确定性", tone: "warning", accent: "amber") {
新证据会改变判断，但不会神奇地消除所有不确定性。
}
}
