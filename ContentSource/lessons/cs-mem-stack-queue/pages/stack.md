有时你只允许从同一端进出，并且**最后放进去的最先出来**。这种纪律叫栈。

撤销输入：最后打的字先被撤销。

## 后进先出

```text
压入 A
压入 B
弹出 → B
弹出 → A
```

## 解决什么问题

需要「回到最近状态」、嵌套结构处理、深度优先的探索时，栈的纪律天然匹配。

## 只暴露顶端

栈的用户通常只能压入与弹出顶端，不能随便掏中间。限制反而防止误用：撤销不会误删更早但仍需保留的状态。

纪律越清楚，错误用法越少。

@Callout(title: "栈是 LIFO", tone: "information", accent: "purple") {
栈只从顶端进出：后进先出。
}

@Quiz(id: "cs-mem-stack-queue-stack.quiz-1", kind: "singleChoice") {
连续压入 `1` 再压入 `2`，下一次弹出得到？

@Option(id: "cs-mem-stack-queue-stack-q1-two", correct: true) {
`2`：后进先出

@Feedback(title: "顶端是 2", tone: "success", accent: "mint") {
最后压入的在最上，先被弹出。
}
}

@Option(id: "cs-mem-stack-queue-stack-q1-one") {
`1`：先进先出
}

@Option(id: "cs-mem-stack-queue-stack-q1-three") {
`3`：从未压入也会出现
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用撤销直觉检验：最后写下的先擦掉。
}

@Feedback(when: "incorrect", title: "画两层", tone: "warning", accent: "amber") {
后放的在上面，弹出先拿上面。
}
}
