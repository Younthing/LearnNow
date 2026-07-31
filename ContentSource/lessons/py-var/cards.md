@Card(id: "py-var-card-label", revision: 1, sourcePage: "py-var-page-label", topic: "开始使用 Python", accent: "mint", frontTitle: "变量名是什么", frontSubtitle: "保存数据", backTitle: "贴在值上的标签") {
赋值把名字贴到某个值上。之后写这个名字，就是取当前贴着的值。

@Highlight {
先赋值，再使用。
}
}

@Card(id: "py-var-card-reassign", revision: 1, sourcePage: "py-var-page-update", topic: "开始使用 Python", accent: "mint", frontTitle: "再赋值会怎样", frontSubtitle: "同一名字", backTitle: "标签改贴到新值") {
同一个变量名可以改指向。之后取到的是最新的值，不会默认累加。

@Highlight {
已 print 出去的旧结果不会自动改写。
}
}
