@Card(id: "py-traceback-card-bottom", revision: 1, sourcePage: "py-traceback-page-bottom", topic: "错误、测试与模块", accent: "mint", frontTitle: "traceback 先看哪", frontSubtitle: "读报错", backTitle: "最底部的类型和说明") {
先定性异常类型，再决定要不要往上追调用链。

@Highlight {
先读最后一行。
}
}

@Card(id: "py-traceback-card-line", revision: 1, sourcePage: "py-traceback-page-line", topic: "错误、测试与模块", accent: "mint", frontTitle: "行号用来做什么", frontSubtitle: "定位", backTitle: "回到爆炸那一行") {
打开对应文件与行号，检查当时的数据；必要时沿调用链往上追来源。

@Highlight {
爆点之后追数据来源。
}
}
