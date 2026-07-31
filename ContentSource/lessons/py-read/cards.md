@Card(id: "py-read-card-with", revision: 1, sourcePage: "py-read-page-open", topic: "文本与文件", accent: "mint", frontTitle: "with open 有什么好处", frontSubtitle: "读文件", backTitle: "用完自动关闭") {
with 代码块结束时关闭文件。读到的内容是字符串，再自行拆分处理。

@Highlight {
读是把字搬进程序。
}
}

@Card(id: "py-read-card-line", revision: 1, sourcePage: "py-read-page-lines", topic: "文本与文件", accent: "mint", frontTitle: "文本日志怎么读", frontSubtitle: "按行", backTitle: "一行一轮，先 strip") {
for line in f 逐行处理；先去掉换行再 split 字段。

@Highlight {
一行常常对应一条记录。
}
}
