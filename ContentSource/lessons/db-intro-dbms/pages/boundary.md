知道它「检查再执行」还不够。还要分清：哪些事是 DBMS 的职责，哪些仍是你的。

## 职责分界

```text
你负责
├─ 决定存什么（会员？订单？）
├─ 决定规则（电话唯一？）
└─ 发出指令（查、改、加、删）

DBMS 负责
├─ 按结构存放
├─ 执行检查与读写
└─ 尽量处理同时访问
```

把「积分活动怎么算」丢给 DBMS 去猜，它不会猜；把「两个人同时改同一行」完全交给收银员口头协调，又太危险。分界在于：**结构与意图在人，执行与冲突管理在引擎**。

## 为什么还要专门学它

因为后面所有「建表、查询、事务」，都是在这个分工上说话：你写清楚意图，引擎保证执行边界。搞混分工，就会既怪工具不智能，又自己去改底层文件。

@Callout(title: "人定意图，引擎守边界", tone: "information", accent: "amber") {
字段与规则由人设计；是否违规、如何安全写入，交给 DBMS。
}

@Quiz(id: "db-intro-dbms.quiz-2", kind: "singleChoice") {
同事说：「DBMS 很聪明，会自动决定我们要不要记录会员生日。」这句话错在哪？

@Option(id: "db-intro-dbms-q2-design", correct: true) {
记不记生日是业务设计，不属于引擎自动决定的范围

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
存什么由人定，引擎只管按已定结构执行。
}
}
@Option(id: "db-intro-dbms-q2-smart") {
没错，现代 DBMS 都会自动补全业务字段
}
@Option(id: "db-intro-dbms-q2-file") {
错在别处：生日只能写在文本文件里，不能进数据库
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
聪明不等于替你做产品设计。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：若从未创建「生日」这一列，引擎有没有地方可写？没有，说明字段来自设计。
}
}

@Quiz(id: "db-intro-dbms.quiz-3", kind: "singleChoice") {
两个店员同时给同一会员加积分。你希望「不要互相覆盖」。这主要该指望谁？

@Option(id: "db-intro-dbms-q3-engine", correct: true) {
DBMS 的并发控制（排队、加锁等），而不是靠口头说好谁先改

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
同时访问是引擎的经典职责之一。
}
}
@Option(id: "db-intro-dbms-q3-mouth") {
只要两人事先说好顺序，就不需要引擎插手
}
@Option(id: "db-intro-dbms-q3-copy") {
每人复制一份会员表，改完再手工合并
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
口头协调在高峰期不可靠；这正是引入引擎的原因之一。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：客流高峰时还能保证每次都口头说好吗？不能，就该把冲突管理交给引擎。
}
}
