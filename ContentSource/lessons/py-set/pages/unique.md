打卡时，科目名可能被重复写入：`语文、数学、语文`。若你只关心「学过哪些科目」，重复没有意义。

**集合**自动保持元素唯一：同样的值只会留一份。

## 去重一眼看懂

```python
subjects = {"语文", "数学", "语文"}
print(subjects)  # 只有语文、数学各一份
```

花括号、元素之间逗号——注意：空集合要用 `set()`，因为 `{}` 是空字典。

```text
放入 语文、数学、语文
  ↓
集合中：语文、数学
```

## 从列表去重

`set(minutes_names)` 可以把带重复的序列变成唯一集合。若还要列表，再 `list(...)` 转回——但顺序不一定跟原来一样。

## 不保证「第几个」

集合主打唯一，不主打下标。要「第 3 个科目」，集合不是第一选择。

@Callout(title: "同样的只留一份", tone: "information", accent: "mint") {
集合关心 **有没有**，不关心出现了几次。
}

@Quiz(id: "py-set-unique.quiz-1", kind: "singleChoice") {
`{"语文", "数学", "语文"}` 里，「语文」会出现几次？

@Option(id: "py-set-unique-q1-one", correct: true) {
一份，重复会被去掉
}

@Option(id: "py-set-unique-q1-two") {
两份，集合会保留所有写入
}

@Option(id: "py-set-unique-q1-zero") {
零份，集合不允许中文
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
唯一性是集合的核心规则。
}

@Feedback(when: "incorrect", title: "想起去重", tone: "warning", accent: "amber") {
集合不是清单流水，是「出现过的种类」。
}
}

@Quiz(id: "py-set-unique.quiz-2", kind: "singleChoice") {
你需要保留「每一次打卡」的完整流水（允许同一科目多次）。更合适的是？

@Option(id: "py-set-unique-q2-list", correct: true) {
列表，因为重复出现本身有意义
}

@Option(id: "py-set-unique-q2-set") {
集合，因为任何重复都应删除
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
流水要保留次数与顺序，列表更合适。
}

@Feedback(when: "incorrect", title: "问重复有没有意义", tone: "warning", accent: "amber") {
若第二次语文也要记账，就不能用集合把它吞掉。
}
}
