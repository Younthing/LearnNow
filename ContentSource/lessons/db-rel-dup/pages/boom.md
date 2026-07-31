另一种「真重复」来自条件过松：忘记写对齐条件或写成恒真，会得到笛卡尔式膨胀。

## 条件要写严

```text
错误直觉：FROM 会员, 订单 却忘了编号相等
→ 每个会员配每笔订单，行数爆炸
```

JOIN ON 必须是真正的关联谓词。

## 若你只要唯一会员

在连接后的明细上，用 `DISTINCT` 或改回聚合/子查询，明确「我要人的粒度还是单的粒度」。不要把明细当名单却抱怨重复。

@Callout(title: "先分清：明细复制还是条件写炸", tone: "information", accent: "amber") {
两种「重复」治法不同。
}

@Quiz(id: "db-rel-dup.quiz-2", kind: "singleChoice") {
连接后会员姓名重复很多次。首先该检查什么？

@Option(id: "db-rel-dup-q2-grain", correct: true) {
结果粒度是否是订单明细；一对多下重复姓名可能完全正常

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
先看粒度。
}
}
@Option(id: "db-rel-dup-q2-reinstall") {
立刻重装数据库
}
@Option(id: "db-rel-dup-q2-forbid-join") {
永远禁止 JOIN
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
正常复制 vs 条件爆炸要分开。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：每一行的订单编号是否不同？若不同，就是明细而非脏数据。
}
}

@Quiz(id: "db-rel-dup.quiz-3", kind: "singleChoice") {
连接查询产生「重复记录」的常见正当原因是？

@Option(id: "db-rel-dup-q3-one-to-many", correct: true) {
一对多对齐时，「一」侧字段随「多」侧每一行被复制到结果中

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
数学结果。
}
}
@Option(id: "db-rel-dup-q3-bug") {
引擎随机复制行取乐
}
@Option(id: "db-rel-dup-q3-pk") {
主键失效导致的唯一合法现象
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
基数决定行数。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把问题改成 COUNT 订单，还会觉得姓名重复是 bug 吗？
}
}
