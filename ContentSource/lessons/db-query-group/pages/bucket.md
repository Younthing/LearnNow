店长问：「每种饮品各卖出多少杯？」一行一个订单明细时，需要先**分组**，再在每组上计数。

`GROUP BY` 把值相同的行收成一组；组上再做统计。

## 最小例子

```text
订单明细
美式
美式
拿铁

GROUP BY 饮品名 之后：
美式  → 两行一组
拿铁  → 一行一组
```

然后对每组 `COUNT(*)` 得到杯数。

## 分组改变的是观察粒度

原来一行是一笔明细；分组后一行结果常是「一个饮品名 + 一个统计值」。粒度从明细变成汇总。

@Callout(title: "先捆成组，再组内统计", tone: "information", accent: "amber") {
GROUP BY 决定按什么切分。
}

@Quiz(id: "db-query-group.quiz-1", kind: "singleChoice") {
按饮品名 GROUP BY 后，结果里通常一行代表什么？

@Option(id: "db-query-group-q1-one-drink", correct: true) {
一个饮品名（一组）以及你对该组做的统计

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
粒度变粗。
}
}
@Option(id: "db-query-group-q1-one-order") {
仍然严格对应原来的每一笔订单行
}
@Option(id: "db-query-group-q1-member") {
一位会员的全部人生
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
一组一行汇总。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：明细有 3 行、2 种饮品，分组结果大概几行？2 行。
}
}
