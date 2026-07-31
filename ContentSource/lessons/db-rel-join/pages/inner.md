表拆开了，阅读时要把它们**连接**回来。`JOIN` 按对齐条件把多表的行拼成更宽的结果行。

最常见：订单行带上会员姓名——用订单.会员编号 = 会员.编号。

## 内连接直觉

```text
订单行 M001 + 会员行 M001
  ↓ 对齐成功
结果行：订单字段 + 会员姓名…
```

两边都匹配才留下，叫内连接的常见行为。只有订单没有对应会员时，该订单在内连接结果里消失。

## 你在描述对齐方式

JOIN 条件就是「凭什么算同一家人」。条件写错，会拼出荒唐组合或空结果。

@Callout(title: "JOIN＝按条件拼行", tone: "information", accent: "amber") {
拆开存储，连接阅读。
}

@Quiz(id: "db-rel-join.quiz-1", kind: "singleChoice") {
要把订单与会员姓名拼在一起，对齐条件通常是？

@Option(id: "db-rel-join-q1-key", correct: true) {
订单中的会员编号等于会员表中的编号

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
用外键对齐主键。
}
}
@Option(id: "db-rel-join-q1-name") {
订单金额等于会员积分
}
@Option(id: "db-rel-join-q1-random") {
随机搭配一行会员
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
标识相等才是同一人。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：金额碰巧相等的两行，是同一会员吗？不一定。
}
}
