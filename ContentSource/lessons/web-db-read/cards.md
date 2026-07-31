@Card(id: "web-db-read-card-query", revision: 1, sourcePage: "web-db-read-page-query", topic: "Web 与数据库", accent: "mint", frontTitle: "列表数据从哪来", frontSubtitle: "查询数据库", backTitle: "服务器代查") {
列表来自服务器发起的数据库查询。

@Highlight {
浏览器不直连数据库口令去查。
}
}

@Card(id: "web-db-read-card-empty", revision: 1, sourcePage: "web-db-read-page-render", topic: "Web 与数据库", accent: "mint", frontTitle: "空结果怎么处理", frontSubtitle: "暂无留言", backTitle: "空≠错误") {
查询成功但无行时显示空状态。

@Highlight {
只有真正失败才走错误流程。
}
}
