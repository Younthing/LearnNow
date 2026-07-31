同一步可能要做多次，直到满足结束条件。这是**重复**。

杯子要洗到干净：检查 → 洗 → 再检查，直到通过。

## 重复解决的问题

重复回答「做几遍」。关键是退出条件：否则会一直做下去。

```text
干净了？
├─ 否 → 再洗一遍 → 回到检查
└─ 是 → 结束清洗
```

## 三种结构对照

| 结构 | 解决什么 | 缺它会怎样 |
| --- | --- | --- |
| 顺序 | 先后 | 依赖断裂 |
| 选择 | 分支 | 该跳过却硬做 |
| 重复 | 多次 | 只能手写很多遍 |

## 重复与选择常一起出现

「不干净就再洗」既有选择（脏吗），又有重复（回到检查）。画流程图时，判断框与回边会同时出现。

拆结构时允许组合，只要每个出口仍说得清。

@Callout(title: "重复管次数", tone: "warning", accent: "amber") {
重复必须带**结束条件**，否则无法停。
}

@Quiz(id: "cs-thinking-control-loop.quiz-1", kind: "singleChoice") {
要把 10 个杯子依次洗净。只用顺序把「洗杯」抄 10 次能工作，但更合适的是？

@Option(id: "cs-thinking-control-loop-q1-rep", correct: true) {
用重复：在「还有未洗的杯子」时继续洗

@Feedback(title: "次数用重复表达", tone: "success", accent: "mint") {
数量一变，重复结构比抄写更稳。
}
}

@Option(id: "cs-thinking-control-loop-q1-branch-only") {
只用选择，完全禁止重复
}

@Option(id: "cs-thinking-control-loop-q1-none") {
三种结构都不需要，杯子会自己变干净
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
同类动作多次出现时，优先考虑重复。
}

@Feedback(when: "incorrect", title: "看次数", tone: "warning", accent: "amber") {
同一动作要随数量变化时，重复比机械抄写更合适。
}
}
