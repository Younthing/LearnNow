结果集可以再收窄——下一单元会系统讲条件与排序。这里先立住：**查询语言描述目标，而不是描述磁盘步骤**。

## 你描述「要什么」

你写「只要姓名和积分」，不必告诉引擎先读哪一页磁盘。怎么走更省，是引擎的事（以后讲索引）。

```text
你：要姓名与积分
引擎：决定如何取回
你：拿到结果表
```

## 空结果也是合法结果

表是空的，或条件一个都没命中，结果可以是零行。这不代表语句写错，只代表此刻没有匹配数据。

@Callout(title: "查询是描述，不是手把手搬磁盘", tone: "information", accent: "amber") {
你声明目标形状；引擎负责取回。
}

@Quiz(id: "db-sql-select.quiz-2", kind: "singleChoice") {
会员表暂时没有行。SELECT 姓名 FROM 会员 最合理的结果是？

@Option(id: "db-sql-select-q2-empty", correct: true) {
成功返回零行，而不是必须报错

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
空结果合法。
}
}
@Option(id: "db-sql-select-q2-error") {
一定语法错误
}
@Option(id: "db-sql-select-q2-amin") {
自动捏造阿明一行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
无数据 ≠ 语句失败。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：插入一行后再查，是否出现一行？是，说明先前只是空集。
}
}

@Quiz(id: "db-sql-select.quiz-3", kind: "singleChoice") {
SELECT 的核心职责是？

@Option(id: "db-sql-select-q3-read", correct: true) {
按你描述的列（与条件）从原表读出结果，通常不改原表数据

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
只读查询。
}
}
@Option(id: "db-sql-select-q3-insert") {
专门用来插入新行
}
@Option(id: "db-sql-select-q3-drop") {
专门用来删除整张表
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
读与写是不同动词。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：语句以 SELECT 开头时，你预期原表行数变吗？通常不变。
}
}
