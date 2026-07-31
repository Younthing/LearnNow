@Card(id: "web-server-session-card-prob", revision: 1, sourcePage: "web-server-session-page-problem", topic: "服务器端程序", accent: "mint", frontTitle: "要解决什么问题", frontSubtitle: "HTTP 健忘", backTitle: "跨请求识别") {
HTTP 请求默认不自动关联身份；会话机制补上这件事。

@Highlight {
登录态依赖跨请求仍能认得你。
}
}

@Card(id: "web-server-session-card-pair", revision: 1, sourcePage: "web-server-session-page-pair", topic: "服务器端程序", accent: "mint", frontTitle: "Cookie 和 Session", frontSubtitle: "记号与柜子", backTitle: "浏览器回传，服务器保存") {
Cookie 常作浏览器侧记号；Session 常在服务器保存会话数据。

@Highlight {
用记号找到会话，而不是每请求重新登录。
}
}
