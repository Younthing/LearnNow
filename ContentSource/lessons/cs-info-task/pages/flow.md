你打开手机计算器，按下 `26`、加号、`12`，屏幕跳出 `38`。

计算机完成一个任务，靠的不是「懂你」，而是走完一条固定链条：**输入 → 处理 → 输出**。

## 三步分别是什么

按下的数字是输入，按加法规则算出结果是处理，屏幕上的 `38` 是输出。换一串按键，链条不变，结果会变。

```text
输入   按下 26 与 12
  ↓
处理   按规则算出 38
  ↓
输出   屏幕显示 38
```

## 换任务，不换链条

你改去算 `26 × 12`，还是输入、处理、输出。变的是中间规则，不是整条路。

日常里拍照、发消息、导航，都可以先问：这一步是进料、加工，还是出结果？

@Callout(title: "先认链条", tone: "information", accent: "purple") {
任何任务都能先拆成**输入、处理、输出**三步。
}

@Quiz(id: "cs-info-task-flow.quiz-1", kind: "singleChoice") {
计算器显示错误结果 `25`。按这一页的模型，你该先查哪一段？

@Option(id: "cs-info-task-flow-q1-process", correct: true) {
中间的处理规则：输入是否被按错了加法步骤

@Feedback(title: "处理决定结果", tone: "success", accent: "mint") {
输入对、输出错，最可疑的是处理清单写错或按错。
}
}

@Option(id: "cs-info-task-flow-q1-screen") {
只换一块屏幕，因为输出看起来不对
}

@Option(id: "cs-info-task-flow-q1-intent") {
让计算器「理解」你真正想算什么
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
链条里，结果由处理步骤决定；换屏幕改不了算法。
}

@Feedback(when: "incorrect", title: "沿链条排查", tone: "warning", accent: "amber") {
先核对输入数字，再逐步核对处理规则，最后才怀疑显示。
}
}
