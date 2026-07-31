数据进表之后，最常做的事是**取出来看**。SQL 用 `SELECT` 描述：从哪张表、要哪些列、（可选）哪些行。

查询不改表里的数据；它生成一份结果给你看。

## 最小查询

```text
SELECT 姓名, 积分
FROM 会员
```

含义：从会员表取出姓名与积分两列，默认包括所有行。

## 先说要什么，再说从哪

阅读顺序常与书写顺序一致：先看选了哪些列，再看来源表。`*` 表示所有列，入门可用，但写明列名更不易看错。

@Callout(title: "SELECT 只读", tone: "information", accent: "amber") {
查询生成结果集，通常不修改原表行。
}

@Quiz(id: "db-sql-select.quiz-1", kind: "singleChoice") {
执行 SELECT 姓名 FROM 会员 之后，会员表里的积分列会被删掉吗？

@Option(id: "db-sql-select-q1-no", correct: true) {
不会。SELECT 只决定结果里显示什么，不删原表列

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
查询≠删结构。
}
}
@Option(id: "db-sql-select-q1-yes") {
会，没被选出的列会从原表消失
}
@Option(id: "db-sql-select-q1-zero") {
不会删列，但会把积分清零
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结果是投影，原表仍在。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：再执行一次 SELECT *，积分还在吗？应在。
}
}
