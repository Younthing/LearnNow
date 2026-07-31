收银：从库存扣一杯豆，同时记一笔订单。若只做成第一步就断电，账实会裂开。

**事务**把多步修改绑成一组：要么一起成功提交，要么一起当作没发生（回滚）。它解决的是「部分完成」的危险。

## 一组意图

```text
开始事务
  ├─ 扣库存
  └─ 写订单
提交  → 两步都留下
回滚  → 两步都不留
```

你不会接受「库存扣了但订单没写」的中间态成为最终真相。

## 与单条语句

单条插入也常自动在事务里。显式事务在你需要**跨多语句**保持一体时登场。

@Callout(title: "事务＝一起成功或一起取消", tone: "information", accent: "amber") {
中间态不对外人成为最终真相。
}

@Quiz(id: "db-reli-tx.quiz-1", kind: "singleChoice") {
扣库存成功、写订单失败，若没有事务保护，最糟的是？

@Option(id: "db-reli-tx-q1-partial", correct: true) {
留下只扣了库存却没有订单的不一致状态

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
部分成功。
}
}
@Option(id: "db-reli-tx-q1-faster") {
系统会变得更快
}
@Option(id: "db-reli-tx-q1-index") {
索引会自动变多
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
事务就是为避免这种裂缝。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：回滚后库存是否应回到扣之前？应。
}
}
