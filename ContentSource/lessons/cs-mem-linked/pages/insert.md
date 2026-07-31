在两个节点之间插入新节点，主要是**改链接**：让前驱指向新节点，新节点指向旧后继。不必搬移整段数组。

## 改指针，不搬大楼

```text
A → C
插入 B：
A → B → C
```

## 灵活来自局部修改

只要找到插入点，更新少数链接即可。这正是数组中间插入所缺的。

## 先找到，再改链

插入的便宜是相对「大搬家」而言。若插入点在链表很深处，你仍要先走很多步找到前驱。

所以链表擅长的是：已经握着相邻节点时的局部修改，而不是任意位置的瞬间跳转。

@Callout(title: "局部重链", tone: "information", accent: "mint") {
链表插入的核心成本在找到位置并改链接，而不是搬移大块。
}

@Quiz(id: "cs-mem-linked-insert.quiz-1", kind: "singleChoice") {
在 A 与 C 之间插入 B，按链表做法，关键动作是？

@Option(id: "cs-mem-linked-insert-q1-relink", correct: true) {
让 A 指向 B，再让 B 指向 C

@Feedback(title: "重链", tone: "success", accent: "mint") {
逻辑顺序靠链接表达。
}
}

@Option(id: "cs-mem-linked-insert-q1-shift") {
必须把内存里所有后续节点整体后移一格
}

@Option(id: "cs-mem-linked-insert-q1-delete") {
先删除 A 与 C，永远不再连接
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
插入=局部改链接。
}

@Feedback(when: "incorrect", title: "画三个框", tone: "warning", accent: "amber") {
箭头该从谁指向谁，才能变成 A-B-C？
}
}
