@Card(id: "db-sql-insert-card", revision: 1, sourcePage: "db-sql-insert-page-add", topic: "数据库基础", accent: "mint", frontTitle: "INSERT", frontSubtitle: "加行还是加列", backTitle: "加行") {
INSERT 向表追加一行；列结构不变。主键冲突时应拒绝，而不是默默改成更新。

@Highlight {
插入失败时先查约束，不要假定它变成了更新。
}
}
