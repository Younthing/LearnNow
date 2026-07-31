@Card(id: "py-tuple-card-immut", revision: 1, sourcePage: "py-tuple-page-immut", topic: "常用数据结构", accent: "mint", frontTitle: "元组能不能改元素", frontSubtitle: "与列表对比", backTitle: "不能") {
元组有序，可用下标读取，但创建后不能改元素，也不能 append。

@Highlight {
有序且不可变。
}
}

@Card(id: "py-tuple-card-choose", revision: 1, sourcePage: "py-tuple-page-choose", topic: "常用数据结构", accent: "mint", frontTitle: "列表和元组怎么选", frontSubtitle: "选型", backTitle: "要改用列表，固定用元组") {
会增减、会改内容 → 列表。固定搭配、主要只读 → 元组。

@Highlight {
会不会改，是分水岭。
}
}
