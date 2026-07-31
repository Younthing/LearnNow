一种组织方式通常**强化一类操作、弱化另一类**。连续数组强化随机访问，弱化中间插入；链表相反。

## 没有全能冠军

| 结构 | 更便宜 | 更贵 |
| --- | --- | --- |
| 数组 | 下标访问 | 中间插入 |
| 链表 | 局部插入 | 按位跳转 |
| 栈/队列 | 受限端操作 | 任意位置访问 |

```text
强化随机读  ↔  弱化中间插
强化局部改  ↔  弱化按位跳
```

## 设计就是交换

接受交换，才能谈选型。下一页把「按主操作选」收成可执行步骤。

## 交换要写进设计理由

选数组时，应能说出：我们接受中间插入更贵，因为主路径是随机读。选链表时则反过来。

说不清交换，往往意味着还没找准主操作。

@Callout(title: "必有交换", tone: "information", accent: "mint") {
组织方式通过允许与限制访问路径，塑造成本。
}

@Quiz(id: "cs-mem-org-efficiency-trade.quiz-1", kind: "singleChoice") {
为什么很难找到「所有操作都最便宜」的单一结构？

@Option(id: "cs-mem-org-efficiency-trade-q1-trade", correct: true) {
强化一种访问方式往往会削弱另一种

@Feedback(title: "交换是常态", tone: "success", accent: "mint") {
连续与灵活、随机与局部，常常对拉。
}
}

@Option(id: "cs-mem-org-efficiency-trade-q1-exist") {
其实有一种结构让一切操作成本为零
}

@Option(id: "cs-mem-org-efficiency-trade-q1-ignore") {
组织方式从不影响任何操作成本
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
选型是承认交换，而不是追求神话。
}

@Feedback(when: "incorrect", title: "举反例", tone: "warning", accent: "amber") {
数组下标很快时，中间插入还快吗？
}
}
