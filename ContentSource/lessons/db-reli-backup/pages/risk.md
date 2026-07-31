事务保护的是「正在改的时候别裂开」。它不保护「磁盘坏了、误删提交了、机房没了」。

**备份**是把可恢复的数据副本放到别处，让灾难之后还能回到某一时间点的真相。

## 两类风险

```text
事务护住：进行中的半成品
备份护住：已经提交却遭遇介质损坏/误删/站点故障
```

日日咖昨天的订单都已提交；今天硬盘损坏——没有备份，事务帮不上忙。

## 副本要离开原地

只在同一块盘上复制一份，盘挂了仍一起没。备份的价值在**独立失效域**：别的盘、别的机器、别的地点。

@Callout(title: "备份对抗的是已提交数据的丢失", tone: "information", accent: "amber") {
与事务互补，不互相替代。
}

@Quiz(id: "db-reli-backup.quiz-1", kind: "singleChoice") {
已提交的订单因为硬盘损坏全部没了。事务能自动救回吗？

@Option(id: "db-reli-backup-q1-no", correct: true) {
不能。事务不管介质损毁；需要备份或副本策略

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
职责不同。
}
}
@Option(id: "db-reli-backup-q1-yes") {
能，提交过的数据永远免疫硬盘损坏
}
@Option(id: "db-reli-backup-q1-index") {
能，只要索引够多
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
备份补的是另一类风险。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：备份是否在另一块介质上？同一坏盘上的「备份」不算。
}
}
