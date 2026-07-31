函数与外界通过**参数**接收输入，通过**返回值**交出结果。边界清楚，主流程才好推理。

## 进与出

`calculate_total(price, count)` 接收单价与数量，返回总价。函数内部变量不必全部暴露。

```text
输入参数  price, count
  ↓
函数内部计算
  ↓
返回值    total
```

## 降低复杂度的关键

调用者只需知道：给什么、得什么。内部步骤可改，只要边界约定保持，主流程仍稳。

| 概念 | 作用 |
| --- | --- |
| 参数 | 传入原料 |
| 返回值 | 交回结果 |
| 内部细节 | 可替换实现 |

@Callout(title: "边界清晰", tone: "warning", accent: "amber") {
函数靠参数进、返回值出，把细节留在内部。
}

@Quiz(id: "cs-prog-functions-boundary.quiz-1", kind: "singleChoice") {
调用者只需得到总价，不必知道内部用不用临时变量。这说明什么？

@Option(id: "cs-prog-functions-boundary-q1-hide", correct: true) {
内部细节被边界隐藏，调用者依赖的是输入输出约定

@Feedback(title: "依赖边界", tone: "success", accent: "mint") {
稳定的是约定，不是内部每一行。
}
}

@Option(id: "cs-prog-functions-boundary-q1-all") {
调用者必须复制函数体的每一行才能调用
}

@Option(id: "cs-prog-functions-boundary-q1-noio") {
函数禁止有任何输入输出
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
复杂度下降，来自「不必同时看见全部细节」。
}

@Feedback(when: "incorrect", title: "看 I/O", tone: "warning", accent: "amber") {
列出调用需要提供什么、期望收回什么。
}
}
