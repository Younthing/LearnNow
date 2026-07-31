@Card(id: "py-except-card-purpose", revision: 1, sourcePage: "py-except-page-purpose", topic: "错误、测试与模块", accent: "mint", frontTitle: "try/except 解决什么", frontSubtitle: "异常处理", backTitle: "给可预期失败一条出路") {
在可能失败的步骤外包 try，用 except 提示或补救，避免只有崩溃一种结局。

@Highlight {
失败也可以有剧本。
}
}

@Card(id: "py-except-card-specific", revision: 1, sourcePage: "py-except-page-careful", topic: "错误、测试与模块", accent: "mint", frontTitle: "为什么不要空 except 全吞", frontSubtitle: "针对性", backTitle: "会把真 bug 藏起来") {
应针对具体异常类型处理。过宽的 except 加 pass 会失去报错地图。

@Highlight {
接住，但别捂死。
}
}
