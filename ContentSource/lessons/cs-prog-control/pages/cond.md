变量保存状态后，程序就能按状态**选择**下一条路。条件语句把计算思维里的「选择」写进语言。

## 读状态，选分支

若 `amount > 100`，走警告分支；否则走正常分支。同一份程序，数据不同，路径不同。

```text
amount > 100 ?
├─ 是 → 显示警告
└─ 否 → 继续记账
```

## 条件要落到可比较的值

比较的是变量当前值与阈值，或两个变量。含糊感觉不能直接写进条件。

## 复合条件要可读

多个判断用「并且 / 或者」组合时，先各自代入真假，再合并。必要时拆成两层 if，避免一行条件塞进三个关系。

条件是给未来的自己读的：宁可多一行，也不要难核对。

@Callout(title: "条件选路", tone: "information", accent: "purple") {
条件读当前状态，决定走哪条语句序列。
}

@Quiz(id: "cs-prog-control-if.quiz-1", kind: "singleChoice") {
`amount` 为 `80`，条件是 `amount > 100`。会走哪条路？

@Option(id: "cs-prog-control-if-q1-no", correct: true) {
条件不成立，走「否」分支

@Feedback(title: "用当前值判断", tone: "success", accent: "mint") {
80 不大于 100，警告分支不会执行。
}
}

@Option(id: "cs-prog-control-if-q1-yes") {
条件成立，一定显示警告
}

@Option(id: "cs-prog-control-if-q1-both") {
两个分支会同时完整执行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先代入当前值，再看真假。
}

@Feedback(when: "incorrect", title: "代入再判", tone: "warning", accent: "amber") {
把 amount 换成 80，重新读一遍条件。
}
}
