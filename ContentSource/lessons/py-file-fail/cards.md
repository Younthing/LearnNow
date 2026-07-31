@Card(id: "py-file-fail-card-ext", revision: 1, sourcePage: "py-file-fail-page-why", topic: "文本与文件", accent: "mint", frontTitle: "文件操作为什么易失败", frontSubtitle: "外部依赖", backTitle: "依赖路径权限等外部环境") {
open 要找到真实文件并获得许可。环境不对，就会失败。

@Highlight {
成功不是默认选项。
}
}

@Card(id: "py-file-fail-card-cat", revision: 1, sourcePage: "py-file-fail-page-clues", topic: "文本与文件", accent: "mint", frontTitle: "打不开时先做什么", frontSubtitle: "排查", backTitle: "先按报错分类") {
找不到→查路径；permission→查权限；占用→关其他程序。

@Highlight {
先分类，再动手。
}
}
