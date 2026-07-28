---
format: learnnow.lesson/v1
id: regression-page-2
module: regression
order: 2
title: R² 的边界
accent: amber
revision: 1
locale: zh-Hans
objectives:
  - regression.r2.interpretation
---

R² 衡量模型解释方差的能力，不等于预测准确率，更不是因果证明。

@Callout(title: "常见误解", tone: "warning", accent: "pink") {
高 R² 仍可能过拟合，需要结合残差与验证集表现。
}

@Quiz(id: "regression-page-2.quiz", kind: "singleChoice") {
模型 R² = 0.82，最稳妥的理解是什么？

@Option(id: "r2-variance-explained", correct: true) {
模型解释了约 82% 的目标波动
}

@Option(id: "r2-perfect-prediction") {
新样本预测准确率一定为 82%
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
R² 描述样本中目标变量方差被模型解释的比例。
}

@Feedback(when: "incorrect", title: "不要把指标混在一起", tone: "warning", accent: "amber") {
R² 不是预测准确率；泛化表现还需要验证集和残差诊断。
}
}
