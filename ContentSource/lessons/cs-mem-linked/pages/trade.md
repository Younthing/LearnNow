代价是：访问第 `k` 个元素，通常要从头沿链接走 `k` 步，不能靠下标一次换算。

## 交换了什么

| 操作 | 数组 | 链表 |
| --- | --- | --- |
| 按下标读 | 快 | 慢（要走链） |
| 中间插入 | 常要搬 | 改链接 |
| 空间布局 | 连续 | 可分散 |

```text
要第 100 个
数组：算地址
链表：走 100 次链接
```

## 怎么选

选型看主操作：随机读多用数组；频繁中间插删更看链表。没有绝对赢家。

## 空间也可能更贵

每个节点额外保存链接，整体占用往往高于「只存值」的紧凑数组。这是灵活的另一张账单。

选型时同时问时间与空间：主操作是什么，内存是否紧张。

@Callout(title: "以时间换灵活", tone: "warning", accent: "amber") {
链表用较慢的按位查找，换较便宜的结构修改。
}

@Quiz(id: "cs-mem-linked-trade.quiz-1", kind: "singleChoice") {
程序几乎只按下标读第 i 个元素，很少插入。更合适的默认结构是？

@Option(id: "cs-mem-linked-trade-q1-array", correct: true) {
数组：下标换地址更直接

@Feedback(title: "主操作决定", tone: "success", accent: "mint") {
链表的优势用不上时，不必付遍历成本。
}
}

@Option(id: "cs-mem-linked-trade-q1-list") {
链表：因为任何场景链表都更快读下标
}

@Option(id: "cs-mem-linked-trade-q1-none") {
两种都不能读元素
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
比较的是操作组合，不是称号。
}

@Feedback(when: "incorrect", title: "看读法", tone: "warning", accent: "amber") {
要第 i 个时，谁能一次定位？
}
}
