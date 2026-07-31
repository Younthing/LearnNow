语言靠**严格约定**：哪些词合法、语句怎样嵌套、名字怎样指代数据。

## 精确才能翻译

「把数弄大一点」机器没法唯一翻译。`sum = a + b` 这类写法把运算与去向说死。

```text
口语：弄大一点（含糊）
语言：sum = a + b（可翻译）
```

## 约定要学，但值得

学语法像学一种窄领域的普通话：表达范围专用于描述计算，所以能自动检查许多低级错误。

| 表达 | 能否唯一翻译 | 原因 |
| --- | --- | --- |
| a 加 b 写入 sum | 能 | 结构清楚 |
| 弄得更好看 | 不能 | 标准不明 |
| 若 a>0 则显示 a | 能 | 条件清楚 |

@Callout(title: "约定换精确", tone: "information", accent: "mint") {
编程语言用严格语法，换取可自动翻译与检查。
}

@Quiz(id: "cs-prog-language-bridge.quiz-1", kind: "singleChoice") {
哪句更适合作为编程语言里的步骤？

@Option(id: "cs-prog-language-bridge-q1-add", correct: true) {
把 a 与 b 相加，结果存入 sum

@Feedback(title: "去向明确", tone: "success", accent: "mint") {
运算对象与结果位置都清楚。
}
}

@Option(id: "cs-prog-language-bridge-q1-nice") {
让结果看起来更聪明一点
}

@Option(id: "cs-prog-language-bridge-q1-maybe") {
也许可以考虑加法之类的事
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
可翻译的句子必须钉死动作与对象。
}

@Feedback(when: "incorrect", title: "去模糊词", tone: "warning", accent: "amber") {
划掉「更聪明」「也许」后，还剩无可执行内容吗？
}
}
