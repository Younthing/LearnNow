@Card(id: "web-db-auth-card-reg", revision: 1, sourcePage: "web-db-auth-page-register", topic: "Web 与数据库", accent: "mint", frontTitle: "注册在做什么", frontSubtitle: "写入用户表", backTitle: "创建身份记录") {
注册校验通过后写入用户记录。

@Highlight {
用户名冲突应拒绝并提示。
}
}

@Card(id: "web-db-auth-card-login", revision: 1, sourcePage: "web-db-auth-page-login", topic: "Web 与数据库", accent: "mint", frontTitle: "登录在做什么", frontSubtitle: "核验+会话", backTitle: "不是再注册一次") {
登录核验凭证并建立会话。

@Highlight {
后续请求靠会话识别用户。
}
}
