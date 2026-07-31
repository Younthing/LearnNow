集合的另一强项是成员判断：某个科目有没有学过？

## 成员检查

```python
learned = {"语文", "数学"}
if "英语" in learned:
    print("学过英语")
else:
    print("还没学英语")
```

`in` 问的是「在不在集合里」，答案是布尔。

```text
问：英语 in learned？
  ↓
否 → 走还没学的分支
```

## 何时集合优于列表

| 需求 | 更合适 |
| --- | --- |
| 去重后的科目表 | 集合 |
| 「有没有学过 X」 | 集合很直接 |
| 保留每次记录与顺序 | 列表 |

列表也能写 `in`，但集合把「唯一 + 成员」当成主业。

@Callout(title: "主业是有没有", tone: "information", accent: "mint") {
集合擅长去重，也擅长回答 **在不在**。
}

@Quiz(id: "py-set-member.quiz-1", kind: "singleChoice") {
`learned = {"语文", "数学"}`，`"英语" in learned` 的结果是？

@Option(id: "py-set-member-q1-false", correct: true) {
False，因为集合里没有英语
}

@Option(id: "py-set-member-q1-true") {
True，因为 in 总会成功
}

@Option(id: "py-set-member-q1-err") {
一定报错，集合不能用 in
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
in 做成员判断，不在就是 False。
}

@Feedback(when: "incorrect", title: "对照集合内容", tone: "warning", accent: "amber") {
集合里只有语文和数学。英语不在其中。
}
}

@Quiz(id: "py-set-member.quiz-2", kind: "singleChoice") {
功能需求是：「快速判断某科目是否已在已学集合中」。这更贴近集合的哪一点？

@Option(id: "py-set-member-q2-member", correct: true) {
成员判断（在不在）
}

@Option(id: "py-set-member-q2-index") {
按下标取第 100 个元素
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
在不在，正是集合的常用问题。
}

@Feedback(when: "incorrect", title: "集合不主打下标", tone: "warning", accent: "amber") {
要第 n 个，先想想列表。
}
}
