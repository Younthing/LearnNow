**赋值**把新值写入变量格子，更新程序的当前状态。

`amount = amount + 10` 读出旧值，加 `10`，写回。名字没变，状态变了。

## 右先左后

先算右边，再写入左边的名字。这是常见约定，避免把「更新」理解成数学方程恒等。

```text
读出 amount(=26)
  ↓
加 10 得 36
  ↓
写回 amount
```

## 状态驱动后续步骤

选择与重复看的是当前状态。金额是否超过预算、计数是否到头，都读变量的当前值。

## 状态决定分支

后面的 if 与循环读的都是当前格子。金额是否超标，看的是赋值之后的 `amount`，不是三行以前的旧值。

顺着时间看变量，比把赋值当成数学恒等式更不容易晕。

@Callout(title: "赋值改状态", tone: "warning", accent: "amber") {
赋值更新格子里的当前值；后续步骤读到的是新状态。
}

@Quiz(id: "cs-prog-variables-state.quiz-1", kind: "singleChoice") {
`count` 原是 `2`，执行 `count = count + 1` 后，`count` 是多少？

@Option(id: "cs-prog-variables-state-q1-three", correct: true) {
`3`：读出 2，加 1，写回

@Feedback(title: "先读后写", tone: "success", accent: "mint") {
赋值不是宣称「count 永远等于 count+1」的恒等式。
}
}

@Option(id: "cs-prog-variables-state-q1-two") {
仍是 `2`，赋值从不改变格子
}

@Option(id: "cs-prog-variables-state-q1-forever") {
变成永远无解的数学方程
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
按「读 → 算 → 写」模拟一次即可。
}

@Feedback(when: "incorrect", title: "模拟一格", tone: "warning", accent: "amber") {
在纸上写出格子旧值，再按右边算完写入。
}
}
