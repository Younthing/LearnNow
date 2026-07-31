今日学习记录保存在 `study.txt`。程序怎样拿到里面的字？

**打开文件 → 读取 → 关闭**。读取后，内容变成程序里的字符串，才能 split、转换、汇总。

## 用 with 打开

```python
with open("study.txt", "r", encoding="utf-8") as f:
    text = f.read()
print(text)
```

`"r"` 表示读取。`with` 结束缩进块后，文件会 **自动关闭**，减少忘记关文件的问题。

```text
磁盘上的 study.txt
  ↓ open + read
程序里的字符串 text
```

## 读到的是文本

即使文件里全是数字字符，读进来仍是字符串。要计算，继续用 `int` 等转换。

@Callout(title: "读是把字搬进程序", tone: "information", accent: "mint") {
`open` 打开，`read` 取内容；`with` 帮你在用完后关闭。
}

@Quiz(id: "py-read-open.quiz-1", kind: "singleChoice") {
`f.read()` 成功之后，`text` 里通常是？

@Option(id: "py-read-open-q1-str", correct: true) {
文件内容对应的字符串
}

@Option(id: "py-read-open-q1-auto-list") {
已经按科目分好的字典，无需再处理
}

@Option(id: "py-read-open-q1-int") {
一个自动算好的合计整数
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
读取给的是原始文本；拆分和计算是下一步。
}

@Feedback(when: "incorrect", title: "读取 ≠ 理解结构", tone: "warning", accent: "amber") {
文件不会因为被打开就自动变成字典或合计。
}
}

@Quiz(id: "py-read-open.quiz-2", kind: "singleChoice") {
为什么推荐 `with open(...) as f`？

@Option(id: "py-read-open-q2-close", correct: true) {
离开 with 代码块时会自动关闭文件
}

@Option(id: "py-read-open-q2-faster") {
with 会让磁盘永久加速
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
自动关闭减少资源泄漏和文件占用问题。
}

@Feedback(when: "incorrect", title: "关注关闭时机", tone: "warning", accent: "amber") {
with 的教学重点是生命周期管理，不是神秘加速。
}
}
