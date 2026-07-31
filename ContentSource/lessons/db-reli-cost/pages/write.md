给每一列都建索引，听起来「怎么查都快」。实际上，每次 `INSERT` / `UPDATE` / `DELETE` 都要同步维护这些目录——写变慢，空间变大，优化器也可能更懵。

**索引不能建得越多越好**：要为真正的高频查找付费，而不是为想象中的查询买单。

## 写入时的账

```text
插入一行会员
  ↓
更新表数据
  ↓
更新电话索引、姓名索引、……每一个相关目录
```

目录越多，这一笔写入越重。

## 读多写少 vs 写多

报表型、查询极多、写入稀少：索引更舍得。收银高峰每秒都在插订单：过多索引会拖垮写入。

@Callout(title: "索引是租来的加速", tone: "information", accent: "amber") {
租金用写入放大与空间支付。
}

@Quiz(id: "db-reli-cost.quiz-1", kind: "singleChoice") {
在一张写入极其频繁的订单表上给十个很少用于查找的列都建索引，最可能的副作用是？

@Option(id: "db-reli-cost-q1-write", correct: true) {
每次写入要维护更多目录，插入与更新变慢，并占用更多空间

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
写入放大。
}
}
@Option(id: "db-reli-cost-q1-free") {
没有任何副作用，索引越多越快
}
@Option(id: "db-reli-cost-q1-delete-col") {
这些列会从桌面消失
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用不到的索引仍要维护。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：这些列是否出现在 WHERE/JOIN 里？很少，就别建。
}
}
