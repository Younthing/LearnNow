有时某一步只在条件成立时才做。这是**选择**：若…则…，否则…

水开了才冲泡；没开就继续等。同一条主线出现岔路。

## 选择解决的问题

选择回答「要不要做」或「做 A 还是做 B」，前提是条件可判断。

```text
水开了？
├─ 是 → 冲泡
└─ 否 → 继续烧
```

## 条件要可观察

「感觉差不多」很难执行。改成可检查的条件：水温达到沸点、杯中无茶叶渣等。

| 条件写法 | 能否稳定分支 | 原因 |
| --- | --- | --- |
| 水开了 | 能 | 可观察 |
| 感觉好了 | 难 | 标准不清 |
| 茶叶已放入 | 能 | 可观察 |

@Callout(title: "选择管分支", tone: "information", accent: "mint") {
条件成立走一条路，不成立走另一条。
}

@Quiz(id: "cs-thinking-control-branch.quiz-1", kind: "singleChoice") {
只有杯子脏时才洗杯，干净就跳过。这主要用哪种结构？

@Option(id: "cs-thinking-control-branch-q1-if", correct: true) {
选择：按「是否脏」决定洗或不洗

@Feedback(title: "条件决定做不做", tone: "success", accent: "mint") {
这是典型的若…则…。
}
}

@Option(id: "cs-thinking-control-branch-q1-only-seq") {
只要顺序就够，条件从来不需要
}

@Option(id: "cs-thinking-control-branch-q1-bit") {
必须先把杯子变成比特才能决定
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
「有时做、有时不做」就是选择的用武之地。
}

@Feedback(when: "incorrect", title: "找条件", tone: "warning", accent: "amber") {
句子里有没有「如果…就…」？有就是选择在起作用。
}
}
