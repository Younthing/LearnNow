@Card(id: "db-query-agg-card", revision: 1, sourcePage: "db-query-agg-page-null", topic: "数据库基础", accent: "mint", frontTitle: "COUNT(*) vs COUNT(列)", frontSubtitle: "邮箱有空", backTitle: "数行还是数非空") {
COUNT(*) 计行数；COUNT(列) 计该列非空个数。SUM/AVG 常跳过 NULL。

@Highlight {
缺测属性用 COUNT(列)。
}
}
