屏幕上的 print 会随窗口关掉而消失。要把今日学习留下，需要 **写入文件**。

## 写入一行

```python
line = "语文,40\n"
with open("study.txt", "w", encoding="utf-8") as f:
    f.write(line)
```

`write` 接收字符串。`\n` 是换行，让下一条记录从新行开始——文件不会自动替你换行。

```text
程序里的字符串
  ↓ write
磁盘上的 study.txt
```

## 仍然是文本

写入 `40` 前若它是整数，先 `str(40)`。文件保存的是字符，不是 Python 变量类型本身。

@Callout(title: "写出的是字", tone: "information", accent: "mint") {
`write` 把字符串落到文件；需要换行就自己写上 `\n`。
}

@Quiz(id: "py-write-write.quiz-1", kind: "singleChoice") {
连续 `f.write("语文,40")` 两次且中间没有 `\n`，文件里更可能怎样？

@Option(id: "py-write-write-q1-stick", correct: true) {
两段字粘在同一行：语文,40语文,40
}

@Option(id: "py-write-write-q1-auto") {
自动变成两行，因为 write 总会换行
}

@Option(id: "py-write-write-q1-dict") {
自动变成字典格式
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
换行是你写进字符串里的字符，不是 write 的默认礼物。
}

@Feedback(when: "incorrect", title: "write 很听话", tone: "warning", accent: "amber") {
你给什么字符，它就写什么字符。
}
}

@Quiz(id: "py-write-write.quiz-2", kind: "singleChoice") {
要把整数分钟写进文本文件，更稳妥的是？

@Option(id: "py-write-write-q2-str", correct: true) {
先转成字符串，再 write
}

@Option(id: "py-write-write-q2-raw") {
直接把 int 丢给 write，文件会保存 Python 类型标签
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
文本文件存的是字符。先 str，再写入。
}

@Feedback(when: "incorrect", title: "文件不懂 int 对象", tone: "warning", accent: "amber") {
磁盘上留下的是文本表示，不是带类型的内存对象。
}
}
