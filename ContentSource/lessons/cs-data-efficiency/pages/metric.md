「哪个算法更快」不能只靠感觉。入门做法：数**关键步骤**——比较次数、交换次数等。

## 同一问题，两种解法

在 `n` 个未排序名字里线性查找，最坏约 `n` 次比较。若已排序且用更聪明的策略，比较次数可明显少于 `n`（细节算法名可后学，这里先抓尺子）。

```text
算法 A：约 n 次比较
算法 B：明显少于 n 次（有前提）
```

## 先定量尺

比较前先约定：比的是最坏情况、平均情况，还是某一固定输入。尺子不一致，结论会吵。

@Callout(title: "数步骤", tone: "information", accent: "purple") {
效率比较先落到可数的操作，而不是形容词。
}

@Quiz(id: "cs-data-efficiency-metric.quiz-1", kind: "singleChoice") {
比较两个查找算法时，更靠谱的做法是？

@Option(id: "cs-data-efficiency-metric-q1-count", correct: true) {
约定同一量尺，数比较等关键步骤

@Feedback(title: "可数才可比较", tone: "success", accent: "mint") {
「感觉快」无法复现。
}
}

@Option(id: "cs-data-efficiency-metric-q1-feel") {
只看哪个名字更好听
}

@Option(id: "cs-data-efficiency-metric-q1-color") {
只看代码缩进颜色
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
量尺一致，结论才有意义。
}

@Feedback(when: "incorrect", title: "找可数指标", tone: "warning", accent: "amber") {
比较次数能否数出来？能，就从它开始。
}
}
