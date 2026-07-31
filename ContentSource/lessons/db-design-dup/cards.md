@Card(id: "db-design-dup-card", revision: 1, sourcePage: "db-design-dup-page-why", topic: "数据库基础", accent: "mint", frontTitle: "减少重复", frontSubtitle: "改电话改几处", backTitle: "一份真相") {
同一当前事实只存一份，其它表用主键引用；历史成交价可以快照，不叫有害重复。

@Highlight {
当前事实引用；历史事实可快照。
}
}
