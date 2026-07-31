定位后，**只改相关处**，并用原先复现用例验证；再补一个相近例子防回归。

## 改完就跑原例

漏乘则补上 `price * count`。用 `10` 与 `3` 期望 `30`。通过后再试 `count=1`、`count=0` 等边界。

```text
修改一处
  ↓
跑原复现例
  ↓
跑一个边界例
```

## 单元收口

语言搭桥，变量存状态，条件循环控流，函数分层，调试用证据收敛。下一单元把数据做成批量结构，并谈查找与排序。

## 回归要留种子

修好原例后，把这组输入留作以后的检查种子。相关逻辑再改时，先跑这些种子，避免旧 bug 回来。

调试闭环的最后一环，是让正确结果可重复看见。

@Callout(title: "验证闭环", tone: "warning", accent: "amber") {
没有复现用例通过，就不算修完。
}

@Quiz(id: "cs-prog-debug-fix.quiz-1", kind: "singleChoice") {
修好总价后，只看了一眼代码就提交。按这一页还缺什么？

@Option(id: "cs-prog-debug-fix-q1-run", correct: true) {
用原先失败的输入再跑一遍，确认输出正确

@Feedback(title: "修完要验证", tone: "success", accent: "mint") {
证据闭环：曾失败的例子现在要通过。
}
}

@Option(id: "cs-prog-debug-fix-q1-feel") {
只要自己感觉对了就行，不必再运行
}

@Option(id: "cs-prog-debug-fix-q1-delete") {
删除所有测试输入以免再看到错误
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
调试的最后一步是验证，不是信心。
}

@Feedback(when: "incorrect", title: "跑原例", tone: "warning", accent: "amber") {
把当初暴露问题的那组输入再跑一次。
}
}
