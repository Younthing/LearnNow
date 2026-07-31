事务还涉及多人同时改时的隔离，细节很深。入门抓住：它把一组写入当成一个工作单元。

## 提交才算数

事务中的修改在提交前，其他会话未必看得见（视隔离级别而定）。提交后成为共同真相；回滚则丢弃。

```text
未提交：工作草稿
已提交：大家认的账
回滚：草稿作废
```

## 边界

事务不是备份，也不能替代正确的业务规则。它保证的是你声明的那一组步骤的原子边界。

@Callout(title: "提交前是草稿", tone: "information", accent: "amber") {
回滚丢草稿；提交才成账。
}

@Quiz(id: "db-reli-tx.quiz-2", kind: "singleChoice") {
事务主要解决什么问题？

@Option(id: "db-reli-tx-q2-atomic", correct: true) {
让多步修改作为整体成功或整体取消，避免部分完成的不一致

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
原子边界。
}
}
@Option(id: "db-reli-tx-q2-font") {
统一屏幕字体
}
@Option(id: "db-reli-tx-q2-join") {
替代所有 JOIN
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
针对写入一致性。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：单步失败时，已成功的步骤应不应自动留下？在事务里通常不应。
}
}

@Quiz(id: "db-reli-tx.quiz-3", kind: "singleChoice") {
显式开事务最适合哪种场景？

@Option(id: "db-reli-tx-q3-multi", correct: true) {
必须一起成功的多条修改（如扣库存+写订单）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
多语句一体。
}
}
@Option(id: "db-reli-tx-q3-select") {
只读一句 SELECT 也必须开复杂事务才合法
}
@Option(id: "db-reli-tx-q3-drop") {
专门用来删除数据库软件本身
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
为跨步骤意图服务。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：两步之间能否允许只完成一步？不能，就需要事务。
}
}
