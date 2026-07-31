五天分钟在列表里。你要的是合计，而不是五次单独的数。

在 `for` 里设一个 **累加器**，每一轮更新它。

## 求和

```python
minutes_list = [30, 40, 20, 50, 35]
total = 0
for m in minutes_list:
    total = total + m
print(total)
```

`total` 在循环外出生，在每一轮变大，循环结束后才是整周合计。

```text
total=0
  +30 → 30
  +40 → 70
  +20 → 90
  ...
```

## 汇总发生在「每一轮」

忘记写 `total = total + m`，最后仍是 0——因为你遍历了，但没有处理。遍历是轨道，处理是车上装的货。

@Callout(title: "外置盒子，每轮更新", tone: "information", accent: "mint") {
汇总变量放在循环外；循环内每一轮把它更新成新结果。
}

@Quiz(id: "py-iter-agg.quiz-1", kind: "singleChoice") {
若把 `total = 0` 误写进 for 循环体内每轮开头，合计会怎样？

@Option(id: "py-iter-agg-q1-wrong", correct: true) {
每轮清零，最后往往只剩最后一天的分钟
}

@Option(id: "py-iter-agg-q1-same") {
和放在外面完全一样
}

@Option(id: "py-iter-agg-q1-error") {
Python 禁止在循环里赋值
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
累加器必须跨轮保留。每轮清零就丢了历史。
}

@Feedback(when: "incorrect", title: "跟踪两轮", tone: "warning", accent: "amber") {
第一轮加完，第二轮又把 total 设回 0——前面白加了。
}
}

@Quiz(id: "py-iter-agg.quiz-2", kind: "singleChoice") {
遍历列表却只写 `print(m)`，没有更新任何汇总变量。结束后你有合计吗？

@Option(id: "py-iter-agg-q2-no", correct: true) {
没有。遍历不等于自动汇总，处理步骤要自己写
}

@Option(id: "py-iter-agg-q2-auto") {
有。for 会秘密生成 total
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
轨道有了，车上的货（累加）还得你装。
}

@Feedback(when: "incorrect", title: "对照求和示例", tone: "warning", accent: "amber") {
合计来自 total = total + m 这类更新，不是 for 自带的。
}
}
