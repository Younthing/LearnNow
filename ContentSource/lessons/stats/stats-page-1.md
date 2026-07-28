---
format: learnnow.lesson/v1
id: stats-page-1
module: stats
order: 1
title: 均值描述数据中心
accent: mint
revision: 1
locale: zh-Hans
objectives:
  - stats.mean.outlier-effect
---

均值把一组观测值压缩成一个中心位置，是理解数据分布最常用的起点。

@Callout(title: "核心认知", tone: "warning", accent: "amber") {
均值会被极端值明显拉动。面对偏态分布时，应同时观察中位数和分位数。
}

```python
values = [2, 3, 3, 4, 18]
mean = sum(values) / len(values)
```

@Quiz(id: "stats-page-1.quiz", kind: "singleChoice") {
一组数据中加入一个非常大的极端值后，均值通常会怎样？

@Option(id: "mean-rises", correct: true) {
向极端值方向移动
}

@Option(id: "mean-fixed") {
保持完全不变
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
极端值参与总和，因此均值会向这个极端值的方向移动。
}

@Feedback(when: "incorrect", title: "再看一次公式", tone: "warning", accent: "amber") {
检查这个极端值是否被计入总和，以及分母是否同步改变。
}
}
