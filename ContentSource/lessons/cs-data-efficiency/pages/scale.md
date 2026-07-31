真正拉开差距的是：**数据变长时，步骤数涨多快**。

## 小 n 看不出

`n=3` 时谁都很快。`n` 变成成千上万，随 `n` 线性增长的算法与增长更慢的算法，体感会分叉。

```text
n=3     差距小
  ↓
n 变大
  ↓
增长更慢的更占优
```

## 前提也算效率的一部分

「更少比较」的算法若要求先排序，要把排序成本算进总账，尤其是只查一次时。

## 小例子只够验正确

`n=3` 时两种算法都「眨眼就完成」，体感分不出胜负。正确性可以用小例子验；效率要想象 `n` 拉长后的曲线。

把列表复制变长，再数关键步骤，增长差异才会说话。

@Callout(title: "看增长", tone: "information", accent: "mint") {
效率比拼的是规模变大时成本如何上涨。
}

@Quiz(id: "cs-data-efficiency-scale.quiz-1", kind: "singleChoice") {
为什么只在 3 个元素上试一次，很难判断两算法谁更高效？

@Option(id: "cs-data-efficiency-scale-q1-small", correct: true) {
规模太小，增长差异还看不出来

@Feedback(title: "要看变长", tone: "success", accent: "mint") {
效率故事发生在 n 变大的过程里。
}
}

@Option(id: "cs-data-efficiency-scale-q1-always") {
3 个元素上更快的，对任何 n 都永远更快且无需前提
}

@Option(id: "cs-data-efficiency-scale-q1-none") {
效率与数据规模无关
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
比较增长趋势，而不是一次小样的体感。
}

@Feedback(when: "incorrect", title: "想象 n 变大", tone: "warning", accent: "amber") {
把列表拉长 1000 倍，步骤数谁涨得更疯？
}
}
