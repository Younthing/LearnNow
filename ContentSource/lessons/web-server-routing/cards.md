@Card(id: "web-server-routing-card-map", revision: 1, sourcePage: "web-server-routing-page-map", topic: "服务器端程序", accent: "mint", frontTitle: "路由是什么", frontSubtitle: "URL → 功能", backTitle: "路径对到入口") {
路由把 URL 映射到服务器中的功能入口。

@Highlight {
不同路径可以触发不同处理。
}
}

@Card(id: "web-server-routing-card-handler", revision: 1, sourcePage: "web-server-routing-page-handler", topic: "服务器端程序", accent: "mint", frontTitle: "处理函数做什么", frontSubtitle: "匹配之后", backTitle: "读请求写响应") {
处理函数接收匹配到的请求并生成响应。

@Highlight {
新功能通常要加路由与处理逻辑。
}
}
