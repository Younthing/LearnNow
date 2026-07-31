阿明积分从 `12` 变成 `13`。表结构不变，只改已有行的某些列——这是 `UPDATE`。

更新必须说清：**改谁、改哪列、改成什么**。说不清「谁」，就可能一次改到很多行。

## 基本形状

```text
UPDATE 会员
SET 积分 = 13
WHERE 编号 = 'M001'
```

`SET` 写新值；`WHERE` 限定行。没有 `WHERE` 的更新，可能改到整张表——这是经典事故。

## 更新 ≠ 插入

行已存在才更新。不存在时，UPDATE 通常影响零行，不会自动插入（除非你用特定的「有则改无则增」语法，那是后话）。

@Callout(title: "先锁定行，再改值", tone: "information", accent: "amber") {
WHERE 决定改谁；缺了它，风险最大。
}

@Quiz(id: "db-sql-update.quiz-1", kind: "singleChoice") {
写了 UPDATE 会员 SET 积分 = 0 却忘了 WHERE。最可能发生什么？

@Option(id: "db-sql-update-q1-all", correct: true) {
所有会员的积分都可能被改成 0

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
无 WHERE 的更新作用域是整表。
}
}
@Option(id: "db-sql-update-q1-one") {
引擎会自动只改第一行
}
@Option(id: "db-sql-update-q1-reject") {
语法上必然被拒绝，所以很安全
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
忘记 WHERE 是高危操作。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：执行前先用同样的 WHERE 做 SELECT，看会命中几行。
}
}
