@Card(id: "py-scope-card-local", revision: 1, sourcePage: "py-scope-page-local", topic: "函数与程序组织", accent: "mint", frontTitle: "函数里的 total 外面能用吗", frontSubtitle: "作用范围", backTitle: "默认不能") {
函数内赋值的名字默认只在函数内可见。要交出去，用 return。

@Highlight {
名字有范围，不是全局自动共享。
}
}

@Card(id: "py-scope-card-doors", revision: 1, sourcePage: "py-scope-page-boundary", topic: "函数与程序组织", accent: "mint", frontTitle: "数据怎样进出函数", frontSubtitle: "边界", backTitle: "参数进，返回出") {
把需要的值当参数传入，把结果 return 给调用处赋值。比同名碰运气更清楚。

@Highlight {
同名不等于同一个变量。
}
}
