还有外连接等变体：左表行即使右边匹配不上也保留，缺口填 NULL。入门先稳住内连接，再按需要扩展。

## 多表链式连接

订单明细对齐订单，再对齐饮品——多次 JOIN，每次一个对齐条件。

```text
明细 ─JOIN→ 订单 ─JOIN→ 会员
明细 ─JOIN→ 饮品
```

## 结果变宽

连接后列变多：来自各表的字段并排。这是「看的形状」，不是又把物理表糊回去。

@Callout(title: "连接不撤销拆分", tone: "information", accent: "amber") {
存依旧分表；结果集临时变宽。
}

@Quiz(id: "db-rel-join.quiz-2", kind: "singleChoice") {
内连接查「订单+会员」时，会员已删但订单仍在（若未做外键），该订单行通常？

@Option(id: "db-rel-join-q2-drop", correct: true) {
不会出现在内连接结果里，因为找不到匹配会员

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
内连接要求两边匹配。
}
}
@Option(id: "db-rel-join-q2-keep") {
仍出现，会员姓名显示为「已删除」自动生成
}
@Option(id: "db-rel-join-q2-dup-all") {
会复制出全部会员姓名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
匹配失败则内连接丢行。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：改用保留左表的外连接，悬空订单是否可能出现且姓名为 NULL？
}
}

@Quiz(id: "db-rel-join.quiz-3", kind: "singleChoice") {
JOIN 的主要作用是？

@Option(id: "db-rel-join-q3-combine", correct: true) {
按对齐条件把多表行拼成更宽的结果，便于一次读清关联事实

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
拼读。
}
}
@Option(id: "db-rel-join-q3-drop") {
永久把多表合并成一张物理表
}
@Option(id: "db-rel-join-q3-delete") {
删除未能对齐的原表行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结果集操作，默认不删原表。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：JOIN 之后原会员表行数变了吗？通常不变。
}
}
