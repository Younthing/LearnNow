NULL 再来捣乱：积分是 NULL 时，`积分 > 10` 通常不会让该行入选——「未知」不能满足「大于」。

## 查空要用专门写法

判断某列是否空，一般用 `IS NULL` / `IS NOT NULL`，而不是 `= NULL`（后者常常得不到你以为的结果）。

```text
找未留邮箱：
WHERE 邮箱 IS NULL
```

## 筛选不改原表

带 WHERE 的 SELECT 仍然只读。原表行还在；只是结果集变瘦了。

@Callout(title: "未知过不了多数比较关", tone: "information", accent: "amber") {
NULL 行通常既不是「大于」也不是「等于」。
}

@Quiz(id: "db-query-where.quiz-2", kind: "singleChoice") {
要找出邮箱尚未填写的会员，更稳妥的条件是？

@Option(id: "db-query-where-q2-is-null", correct: true) {
WHERE 邮箱 IS NULL

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
空值用 IS NULL。
}
}
@Option(id: "db-query-where-q2-eq") {
WHERE 邮箱 = NULL
}
@Option(id: "db-query-where-q2-zero") {
WHERE 邮箱 = 0
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
= NULL 常常不是你要的语义。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：用 IS NULL 与 = NULL 各查一次，行数是否不同？
}
}

@Quiz(id: "db-query-where.quiz-3", kind: "singleChoice") {
WHERE 的主要作用是？

@Option(id: "db-query-where-q3-filter", correct: true) {
按条件决定哪些行进入结果

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
行级筛选。
}
}
@Option(id: "db-query-where-q3-sort") {
专门负责排序
}
@Option(id: "db-query-where-q3-create") {
专门负责建表
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
筛选 ≠ 排序。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：去掉 WHERE 后行数通常变多还是变少？变多。
}
}
