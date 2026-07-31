有了现象，就**缩小范围**：是输入错、函数算错，还是显示错？

## 对半或按层查

先看调用 `calculate_total` 前后的值。返回已错，问题在函数内；返回对而屏幕错，问题在输出侧。

```text
输入正确？
  ↓ 是
函数返回正确？
  ├─ 否 → 查函数内
  └─ 是 → 查显示/后续
```

## 一次只追一条假设

「可能是类型，也可能是循环，也可能是名字拼错」要拆开验证。每次用观察结果排除一个。

## 一次只验证一个假设

假设「漏乘」时，只检查乘法那一行与返回值。不要同时改名、改循环、改显示。

排除法要求变量可控：一次动一处，观察是否还复现。

@Callout(title: "缩小包围圈", tone: "information", accent: "mint") {
用中间结果判断错误在哪一层，而不是同时改所有地方。
}

@Quiz(id: "cs-prog-debug-locate.quiz-1", kind: "singleChoice") {
`price=10`，`count=3`，函数返回 `10`，屏幕也显示 `10`。问题更可能在哪？

@Option(id: "cs-prog-debug-locate-q1-fn", correct: true) {
函数内部：很可能漏乘了数量

@Feedback(title: "返回已错", tone: "success", accent: "mint") {
显示与返回一致且都错，优先查计算。
}
}

@Option(id: "cs-prog-debug-locate-q1-screen-only") {
只可能是屏幕字体颜色不对
}

@Option(id: "cs-prog-debug-locate-q1-input") {
输入一定是错的，尽管题面已给定 10 与 3
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
中间返回值是定位的关键锚点。
}

@Feedback(when: "incorrect", title: "看返回值", tone: "warning", accent: "amber") {
返回已经是 10，说明错误在返回之前的计算链。
}
}
