@Card(id: "py-run-card-interpreter", revision: 1, sourcePage: "py-run-page-handoff", topic: "开始使用 Python", accent: "mint", frontTitle: "`.py` 自己会跑吗", frontSubtitle: "文件和解释器", backTitle: "要交给解释器") {
源文件保存的是步骤文字。只有解释器去读它，这些步骤才会被执行。

@Highlight {
改文件是编辑；看到结果要再运行。
}
}

@Card(id: "py-run-card-line", revision: 1, sourcePage: "py-run-page-lines", topic: "开始使用 Python", accent: "mint", frontTitle: "报错时为什么还能看见前面的输出", frontSubtitle: "逐行执行", backTitle: "前面的行已经跑完") {
解释器从上到下执行。停在某一行时，更上面的行通常已经做过。

@Highlight {
行号指出卡点，不是整文件同时失败。
}
}
