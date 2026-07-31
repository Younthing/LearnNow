关系模型落在纸面上，就是三样东西：**表、行、列**。日日咖的会员清单，正好拿来钉死这三个词。

表是整张清单；行是清单里的一个人；列是每个人都要填的同一种信息。

## 一张表长什么样

```text
会员表
姓名     电话           积分
阿明     13800001111    12
小陈     13900002222     5
```

整张叫**表**。`阿明` 那一整横条叫**行**（一条记录）。`积分` 那一整竖条叫**列**（一个字段）。

## 行是「一个对象的一次快照」

一行通常描述**同一个对象**在约定字段上的取值：这个会员叫什么、电话多少、积分多少。换一行，就是另一个会员。

不要把「阿明的积分」和「小陈的电话」糊在同一行——那会破坏「一行一个对象」。

@Callout(title: "一行一个对象", tone: "information", accent: "amber") {
横着看是一个人的全套字段；竖着看是所有人在同一字段上的取值。
}

@Quiz(id: "db-intro-table.quiz-1", kind: "singleChoice") {
在会员表里，「小陈」和「5」出现在同一行。这通常表示什么？

@Option(id: "db-intro-table-q1-same-person", correct: true) {
它们同属小陈这一条记录：姓名是小陈，积分是 5

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
同一行绑定同一个对象的各字段。
}
}
@Option(id: "db-intro-table-q1-avg") {
5 是全店积分的平均值，碰巧写在小陈旁边
}
@Option(id: "db-intro-table-q1-col") {
5 属于「积分」列的标题，不是小陈的值
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
同行＝同一对象上的一组取值。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把这一行单独抄出来，还能不能完整描述一个会员？能，就是一条记录。
}
}
