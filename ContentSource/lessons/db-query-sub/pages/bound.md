子查询可以返回单值（标量）或多行集合（再配合 `IN` 等）。入门先掌握「括号里先问一句」。

## 可读性边界

嵌太深会难读。能拆成两步、或用连接（下一单元）更清晰时，不必为嵌而嵌。

```text
可以：
WHERE 积分 > (SELECT AVG(积分) FROM 会员)

谨慎：
层层套四层括号却说不清每层在问什么
```

## 与连接的分工（预告）

多表信息拼在一行上，常用 JOIN；把一次查询的结果当条件，常用子查询。二者有重叠区，选择看哪一种更直白。

@Callout(title: "嵌套是为了中间答案", tone: "information", accent: "amber") {
说不清内层在问什么，就先别嵌。
}

@Quiz(id: "db-query-sub.quiz-2", kind: "singleChoice") {
子查询最核心的作用是？

@Option(id: "db-query-sub-q2-mid", correct: true) {
在一条语句里先求出中间结果，再供外层条件或数据来源使用

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
中间提问。
}
}
@Option(id: "db-query-sub-q2-backup") {
自动备份数据库
}
@Option(id: "db-query-sub-q2-index") {
强制创建索引
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结构是嵌套提问。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：去掉括号里的查询，外层条件还完得成吗？完不成，就说明需要中间答案。
}
}

@Quiz(id: "db-query-sub.quiz-3", kind: "singleChoice") {
内层算出平均积分 8，外层 WHERE 积分 > (…)。积分是 NULL 的会员会怎样？

@Option(id: "db-query-sub-q3-out", correct: true) {
通常仍不会入选，因为 NULL 与 8 的比较不成立

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
NULL 规则依旧。
}
}
@Option(id: "db-query-sub-q3-in") {
NULL 会被当成大于一切
}
@Option(id: "db-query-sub-q3-err") {
整句必然语法错误
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
子查询不取消 NULL 语义。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把 NULL 积分改成 9，是否出现在结果里？
}
}
