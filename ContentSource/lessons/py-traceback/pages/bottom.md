运行错误抛出时，终端常打出一长串 **traceback**。信息很多，但阅读有顺序。

## 从最后看起

最底下通常是：

```text
ValueError: invalid literal for int() with base 10: '四十分'
```

左边是 **异常类型**（这里是 ValueError），冒号后是简短说明。这一行告诉你「撞上了什么墙」。

```text
……中间一堆调用过程……
最后一行：类型 + 说明   ← 先读这里
```

## 上面是怎么来到这里的

traceback 上半部列出调用链：谁调用了谁，最终到爆炸那一行。初学先抓住最后类型，再按需向上追。

@Callout(title: "先读最后一行", tone: "information", accent: "mint") {
异常 **类型** 和说明在堆栈最底部；先定性，再追过程。
}

@Quiz(id: "py-traceback-bottom.quiz-1", kind: "singleChoice") {
面对很长的 traceback，更高效的第一步是？

@Option(id: "py-traceback-bottom-q1-last", correct: true) {
先看最底部的异常类型和说明
}

@Option(id: "py-traceback-bottom-q1-top") {
必须从第一行逐字读到最后，否则无效
}

@Option(id: "py-traceback-bottom-q1-ignore") {
整段忽略，直接重写项目
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
底部给出定性；再决定要不要往上看调用链。
}

@Feedback(when: "incorrect", title: "节省注意力", tone: "warning", accent: "amber") {
堆栈很长是常态。先抓类型，再按需展开。
}
}

@Quiz(id: "py-traceback-bottom.quiz-2", kind: "singleChoice") {
`ValueError: ... int() ... '四十分'` 这类信息，主要在说？

@Option(id: "py-traceback-bottom-q2-convert", correct: true) {
某次转换成整数失败，当前字符串不适合 int
}

@Option(id: "py-traceback-bottom-q2-syntax") {
文件第一行少了冒号
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
类型和说明已经点出转换问题。
}

@Feedback(when: "incorrect", title: "读冒号后面的话", tone: "warning", accent: "amber") {
int 与非法字面量，不是缺冒号的语法画像。
}
}
