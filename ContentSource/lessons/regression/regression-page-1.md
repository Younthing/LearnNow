---
format: learnnow.lesson/v1
id: regression-page-1
module: regression
order: 1
title: 回归系数的方向
accent: purple
revision: 1
locale: zh-Hans
objectives:
  - regression.coefficient.direction
---

在线性回归中，系数的正负首先说明变量变化的方向。

@Callout(title: "阅读顺序", tone: "information", accent: "blue") {
先看符号，再看大小，最后结合显著性和业务语境判断。
}

```python
model.fit(X, y)
print(model.coef_)
```

@Quiz(id: "regression-page-1.quiz", kind: "singleChoice") {
某特征的回归系数为 -2.1，首先可以确定什么？

@Option(id: "reg-negative-direction", correct: true) {
该特征增加时，目标值倾向下降
}

@Option(id: "reg-strong-causality") {
它一定会导致目标值下降
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
负号表示在其他条件不变时，特征增加与目标值下降相关。
}

@Feedback(when: "incorrect", title: "相关不等于因果", tone: "warning", accent: "amber") {
系数首先描述模型中的方向，单凭回归系数不能断定因果。
}
}
