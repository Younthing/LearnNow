实用策略：先观测慢查询，再针对性加索引；定期回头删掉不再服务任何查询的索引。

## 选择性

几乎只有两三个取值的列（如是/否），目录区分度低，收益常有限。电话这种高区分度列更常值得。

```text
更值得：高区分度 + 常出现在条件里
更谨慎：低区分度 + 几乎不出现在条件里
```

## 收口

快来自「对的目录」，不是「目录墙」。下一课换可靠的另一面：多步修改怎样绑成一体。

@Callout(title: "为真实查询付费", tone: "information", accent: "amber") {
没有负载依据的索引是负债。
}

@Quiz(id: "db-reli-cost.quiz-2", kind: "singleChoice") {
为什么说索引不能越多越好？

@Option(id: "db-reli-cost-q2-trade", correct: true) {
每个索引都占用空间，并在写入时需要维护，过多会拖慢改动

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
有代价。
}
}
@Option(id: "db-reli-cost-q2-illegal") {
法规规定每表最多一个索引
}
@Option(id: "db-reli-cost-q2-select") {
索引会阻止 SELECT
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
权衡读写。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：加索引后插入耗时是否上升？上升就是租金。
}
}

@Quiz(id: "db-reli-cost.quiz-3", kind: "singleChoice") {
更合理的加索引方式是？

@Option(id: "db-reli-cost-q3-need", correct: true) {
根据实际慢查询与条件列来加，并清理不再使用的索引

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
证据驱动。
}
}
@Option(id: "db-reli-cost-q3-all") {
给所有列无脑建索引
}
@Option(id: "db-reli-cost-q3-none") {
永远不建除主键外的任何索引
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
两端极端都不可取。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：能否说出这条索引服务哪条查询？说不出就可疑。
}
}
