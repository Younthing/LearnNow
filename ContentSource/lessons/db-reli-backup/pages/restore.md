备份还要能**恢复**：定期演练比「自以为有备份文件」更重要。只问有没有文件，不问能不能还原，等于没备份。

## 频率与窗口

备份越勤，灾难时丢失的时间窗越小，成本也越高。日日咖可按业务容忍度选每日/每时——关键是有明确策略。

```text
策略三问
├─ 副本在哪
├─ 多久一次
└─ 上次恢复演练何时
```

## 课程收口

怎样可靠地组织和查询大量数据？用表与约束组织，用 SQL 查询，用多表关系对齐，用索引与事务与备份托住可靠性。

@Callout(title: "有备份且能恢复，才叫有备份", tone: "information", accent: "amber") {
演练是备份的一部分。
}

@Quiz(id: "db-reli-backup.quiz-2", kind: "singleChoice") {
为什么需要备份数据？

@Option(id: "db-reli-backup-q2-why", correct: true) {
防止已提交数据因损坏、误删或站点故障而不可恢复地丢失

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
灾难恢复。
}
}
@Option(id: "db-reli-backup-q2-tx") {
因为有了备份就不需要事务
}
@Option(id: "db-reli-backup-q2-join") {
因为备份能替代 JOIN
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
备份与事务叠加以覆盖不同风险。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：误执行了已提交的 DELETE，事务回滚还救得了吗？通常救不了，靠备份。
}
}

@Quiz(id: "db-reli-backup.quiz-3", kind: "singleChoice") {
「我们每周把备份写在同一块业务盘的另一个文件夹」主要问题是？

@Option(id: "db-reli-backup-q3-same", correct: true) {
失效域相同：盘坏时业务与备份可能一起没

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
独立性不足。
}
}
@Option(id: "db-reli-backup-q3-ok") {
这是最佳实践，无需改进
}
@Option(id: "db-reli-backup-q3-sql") {
文件夹名必须是 SQL 关键字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
备份要能独立于原盘存活。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：盘坏场景下，另一文件夹还在吗？不在，就不是合格隔离。
}
}
