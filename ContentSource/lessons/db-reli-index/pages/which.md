索引建在哪些列上，取决于你怎么查。日日咖若总按电话找会员，电话列就值得考虑索引；若几乎从不按姓名精确查，姓名索引收益可能很小。

## 与主键

主键通常自带唯一索引：既标识又加速按主键定位。外键列也常建索引，以加速连接与校验。

```text
常查：电话 → 考虑索引
主键：编号 → 通常已有
很少当条件：备注 → 通常不建
```

## 下一课

索引不是越多越好：每次写入还要更新目录。先立住「它为何快」，再谈成本。

@Callout(title: "按查询方式选列", tone: "information", accent: "amber") {
索引服务 WHERE / JOIN 条件，不是装饰。
}

@Quiz(id: "db-reli-index.quiz-2", kind: "singleChoice") {
索引主要加快哪类操作？

@Option(id: "db-reli-index-q2-lookup", correct: true) {
按条件定位符合的行（查找/连接时常受益）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
读路径加速。
}
}
@Option(id: "db-reli-index-q2-coffee") {
煮咖啡的速度
}
@Option(id: "db-reli-index-q2-always-write") {
一定让每次写入都更快
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
写入往往更忙，见下一课。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：没有 WHERE 的全表汇总，是否一定走你的电话索引？不一定。
}
}

@Quiz(id: "db-reli-index.quiz-3", kind: "singleChoice") {
为什么说索引像目录？

@Option(id: "db-reli-index-q3-dir", correct: true) {
它按列值组织查找路径，让你先查目录再跳到数据行

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
间接定位。
}
}
@Option(id: "db-reli-index-q3-copy") {
它把整张表复制成文本文件
}
@Option(id: "db-reli-index-q3-null") {
它把所有 NULL 变成 0
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
目录隐喻落在定位。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：目录本身占不属于正文的额外页——索引也占额外空间。
}
}
