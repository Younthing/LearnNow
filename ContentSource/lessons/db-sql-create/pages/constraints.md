建表时顺手把关键约束写上，比事后补救便宜。

## 主键与非空

在创建表语句里声明「编号是主键」「电话不能为空」，引擎从第一行起就执行这些规则。

```text
编号  主键 → 唯一且非空
电话  非空 → 拒绝空电话
积分  整数 → 拒绝「很多」
```

## 改结构是另一类操作

表已有数据后再改列，要考虑旧行怎么填新列。入门先掌握「创建时把已知约束写清」。

@Callout(title: "约束写进创建表", tone: "information", accent: "amber") {
规则越早声明，脏数据越难混进来。
}

@Quiz(id: "db-sql-create.quiz-2", kind: "singleChoice") {
创建表时忘了声明主键，之后又插入了两行相同编号。主要风险是？

@Option(id: "db-sql-create-q2-identity", correct: true) {
失去稳定唯一标识，后续改删与关联会含糊

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
主键宜在结构层就定。
}
}
@Option(id: "db-sql-create-q2-fast") {
查询一定会更快
}
@Option(id: "db-sql-create-q2-auto-fix") {
引擎会在第二天自动合并重复编号
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
没有主键约束，重复标识可能被默许。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：两行同号时，「更新该编号的积分」会命中几行？
}
}

@Quiz(id: "db-sql-create.quiz-3", kind: "singleChoice") {
SQL 里创建表的核心目的是？

@Option(id: "db-sql-create-q3-shape", correct: true) {
向 DBMS 登记表名、列、类型与约束，准备好可写入的形状

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
登记形状。
}
}
@Option(id: "db-sql-create-q3-query") {
立刻查出所有历史订单
}
@Option(id: "db-sql-create-q3-backup") {
自动备份整台手机
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
CREATE TABLE 管结构。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：语句里有没有出现具体的阿明、小陈？没有，就是在定形状。
}
}
