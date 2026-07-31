链表不要求元素挤在连续地址。每个**节点**保存：一个值，以及「下一个节点在哪」的链接（地址）。

## 分散也能串成序列

节点可以东一块西一块，靠链接排成逻辑顺序。

```text
[6000|→] → [7500|→] → [5000|×]
```

## 从头出发

通常从「头节点」开始，跟着链接走到下一项。没有下标公式一步跳到第 100 个。

## 头节点是入口

整条链通常只对外暴露头。丢了头，就找不到后续节点——数据还在内存某处，但逻辑上丢了入口。

画链表时先标头，再顺着箭头走，比空想「第 5 个在哪」更稳。

@Callout(title: "值 + 下一处", tone: "information", accent: "purple") {
链表节点携带数据，并用链接指出后继。
}

@Quiz(id: "cs-mem-linked-node.quiz-1", kind: "singleChoice") {
链表节点相对「只存一个数」的格子，多带了什么关键信息？

@Option(id: "cs-mem-linked-node-q1-next", correct: true) {
指向下一个节点的位置信息

@Feedback(title: "链接串起序列", tone: "success", accent: "mint") {
没有「下一处」，分散的值就串不起来。
}
}

@Option(id: "cs-mem-linked-node-q1-only") {
什么都不需要，值会自己排队
}

@Option(id: "cs-mem-linked-node-q1-sort") {
必须带一份完整排序算法正文
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
链接是链表的结构核心。
}

@Feedback(when: "incorrect", title: "想连接方式", tone: "warning", accent: "amber") {
两个不连续的格子如何知道谁先谁后？
}
}
