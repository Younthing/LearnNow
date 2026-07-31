表之间的关系还有**数量模式**：一边一行能对应另一边几行？

常见三种：**一对一**、**一对多**、**多对多**。先用日日咖说清差别，再谈中间表。

## 一对多（最常见）

一位会员可以有多笔订单；一笔订单只属于一位会员。会员:订单 = 1:多。

```text
会员 M001
├─ 订单 A
└─ 订单 B
```

外键放在「多」的一侧：订单表存会员编号。

## 一对一

一位会员至多有一份「详细档案」扩展行。两边都像唯一对齐。实际中可用共享主键或唯一外键实现；入门先识别「两边都最多一行」。

@Callout(title: "外键通常在「多」的一侧", tone: "information", accent: "amber") {
一对多里，多的那边记着一的那边的编号。
}

@Quiz(id: "db-rel-cardinality.quiz-1", kind: "singleChoice") {
会员与订单最常见的数量关系是？

@Option(id: "db-rel-cardinality-q1-om", correct: true) {
一对多：一会员多订单，一订单一会员

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
经典 1:N。
}
}
@Option(id: "db-rel-cardinality-q1-mm") {
多对多：一订单必须属于许多会员
}
@Option(id: "db-rel-cardinality-q1-oo") {
一对一：一会员一生只能有一笔订单
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
订单重复发生，所以是多。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：同一会员能不能有第二笔订单？能，就是一对多。
}
}
