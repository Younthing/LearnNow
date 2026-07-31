`print` 让程序说话。那它怎样听你说话？

用 **`input`**。它会暂停，等你打字并回车，再把你打的内容接进程序。

## 问一句，等一个数

今日学习里常见这样写：

```python
minutes = input("今天学了几分钟？")
print("已记录：", minutes)
```

括号里的提示语先出现在屏幕上，提醒你该输入什么；你敲下的数字，才是真正进入程序的那份信息。

## 输入是「进入程序」的方向

```text
你敲下的文字
  ↓  input
程序内部拿到这份内容
  ↓  print
再确认给你看
```

`input` 负责接进来；要不要再 `print` 出去，是另一步。

## 提示语写给谁看

提示语是写给 **使用者** 看的说明，不是给 Python 当数据。写清楚「今天学了几分钟？」，比只写一个冷冰冰的光标，更不容易输错。

@Callout(title: "听和说是两个方向", tone: "information", accent: "mint") {
`input` **接进**，`print` **送出**。提示语给人看，输入内容给程序用。
}

@Quiz(id: "py-io-input.quiz-1", kind: "singleChoice") {
程序停住，屏幕上出现「今天学了几分钟？」，光标在闪。此时程序最可能在做什么？

@Option(id: "py-io-input-q1-waiting", correct: true) {
执行到了 input，正在等你输入并回车
}

@Option(id: "py-io-input-q1-printing") {
卡在 print，因为 print 总是要等人确认
}

@Option(id: "py-io-input-q1-done") {
程序已经结束，这句话是上次运行留下的
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
带提示、等待输入，是 input 的典型样子。
}

@Feedback(when: "incorrect", title: "看它在不在等你", tone: "warning", accent: "amber") {
print 通常立刻打完就继续；会停住等你打字的，是 input。
}
}

@Quiz(id: "py-io-input.quiz-2", kind: "singleChoice") {
`input("今天学了几分钟？")` 里，真正进入变量、给后面计算用的是哪一部分？

@Option(id: "py-io-input-q2-typed", correct: true) {
使用者敲下并回车的那串内容
}

@Option(id: "py-io-input-q2-prompt") {
括号里「今天学了几分钟？」整句提示语
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
提示语给人看；进入程序的是你输入的内容。
}

@Feedback(when: "incorrect", title: "分开两样东西", tone: "warning", accent: "amber") {
把提示语改成英文，你仍输入 40——程序后面用到的应是 40，不是那句英文。
}
}
