NULL 再次影响聚合：`SUM` / `AVG` 常跳过 NULL；`COUNT(*)` 计行，`COUNT(列)` 计该列非空个数——两者可能不同。

## 选对 COUNT

```text
COUNT(*)        组内行数
COUNT(邮箱)     邮箱非空的行数
```

## 无 GROUP BY 的聚合

对整张表（或 WHERE 后的子集）聚合，结果通常只有一行：全店总销售额。有 GROUP BY 则每组一行。

@Callout(title: "COUNT(*) 与 COUNT(列) 不同", tone: "information", accent: "amber") {
一个数行，一个数非空。
}

@Quiz(id: "db-query-agg.quiz-2", kind: "singleChoice") {
会员 3 人，其中 1 人邮箱为 NULL。COUNT(*) 与 COUNT(邮箱) 通常？

@Option(id: "db-query-agg-q2-diff", correct: true) {
COUNT(*) 为 3，COUNT(邮箱) 为 2

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
星号数行，列名跳过 NULL。
}
}
@Option(id: "db-query-agg-q2-same") {
两者一定都是 3
}
@Option(id: "db-query-agg-q2-zero") {
两者一定都是 0
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺测要用 COUNT(列)。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：再插入一个邮箱非空会员，谁先变成 4？COUNT(*)。
}
}

@Quiz(id: "db-query-agg.quiz-3", kind: "singleChoice") {
聚合函数主要解决什么问题？

@Option(id: "db-query-agg-q3-summary", correct: true) {
把多行压缩成计数、总和、平均等概览指标

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
多行→一值。
}
}
@Option(id: "db-query-agg-q3-insert") {
专门插入多行
}
@Option(id: "db-query-agg-q3-index") {
专门创建索引
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
概览而非写入。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：没有聚合时，你是否在脑内自己加总？是，就正是它自动化的事。
}
}
