列表擅长「第 n 个」。字典擅长「名叫 x 的那个」。选题时先问：调用者记得住的是位置还是名称？

## 对照

| 问题 | 更合适 |
| --- | --- |
| 第 3 天学了多少 | 列表下标 |
| 语文学了多少 | 字典键 |
| 严格按录入顺序逐个处理 | 列表常更直接 |
| 按科目名更新某一项 | 字典更直接 |

## 别把字典当列表用

可以遍历字典，但若你的主需求是「按位置取第几个」，先确认是不是列表更简单。工具要对上问题。

## 组合也很常见

`[{"科目":"语文","分钟":40}, ...]` 或 `{"语文":[40,30], ...}`——先掌握「单层键值」，再按需组合。

@Callout(title: "记得住名字就用键", tone: "information", accent: "mint") {
按名称查找 → 字典；按顺序位置 → 列表。
}

@Quiz(id: "py-dict-vs.quiz-1", kind: "singleChoice") {
产品经理说：「给我英语那一科的分钟」。数据结构上更顺的是？

@Option(id: "py-dict-vs-q1-dict", correct: true) {
字典，用键「英语」直接取
}

@Option(id: "py-dict-vs-q1-guess") {
列表，靠猜英语大概在下标 7
}

@Option(id: "py-dict-vs-q1-tuple-only") {
只能用元组，因为科目名不可变
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
按名称取，正是字典的问题形状。
}

@Feedback(when: "incorrect", title: "名称 vs 位置", tone: "warning", accent: "amber") {
对方给的是名字「英语」，不是「第几个」。
}
}

@Quiz(id: "py-dict-vs.quiz-2", kind: "singleChoice") {
只要「按录入顺序把每一天分钟打出来」，更优先考虑？

@Option(id: "py-dict-vs-q2-list", correct: true) {
列表，顺序就是主线
}

@Option(id: "py-dict-vs-q2-force-dict") {
必须先改成字典，否则无法遍历
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
顺序遍历是列表的舒适区。
}

@Feedback(when: "incorrect", title: "字典也能遍历，但不是必须", tone: "warning", accent: "amber") {
问题若是顺序本身，列表通常更简单。
}
}
