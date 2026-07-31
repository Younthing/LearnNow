表的形状在脑子里定好了，还要告诉 DBMS：**请按这个结构建表**。这条指令在 SQL 里通常叫创建表（`CREATE TABLE`）。

你写出表名、列名、类型、以及主键等约束；引擎据此准备好空表，等待插入行。

## 建表在说什么

```text
CREATE TABLE 会员 (
  编号  文本  主键,
  姓名  文本,
  电话  文本,
  积分  整数
)
```

这不是插入阿明，只是规定：以后每一行都长这样。

## 先有结构，后有数据

没有表，就无处可插。结构改动（加列、改类型）以后也能做，但入门先养成「先定形状」的习惯。

@Callout(title: "建表＝登记形状", tone: "information", accent: "amber") {
空表也有列与约束；数据是之后的事。
}

@Quiz(id: "db-sql-create.quiz-1", kind: "singleChoice") {
执行创建会员表成功后，表里有阿明这一行吗？

@Option(id: "db-sql-create-q1-empty", correct: true) {
没有。建表只准备结构，行要另用插入指令添加

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
CREATE 不等于 INSERT。
}
}
@Option(id: "db-sql-create-q1-amin") {
有，引擎会自动生成示例会员阿明
}
@Option(id: "db-sql-create-q1-phone") {
有，电话列会自动填入店长电话
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结构与数据是两步。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：建完表立刻查询所有行，结果应是空集合还是已有样例？通常是空。
}
}
