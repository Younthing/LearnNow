@Card(id: "web-db-security-card-input", revision: 1, sourcePage: "web-db-security-page-input", topic: "Web 与数据库", accent: "mint", frontTitle: "输入为何危险", frontSubtitle: "注入与 XSS", backTitle: "不可信输入") {
用户输入可能造成注入或脚本注入，必须约束与转义。

@Highlight {
永不把原始输入直接拼进查询或当 HTML 执行。
}
}

@Card(id: "web-db-security-card-authz", revision: 1, sourcePage: "web-db-security-page-authz", topic: "Web 与数据库", accent: "mint", frontTitle: "鉴权与授权", frontSubtitle: "你是谁 / 能做什么", backTitle: "登录后仍要检查") {
鉴权识别身份，授权限制动作。

@Highlight {
改数据的接口必须做授权检查。
}
}

@Card(id: "web-db-security-card-secret", revision: 1, sourcePage: "web-db-security-page-secret", topic: "Web 与数据库", accent: "mint", frontTitle: "密码与会话", frontSubtitle: "明文不可", backTitle: "保护机密") {
密码不可明文存储；会话记号需要保护与过期。

@Highlight {
安全与功能一起设计。
}
}
