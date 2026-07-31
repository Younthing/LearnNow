程序已经会跑了。可如果它算完「今天学了 40 分钟」却什么都不显示，你怎么知道它做对了？

用 **`print`**。它把信息送到屏幕——这是程序对外说话的基本方式。

## 先让它说出一句话

今日学习程序的第一行常常是：

```python
print("开始记录今日学习")
```

运行后，屏幕上出现引号里的那句话。引号告诉 Python：这是一段文字；`print` 告诉它：把这段文字送出去。

## 输出是「离开程序」的方向

```text
程序内部的信息
  ↓  print
屏幕上出现文字
```

没有这条路，结果只留在程序内部。你调试时先加一行 `print`，往往就是在打开这条出路。

## 一次可以说好几样

你可以连续写几行 `print`，每行送出一条信息：欢迎、分钟数、收尾。顺序和你写下的顺序一致。

@Callout(title: "先让结果可见", tone: "information", accent: "mint") {
`print` 负责把信息 **送出** 程序；看不见，就很难确认步骤有没有做对。
}

@Quiz(id: "py-io-print.quiz-1", kind: "singleChoice") {
今日学习程序算完了分钟数，但屏幕一片空白。按这一页的思路，缺的最可能是哪一步？

@Option(id: "py-io-print-q1-print", correct: true) {
把算到的结果用 print 送出到屏幕
}

@Option(id: "py-io-print-q1-input") {
再写一个 input，让程序继续等待
}

@Option(id: "py-io-print-q1-rename") {
把文件名改成 output.py
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
算完和显示是两步。没有 print，结果可以存在，但你看不到。
}

@Feedback(when: "incorrect", title: "问输出方向", tone: "warning", accent: "amber") {
自检：你是想让信息离开程序、出现在屏幕上吗？那是 print 的方向，不是 input。
}
}

@Quiz(id: "py-io-print.quiz-2", kind: "singleChoice") {
两行代码依次是 `print("欢迎")` 和 `print("收尾")`。运行后你通常会先看到哪一句？

@Option(id: "py-io-print-q2-order", correct: true) {
先「欢迎」后「收尾」，和代码书写顺序一致
}

@Option(id: "py-io-print-q2-reverse") {
先「收尾」后「欢迎」，因为收尾更重要
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
多行 print 按书写顺序依次送出。
}

@Feedback(when: "incorrect", title: "回想逐行执行", tone: "warning", accent: "amber") {
解释器先遇到哪一行 print，就先送出哪一句。
}
}
