每个路由背后是一个**处理函数**（叫法因框架而异）：读请求、执行规则、写响应。

```text
请求进入
  ↓
路由表匹配
  ↓
处理函数运行
  ↓
响应返回
```

「小记」加「删除留言」功能，通常是加一条路由 + 一个处理函数，而不是改域名。

## 边界

框架语法各异；本课只立模型。下一课专门区分 GET 与 POST。

## 处理函数里有什么

匹配成功后，函数读取请求、执行规则、生成响应。创建留言、删除留言，各自是一条路由加一个处理入口。

## 加功能时改什么

```text
新能力
├─ 新的路径（或方法）
└─ 新的处理逻辑
```

只改域名或 IP，不会自动长出删除功能。

## 一个请求一段处理

处理函数应把这一次请求的校验、读写、响应写完整。不要指望「另一个无关路径」偷偷帮你收尾。

回到本页的目标：围绕「URL 怎样对应服务器中的功能？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "一路由一入口", tone: "information", accent: "mint") {
匹配到路由后，对应处理函数负责这次请求的后续全部工作。
}

@Quiz(id: "web-server-routing-page-handler.quiz-1", kind: "singleChoice") {
要新增「删除留言」。按本课，服务器侧更本质的工作是？

@Option(id: "web-server-routing-q2-route", correct: true) {
增加对应的 URL 映射与处理逻辑

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
新功能＝新入口+新处理。
}
}

@Option(id: "web-server-routing-q2-font") {
只改浏览器默认字体
}

@Option(id: "web-server-routing-q2-ip") {
只改服务器 IP 就能自动出现删除
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
功能落在路由与处理上。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
换 IP 不产生新业务逻辑。
}
}
