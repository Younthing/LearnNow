会员注销，需要从表中去掉那一行。SQL 用 `DELETE`：删的是行，不是列定义。

和更新一样：**WHERE 决定删谁**。没有 WHERE，可能清空整张表。

## 基本形状

```text
DELETE FROM 会员
WHERE 编号 = 'M003'
```

小周那一行消失；表结构还在，其他人还在。

## 删除行 ≠ 删除表

删表结构是另一类语句（如 `DROP TABLE`）。日常说的「删数据」多半是 DELETE 行。

@Callout(title: "DELETE 针对行", tone: "information", accent: "amber") {
缺 WHERE 等于邀请灾难。
}

@Quiz(id: "db-sql-delete.quiz-1", kind: "singleChoice") {
DELETE FROM 会员 WHERE 编号='M003' 成功后，会员表本身还在吗？

@Option(id: "db-sql-delete-q1-table", correct: true) {
还在。只是 M003 那一行没了，表结构仍在

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
删行留表。
}
}
@Option(id: "db-sql-delete-q1-gone") {
整张会员表被销毁，需要重建
}
@Option(id: "db-sql-delete-q1-cols") {
姓名列被删掉，行还在
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
DELETE 管行。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：还能对该表 INSERT 新行吗？能，说明表还在。
}
}
