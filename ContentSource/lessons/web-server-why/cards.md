@Card(id: "web-server-why-card-need", revision: 1, sourcePage: "web-server-why-page-need", topic: "服务器端程序", accent: "mint", frontTitle: "为何要服务器程序", frontSubtitle: "共享留言", backTitle: "远端处理请求") {
服务器程序接收请求、处理并响应，以支持共享与持久。

@Highlight {
只靠各浏览器本地存储，构不成共同留言板。
}
}

@Card(id: "web-server-why-card-secret", revision: 1, sourcePage: "web-server-why-page-secret", topic: "服务器端程序", accent: "mint", frontTitle: "什么必须放服务器", frontSubtitle: "权限与机密", backTitle: "最终裁决在远端") {
权限、密码核验等机密规则必须在服务器执行。

@Highlight {
浏览器端可被绕过，不能当唯一防线。
}
}
