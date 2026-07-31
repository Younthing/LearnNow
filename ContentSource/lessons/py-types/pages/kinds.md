`minutes = 40` 和 `minutes = "40"` 看起来都像四十分钟，但 Python 把它们当成 **不同种类** 的值。

种类决定你能做什么：数字可以比大小、做加减；引号里的是文本；还有一种只表示「是 / 否」的值。

## 三类最常用的基础值

| 种类 | 例子 | 常用来做什么 |
| --- | --- | --- |
| 数字 | `40`、`3.5` | 计算、比较大小 |
| 字符串 | `"40"`、`"语文"` | 保存文字、拼接说明 |
| 布尔 | `True`、`False` | 表示是或否 |

布尔常出现在「是否达标」这类判断里：达标为 `True`，否则为 `False`。

## 种类会限制运算

```text
40 + 5        → 可以算
"学了" + "分" → 可以拼文字
"40" + 5      → 种类不合，通常会出问题
```

所以看到奇怪报错时，先问：参与运算的两边，是不是同一种该在一起的值？

## 先认出，再深入

这一页只要能 **认出** 三类，并知道种类会影响能做的事。下一页专门看 `input` 为什么特别容易让人混进文本。

@Callout(title: "种类决定能做什么", tone: "information", accent: "mint") {
同样长得像 40，是数字还是文本，决定它能不能直接拿去算。
}

@Quiz(id: "py-types-kinds.quiz-1", kind: "singleChoice") {
要判断「今天是否达标」，最适合用哪一类值来保存结论？

@Option(id: "py-types-kinds-q1-bool", correct: true) {
布尔值 True 或 False，表示是或否
}

@Option(id: "py-types-kinds-q1-long-str") {
一段很长的说明文字，把原因写进同一个值里
}

@Option(id: "py-types-kinds-q1-float") {
一个带很多小数的数字，越精确越好
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
「是否」正好对应布尔。原因可以另存，不必塞进同一个是/否值里。
}

@Feedback(when: "incorrect", title: "先看问题在问什么", tone: "warning", accent: "amber") {
问题要的是是或否，不是一篇解释，也不是更细的小数。
}
}

@Quiz(id: "py-types-kinds.quiz-2", kind: "singleChoice") {
`"40" + 5` 这类写法容易出问题。按这一页的模型，原因更接近哪一句？

@Option(id: "py-types-kinds-q2-kind", correct: true) {
一边是文本，一边是数字，种类不合，不能按同一种运算处理
}

@Option(id: "py-types-kinds-q2-python") {
Python 禁止任何加法
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
加法本身没问题，问题在两边是不是同一种该在一起的值。
}

@Feedback(when: "incorrect", title: "对照能算的例子", tone: "warning", accent: "amber") {
`40 + 5` 可以；出问题的是混进了带引号的 `"40"`。
}
}
