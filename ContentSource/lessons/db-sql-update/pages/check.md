更新也受约束管束：把主键改成冲突值、把非空列改成 NULL，通常失败。

## 用查询验证影响面

稳妥习惯：先 `SELECT` 出将要命中的行，确认无误再 `UPDATE`。结果行数（影响行数）是你的反馈。

```text
先 SELECT … WHERE 编号='M001'
  ↓ 确认只有阿明
再 UPDATE … WHERE 编号='M001'
```

## 边界

一次更新可以改多列；也可以命中多行（例如给所有积分 `< 5` 的人加活动分）。多行更新是能力，也是责任。

@Callout(title: "影响行数是体检单", tone: "information", accent: "amber") {
预期改 1 行却报 80 行，立刻停下来查 WHERE。
}

@Quiz(id: "db-sql-update.quiz-2", kind: "singleChoice") {
UPDATE 后引擎回报「影响 0 行」。最合理的解释是？

@Option(id: "db-sql-update-q2-none", correct: true) {
WHERE 条件没有命中任何现有行，所以没有值被改掉

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
零影响≠一定语法错。
}
}
@Option(id: "db-sql-update-q2-deleted-table") {
整张表被删除了
}
@Option(id: "db-sql-update-q2-inserted") {
其实已经自动插入了新行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先检查条件是否写错主键。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：用同一 WHERE 去 SELECT，是否也是零行？
}
}

@Quiz(id: "db-sql-update.quiz-3", kind: "singleChoice") {
UPDATE 与 INSERT 的关键差别是？

@Option(id: "db-sql-update-q3-diff", correct: true) {
UPDATE 改已有行的列值；INSERT 追加新行

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
改 vs 增。
}
}
@Option(id: "db-sql-update-q3-same") {
两者完全相同
}
@Option(id: "db-sql-update-q3-select") {
UPDATE 专门用来查询
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
动词不同，意图不同。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：行还不存在时，默认 UPDATE 会不会造出新行？通常不会。
}
}
