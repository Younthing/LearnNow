@Card(id: "cs-prog-control-card-if", revision: 1, sourcePage: "cs-prog-control-page-if", topic: "条件", accent: "purple", frontTitle: "条件语句做什么", frontSubtitle: "控制流", backTitle: "按当前状态选择分支") {
同一程序，数据不同则路径不同。

@Highlight {
先代入变量当前值，再判断真假。
}
}

@Card(id: "cs-prog-control-card-loop", revision: 1, sourcePage: "cs-prog-control-page-trap", topic: "循环", accent: "amber", frontTitle: "死循环常见原因", frontSubtitle: "自检", backTitle: "结束条件相关状态未推进") {
能进入，也要能离开。

@Highlight {
圈内必须改变条件所依赖的状态。
}
}
