表有了，下一句是往里面加行。SQL 里常用 `INSERT`：指明插入哪张表、哪些列、各列的值。

日日咖新来一位会员，就插入一行，而不是改表结构。

## 插入是加行

```text
INSERT INTO 会员 (编号, 姓名, 电话, 积分)
VALUES ('M003', '小周', '13700003333', 0)
```

结果：会员表多一行。列的形状没变。

## 列与值要对齐

写了四个列，就要给四个值，顺序对应。类型也要对：积分列不能塞「很多」。主键冲突或非空列缺失，插入会被拒绝。

@Callout(title: "INSERT 加的是行", tone: "information", accent: "amber") {
结构不变，集合变大一号。
}

@Quiz(id: "db-sql-insert.quiz-1", kind: "singleChoice") {
插入语句成功后，会员表发生了什么？

@Option(id: "db-sql-insert-q1-row", correct: true) {
多了一行符合表结构的数据；列定义本身通常不变

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
加行非改结构。
}
}
@Option(id: "db-sql-insert-q1-col") {
自动多出一列叫小周
}
@Option(id: "db-sql-insert-q1-drop") {
旧会员全部被清空只留新行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
INSERT 追加行。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：插入前有 2 行，成功后通常几行？3 行。
}
}
