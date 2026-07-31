多对多：一杯饮品出现在多笔订单里；一笔订单也可含多种饮品（明细行）。会员与优惠券活动也可能是多对多。

## 中间表登场

多对多不能只靠一边塞多个编号糊弄。通常引入**中间表**（如订单明细）：一行是一次「订单–饮品」配对，并可带杯数、成交价。

```text
订单 ── 订单明细 ── 饮品
         ↑
      中间表一行
      = 一次配对
```

## 对照

| 关系 | 例子 | 外键落点 |
| --- | --- | --- |
| 一对多 | 会员–订单 | 订单侧 |
| 一对一 | 会员–档案 | 任一侧唯一 |
| 多对多 | 订单–饮品 | 中间表两侧 |

@Callout(title: "多对多靠中间表落地", tone: "information", accent: "amber") {
中间行就是一次配对事实。
}

@Quiz(id: "db-rel-cardinality.quiz-2", kind: "singleChoice") {
订单与饮品是多对多时，订单明细表的一行通常表示？

@Option(id: "db-rel-cardinality-q2-pair", correct: true) {
某笔订单与某饮品的一次配对（可含杯数等）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
配对事实。
}
}
@Option(id: "db-rel-cardinality-q2-member") {
一位会员的生日
}
@Option(id: "db-rel-cardinality-q2-all") {
全店所有饮品的平均价
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
中间表记录配对。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：同一订单两行明细，是否可以是两种饮品？可以。
}
}

@Quiz(id: "db-rel-cardinality.quiz-3", kind: "singleChoice") {
一对一与一对多的关键差别是？

@Option(id: "db-rel-cardinality-q3-diff", correct: true) {
一对一：两边对对方都最多一行；一对多：一侧可对应多行

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
数量上限不同。
}
}
@Option(id: "db-rel-cardinality-q3-sql") {
一对一不能用 SQL 查询
}
@Option(id: "db-rel-cardinality-q3-fk") {
一对多禁止使用外键
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
差别在基数，不在能不能查。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：档案能否对同一会员插第二行？一对一下通常不能。
}
}
