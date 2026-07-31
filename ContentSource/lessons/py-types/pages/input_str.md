今日学习里你写了 `minutes = input(...)`，使用者敲了 `40`。它看起来像数字，但 `input` 默认交还给你的是 **字符串**。

这解释了为什么直接拿去和 `30` 比大小、或做加法，有时会怪，有时会报错。

## 敲下来的「40」仍是文字

```text
你敲下 4 和 0
  ↓ input
得到的是文本 "40"
  ↓ 若要当数字用
先转换成 40
```

转换常用 `int(...)`（整数）或 `float(...)`（小数）。先转，再比较或计算。

## 一个最小对照

```python
raw = input("今天学了几分钟？")
minutes = int(raw)
print(minutes > 30)
```

`raw` 仍是文本；`minutes` 才是可比较的数字。最后一行打印的是布尔：是否大于 30。

## 边界

使用者若输入 `四十分` 这种无法变成数字的内容，转换会失败——后面「错误」单元会专门处理。这一页先建立：`input` → 文本 →（需要时）再转数字。

@Callout(title: "先问它是不是文本", tone: "warning", accent: "amber") {
`input` 的结果默认是字符串；要计算或比大小，先 **转换** 再动手。
}

@Quiz(id: "py-types-input.quiz-1", kind: "singleChoice") {
`minutes = input("今天学了几分钟？")`，使用者输入 40。此时 minutes 里更准确的描述是？

@Option(id: "py-types-input-q1-str", correct: true) {
字符串 "40"，还不是可以默认拿去算术的数字
}

@Option(id: "py-types-input-q1-int") {
整数 40，因为看起来全是数字字符
}

@Option(id: "py-types-input-q1-bool") {
布尔值 True，因为输入成功了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
input 交还文本。看起来像数字，不等于已经是数字类型。
}

@Feedback(when: "incorrect", title: "别被样子骗了", tone: "warning", accent: "amber") {
自检：若直接 `"40" + 1`，会不会出问题？会的话，说明它还按文本在处理。
}
}

@Quiz(id: "py-types-input.quiz-2", kind: "singleChoice") {
要把今日分钟和目标 30 比较大小，更稳妥的顺序是？

@Option(id: "py-types-input-q2-convert", correct: true) {
先把 input 的结果转成数字，再和 30 比较
}

@Option(id: "py-types-input-q2-direct") {
直接拿 input 的结果和 30 比，Python 会自动猜对
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先转换，种类对齐，比较才可靠。
}

@Feedback(when: "incorrect", title: "把转换写成显式一步", tone: "warning", accent: "amber") {
养成习惯：input 之后，若要算，就先 int 或 float。
}
}
