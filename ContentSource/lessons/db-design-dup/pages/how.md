减少重复不是删信息，而是**换存放位置**。

## 什么该留下，什么该引用

订单发生时的成交价，有时要**快照**在订单里——因为菜单价以后会变，历史订单不能跟着变。这不是有害重复，而是「当时事实」。

会员电话则是「当前事实」，宜单处存放、别处引用。

```text
当前电话
  → 只存会员表，订单引用编号
成交价 22
  → 可留在订单行（历史快照）
菜单现价 25
  → 只影响新单，不改旧账
```

| 事实 | 更合适 |
| --- | --- |
| 当前电话 | 会员表一份，订单引用会员 |
| 成交时价格 | 可快照在订单行 |
| 饮品名（仅展示） | 可引用饮品表，或按需快照 |

## 边界

过度拆分也会让每次查询都要拼很多表。入门原则：先消灭「同一当前事实复制多份」；历史快照与当前引用要分清。

@Callout(title: "当前事实引用，历史事实可快照", tone: "information", accent: "amber") {
重复是否有害，看它是不是同一真相的多份拷贝。
}

@Quiz(id: "db-design-dup.quiz-2", kind: "singleChoice") {
菜单里拿铁从 22 元改成 25 元。去年的订单仍应显示当年成交的 22。订单里存了 22，这算有害重复吗？

@Option(id: "db-design-dup-q2-snapshot", correct: true) {
不算。那是成交时点的快照，与当前菜单价不是同一份「当前真相」

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
历史快照有意保留。
}
}
@Option(id: "db-design-dup-q2-harmful") {
算有害，必须删掉订单里的价格
}
@Option(id: "db-design-dup-q2-update") {
必须把所有历史订单价格改成 25
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
当前价与成交价职责不同。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：改菜单价，是否应该改写去年账本？通常不应。
}
}

@Quiz(id: "db-design-dup.quiz-3", kind: "singleChoice") {
减少重复的主要目的是？

@Option(id: "db-design-dup-q3-one-truth", correct: true) {
让同一当前事实只有一份真相，更新时不会漏改

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
一份真相，多处引用。
}
}
@Option(id: "db-design-dup-q3-slow") {
故意让查询变慢
}
@Option(id: "db-design-dup-q3-delete") {
把所有列都删到只剩主键
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
目标是一致更新，不是删光信息。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：改一处电话，是否所有相关订单都能通过对齐引用看到？
}
}
