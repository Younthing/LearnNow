@Card(id: "py-why-fn-card-def", revision: 1, sourcePage: "py-why-fn-page-pack", topic: "函数与程序组织", accent: "mint", frontTitle: "def 会立刻执行函数体吗", frontSubtitle: "定义与调用", backTitle: "不会，定义只是装箱") {
def 把步骤装进名字。只有调用时，函数体才会执行。

@Highlight {
先定义，再调用。
}
}

@Card(id: "py-why-fn-card-one", revision: 1, sourcePage: "py-why-fn-page-reuse", topic: "函数与程序组织", accent: "mint", frontTitle: "为什么改函数体就够了", frontSubtitle: "复用", backTitle: "行为来源只有一处") {
多处调用共享同一套定义。改定义，所有调用点的行为一起更新。

@Highlight {
一处定义，多处调用。
}
}
