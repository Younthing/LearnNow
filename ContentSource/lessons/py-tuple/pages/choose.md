两者都有序。选谁，主要看 **还要不要改**，以及它表示的是不是一组固定搭配。

## 对照

| 需求 | 更合适 |
| --- | --- |
| 天数会增减、分钟常改 | 列表 |
| 一对固定字段，如 (星期, 分钟) | 元组 |
| 要 append / 改下标 | 列表 |
| 想表达「别改我」 | 元组 |

## 固定记录的例子

```python
record = ("周一", 40)
# 后面只读 record[0]、record[1]
```

若变成「持续追加每天分钟」，外层仍应用列表：`[("周一",40), ("周二",35)]`——列表装元组，很常见。

## 选错的信号

你发现自己在「绕过」元组去改内容，或频繁重建整份元组只为改一个字段——多半该用列表，或改用字典（下一课）。

@Callout(title: "会不会改，是分水岭", tone: "information", accent: "mint") {
要改、要变长 → 列表；固定搭配、只读 → 考虑元组。
}

@Quiz(id: "py-tuple-choose.quiz-1", kind: "singleChoice") {
用户每天都可能追加新的学习分钟。保存这串分钟，更合适的是？

@Option(id: "py-tuple-choose-q1-list", correct: true) {
列表，因为需要不断追加和可能修改
}

@Option(id: "py-tuple-choose-q1-tuple") {
元组，因为不可变更安全，所以任何数据都该用元组
}

@Option(id: "py-tuple-choose-q1-either") {
完全没区别，随机选一个即可
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
会变长、会改，是列表的主场。
}

@Feedback(when: "incorrect", title: "看会不会变", tone: "warning", accent: "amber") {
不可变在「固定搭配」时有价值；对要增长的序列是障碍。
}
}

@Quiz(id: "py-tuple-choose.quiz-2", kind: "singleChoice") {
只想固定保存「科目名 + 目标分钟」且后续只读，更贴近？

@Option(id: "py-tuple-choose-q2-tuple", correct: true) {
元组，表达一组不打算改的搭配
}

@Option(id: "py-tuple-choose-q2-grow") {
必须用列表，否则 Python 不允许保存两个值
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
固定二元组正是元组的典型用法之一。
}

@Feedback(when: "incorrect", title: "两个值都能装", tone: "warning", accent: "amber") {
列表也能装两个值；这里选元组是因为「不打算改」。
}
}
