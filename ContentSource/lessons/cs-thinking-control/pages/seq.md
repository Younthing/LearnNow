步骤有了，还要决定它们怎样串起来。第一种结构是**顺序**：按固定先后执行。

泡茶时必须先烧水，再冲泡。对调就会失败。

## 先后由依赖决定

后一步依赖前一步的输出时，顺序不能随意换。

```text
1 烧水
  ↓
2 放茶叶
  ↓
3 冲泡
```

## 顺序解决的问题

当你需要「先 A 后 B」且无需岔路时，顺序就够。它不回答「有时做、有时不做」，也不回答「做很多遍」。

## 可交换的步骤

若两步互不依赖——「放茶叶」与「取杯子」有时可对调——顺序仍可写成先后，但调换不破坏结果。

先标依赖，再决定哪些顺序是硬约束，哪些只是习惯。

@Callout(title: "顺序管先后", tone: "information", accent: "purple") {
有依赖就有顺序；乱序会弄断输入输出链。
}

@Quiz(id: "cs-thinking-control-seq.quiz-1", kind: "singleChoice") {
步骤「开门」与「进入房间」调换后常常失败。说明什么？

@Option(id: "cs-thinking-control-seq-q1-dep", correct: true) {
后一步依赖前一步，顺序不可随意换

@Feedback(title: "依赖决定顺序", tone: "success", accent: "mint") {
进入需要门已打开这一输出。
}
}

@Option(id: "cs-thinking-control-seq-q1-same") {
任何两步都可以对调，结果总相同
}

@Option(id: "cs-thinking-control-seq-q1-loop") {
这说明必须使用重复结构
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先找依赖，再定先后。
}

@Feedback(when: "incorrect", title: "看依赖", tone: "warning", accent: "amber") {
问：后一步是否用到了前一步的结果？
}
}
