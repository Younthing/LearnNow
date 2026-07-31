录入学习分钟时，你事先不知道有多少天，只约定：输入 `-1` 表示结束。

这种「次数不定、靠条件决定」的重复，适合 **`while`**。

## 边问边录

```python
total = 0
n = int(input("分钟（-1 结束）："))
while n != -1:
    total = total + n
    n = int(input("分钟（-1 结束）："))
print("合计", total)
```

条件 `n != -1` 为真就继续累加；一旦输入 -1，条件变假，循环结束。

```text
读入 n
  ↓
n 是 -1？
  是 → 结束循环
  否 → 累加，再读入
```

## 条件要有机会变假

如果循环体内从不更新会让条件变假的量，`while` 可能一直转——这就是死循环的常见来源。写 while 时顺手问：什么情况下会停？

## 和 for 怎么选

有现成序列、逐个处理 → 优先 `for`。不知次数、靠哨兵或条件 → 看 `while`。

@Callout(title: "停得下来才算写完", tone: "warning", accent: "amber") {
`while` 靠条件继续；你必须保证条件 **有机会变成假**。
}

@Quiz(id: "py-loop-ctrl-while.quiz-1", kind: "singleChoice") {
用户连续输入 30、40、-1。按上面的模型，合计最可能是？

@Option(id: "py-loop-ctrl-while-q1-70", correct: true) {
70，因为 -1 只负责结束，不加入合计
}

@Option(id: "py-loop-ctrl-while-q1-69") {
69，因为 -1 也会被加进去再结束
}

@Option(id: "py-loop-ctrl-while-q1-inf") {
无法结束，因为 while 不会停
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
读到 -1 时条件为假，不会走进累加那一步。
}

@Feedback(when: "incorrect", title: "看条件何时检查", tone: "warning", accent: "amber") {
进入循环体前先判断 n != -1。已经是 -1，就不会再累加。
}
}

@Quiz(id: "py-loop-ctrl-while.quiz-2", kind: "singleChoice") {
什么情况下 while 更合适，而不是 for？

@Option(id: "py-loop-ctrl-while-q2-unknown", correct: true) {
重复次数事先不确定，要靠条件决定是否继续
}

@Option(id: "py-loop-ctrl-while-q2-list") {
手里已有固定列表，只是逐个打印
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
不知次数、靠哨兵或条件，正是 while 的典型场景。
}

@Feedback(when: "incorrect", title: "固定序列优先 for", tone: "warning", accent: "amber") {
已有列表逐个处理时，for 通常更直接。
}
}
