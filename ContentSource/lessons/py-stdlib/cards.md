@Card(id: "py-stdlib-card-std", revision: 1, sourcePage: "py-stdlib-page-std", topic: "错误、测试与模块", accent: "mint", frontTitle: "标准库要先 pip 吗", frontSubtitle: "模块来源", backTitle: "不用，随 Python 自带") {
math、json 等标准库可直接 import。优先用自带工具箱。

@Highlight {
先翻自带工具箱。
}
}

@Card(id: "py-stdlib-card-third", revision: 1, sourcePage: "py-stdlib-page-third", topic: "错误、测试与模块", accent: "mint", frontTitle: "第三方模块怎么用", frontSubtitle: "安装与导入", backTitle: "先安装再 import") {
第三方不在默认全集里。用 pip 等工具安装后，再 import 使用。

@Highlight {
自己的 / 标准库 / 第三方，来源不同。
}
}
