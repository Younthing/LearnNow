@Card(id: "cs-mem-linked-card-node", revision: 1, sourcePage: "cs-mem-linked-page-node", topic: "链表", accent: "purple", frontTitle: "链表节点里有什么", frontSubtitle: "两件", backTitle: "值 + 指向下一节点的链接") {
靠链接排顺序。

@Highlight {
分散存放，逻辑仍成序列。
}
}

@Card(id: "cs-mem-linked-card-trade", revision: 1, sourcePage: "cs-mem-linked-page-trade", topic: "权衡", accent: "amber", frontTitle: "链表相对数组的代价", frontSubtitle: "访问", backTitle: "按位置访问常需从头走链") {
插入便宜，跳转变贵。

@Highlight {
第 k 个往往要走 k 步。
}
}
