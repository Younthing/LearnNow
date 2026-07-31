@Card(id: "py-loop-ctrl-card-while", revision: 1, sourcePage: "py-loop-ctrl-page-while", topic: "控制程序流程", accent: "mint", frontTitle: "什么时候用 while", frontSubtitle: "循环边界", backTitle: "次数不定、靠条件继续") {
while 在条件为真时重复。必须保证条件有机会变假，否则可能死循环。

@Highlight {
写 while 先想清楚出口。
}
}

@Card(id: "py-loop-ctrl-card-break", revision: 1, sourcePage: "py-loop-ctrl-page-break", topic: "控制程序流程", accent: "mint", frontTitle: "break 和 continue 差在哪", frontSubtitle: "提前控制", backTitle: "结束全部 vs 跳过本轮") {
break 立刻结束循环。continue 结束本轮剩余语句并进入下一轮。

@Highlight {
停全部用 break；忽略一条用 continue。
}
}
