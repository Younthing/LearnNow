删除常牵扯别的表：订单还引用着 `M003` 时，直接删会员可能被外键规则阻止——那是多表单元的话题。这里先掌握单表删除的纪律。

## 先查后删

```text
SELECT … WHERE 编号='M003'
  ↓ 确认命中预期
DELETE … WHERE 编号='M003'
```

## 清空与删表

`DELETE` 不带 WHERE 可能删光所有行；`DROP TABLE` 连结构一起拿走。二者都不可随便在生产环境试手感。

@Callout(title: "删之前先能描述谁会被删", tone: "information", accent: "amber") {
说不清 WHERE，就还没准备好执行。
}

@Quiz(id: "db-sql-delete.quiz-2", kind: "singleChoice") {
同事执行了 DELETE FROM 会员 且没有 WHERE。最严重的后果是？

@Option(id: "db-sql-delete-q2-all", correct: true) {
会员表中所有行都可能被删光

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
无条件删除＝清空行。
}
}
@Option(id: "db-sql-delete-q2-one") {
只会删编号最小的一行
}
@Option(id: "db-sql-delete-q2-safe") {
引擎会拒绝所有不带 WHERE 的删除，所以安全
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
许多引擎允许无 WHERE 删除，危险真实存在。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：删除前用 SELECT 不加 WHERE，会看到几行？那就是危险面。
}
}

@Quiz(id: "db-sql-delete.quiz-3", kind: "singleChoice") {
DELETE 与 DROP TABLE 的差别是？

@Option(id: "db-sql-delete-q3-diff", correct: true) {
DELETE 删行（可带条件）；DROP TABLE 去掉整张表的结构

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
行 vs 结构。
}
}
@Option(id: "db-sql-delete-q3-same") {
两者完全一样
}
@Option(id: "db-sql-delete-q3-select") {
DROP 用来查询，DELETE 用来建表
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
动词对准的对象不同。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：删光所有行后，表名是否还在？DELETE 之后通常还在。
}
}
