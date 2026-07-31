条件和循环最常见的坑：条件写反、忘记更新、结束条件永真或永假。

## 两张检查表

| 陷阱 | 症状 | 自检 |
| --- | --- | --- |
| 条件写反 | 总走错分支 | 代入极端值试 |
| 忘记更新 | 死循环 | 圈内是否改条件相关变量 |
| 结束永假 | 一次都不进 | 初始状态是否满足进入条件 |

```text
死循环典型
条件看 count
  ↓
圈内从不改 count
  ↓
条件一直成立
```

## 与上一单元的联系

程序里的 if/循环，就是流程图里的判断框与回边。调试时也可以画回那张图。

@Callout(title: "先保能停", tone: "warning", accent: "amber") {
写循环时先问：哪一步让结束条件最终成立？
}

@Quiz(id: "cs-prog-control-trap.quiz-1", kind: "singleChoice") {
循环条件依赖 `left`，圈内只打印从不改 `left`。最大风险是？

@Option(id: "cs-prog-control-trap-q1-hang", correct: true) {
若初始就满足条件，可能永远循环

@Feedback(title: "状态不推进", tone: "success", accent: "mint") {
结束条件相关的变量必须在圈内变化。
}
}

@Option(id: "cs-prog-control-trap-q1-faster") {
程序会自动越跑越快并自己停
}

@Option(id: "cs-prog-control-trap-q1-type") {
这会把整数变成文字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
死循环多来自「条件相关状态不变」。
}

@Feedback(when: "incorrect", title: "盯住条件变量", tone: "warning", accent: "amber") {
问：left 怎样才会变成让条件失败的值？
}
}
