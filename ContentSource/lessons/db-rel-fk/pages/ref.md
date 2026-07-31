订单表里写着会员编号 `M001`。若有人写成不存在的 `M999`，这笔订单就悬空了。

**外键**是一种约束：本表某列的值必须指向另一表中已存在的主键（或唯一键）。它把「引用」变成引擎会执行的规则。

## 指向关系

```text
订单.会员编号  →  必须能在会员.编号里找到
```

插入订单时若会员不存在，引擎可拒绝；删会员时若仍有订单引用，也可拒绝或按策略级联——具体策略后述，入门先懂「必须指到真行」。

## 外键不是新列类型

它是加在列上的**约束**。列仍然是文本或整数；额外保证取值来自父表。

@Callout(title: "外键＝合法引用", tone: "information", accent: "amber") {
子表不能指向不存在的父行。
}

@Quiz(id: "db-rel-fk.quiz-1", kind: "singleChoice") {
订单插入会员编号 M999，会员表没有 M999。外键约束下通常怎样？

@Option(id: "db-rel-fk-q1-reject", correct: true) {
拒绝插入，因为引用无效

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
悬空引用不进表。
}
}
@Option(id: "db-rel-fk-q1-create") {
自动创建一位叫 M999 的会员
}
@Option(id: "db-rel-fk-q1-ok") {
允许，外键只管排序
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
外键守护引用完整性。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：先插入会员 M999，再插订单，是否就能通过？
}
}
