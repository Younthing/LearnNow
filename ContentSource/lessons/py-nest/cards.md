@Card(id: "py-nest-card-cost", revision: 1, sourcePage: "py-nest-page-cost", topic: "控制程序流程", accent: "mint", frontTitle: "嵌套为什么难读", frontSubtitle: "控制结构", backTitle: "要同时记住多层状态") {
每深一层，就要多跟踪当前轮次或当前分支。便签越多越容易漏。

@Highlight {
能跑不等于好改。
}
}

@Card(id: "py-nest-card-guard", revision: 1, sourcePage: "py-nest-page-flatten", topic: "控制程序流程", accent: "mint", frontTitle: "怎样先减一层", frontSubtitle: "降低嵌套", backTitle: "门口守卫 + 提前跳过") {
无效情况用 continue 或提前返回拦住，让正常路径保持较浅缩进。

@Highlight {
能浅则浅。
}
}
