约束与事务一起工作：任一语句违反主键/外键等，可使当前语句失败；事务策略可选择回滚整组。

## 失败要可见

应用应检查执行结果：某步失败就回滚，而不是假装成功去提交。引擎提供能力，调用方负责不提交已知烂尾。

```text
步骤2失败
  ↓
回滚
  ↓
不提交
```

## 收口到整门课

可靠组织：表结构与约束。可靠查询：条件、聚合、连接。可靠写入：事务与提交。下一课补最后一刀——备份。

@Callout(title: "原子性要你配合", tone: "information", accent: "amber") {
失败后回滚，不要硬提交。
}

@Quiz(id: "db-reli-atomic.quiz-2", kind: "singleChoice") {
怎样避免不完整的修改成为最终真相？

@Option(id: "db-reli-atomic-q2-boundary", correct: true) {
把相关步骤放进同一事务，仅在全部成功后提交；失败则回滚

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
提交闸门。
}
}
@Option(id: "db-reli-atomic-q2-more-index") {
多建十个索引即可
}
@Option(id: "db-reli-atomic-q2-wide") {
改回一张宽表即可
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
边界在事务。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：两步之间若允许对外可见，是否已提前提交？若是，原子性已被你拆开。
}
}

@Quiz(id: "db-reli-atomic.quiz-3", kind: "singleChoice") {
引擎保证了事务原子性，应用仍可能弄裂数据的一种方式是？

@Option(id: "db-reli-atomic-q3-outside", correct: true) {
把必须一起成功的步骤拆到事务外，或失败后仍继续提交

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
边界被应用拆坏。
}
}
@Option(id: "db-reli-atomic-q3-select") {
执行只读 SELECT
}
@Option(id: "db-reli-atomic-q3-name") {
会员姓名用了中文
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
能力要配合正确用法。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：失败后是否调用了回滚？没有就危险。
}
}
