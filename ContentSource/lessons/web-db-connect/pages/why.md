服务器程序可以把留言暂时放在内存里，但进程一重启就没了，也难支撑大量查询。「小记」要可靠保存，通常把数据放进**数据库**，由服务器程序在需要时连接并读写。

```text
浏览器
  ↓ HTTP
服务器程序
  ↓ 连接与查询
数据库
```

数据库专长：持久保存、按条件查找、多请求间共享同一份数据。

## 程序与库是两角

服务器程序负责业务规则与 HTTP；数据库负责存储与查询。混成一团会让两边都难维护。

## 落到「小记」上

服务重启后留言还在，朋友刷新也看得到——这要求数据落在进程内存之外的持久存储里。数据库就是常见选择。

## 三层图再画一次

```text
浏览器
  ↓ HTTP
服务器程序（规则）
  ↓ 连接与查询
数据库（持久与查找）
```

程序负责业务；库负责存与查。两边职责分开，才好排查「是逻辑错还是存取错」。

## 用自己的话收一下

回到本页的目标：围绕「服务器怎样连接数据库？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "持久数据进数据库", tone: "information", accent: "mint") {
要跨重启、可查询地保存，服务器通过连接把数据交给数据库。
}

@Quiz(id: "web-db-connect-page-why.quiz-1", kind: "singleChoice") {
留言只存在服务器进程的内存变量里。重启服务后更可能怎样？

@Option(id: "web-db-connect-q1-lost", correct: true) {
内存中的留言丢失

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
未持久化到数据库就会掉。
}
}

@Option(id: "web-db-connect-q1-ok") {
自动刻进所有用户手机
}

@Option(id: "web-db-connect-q1-css") {
CSS 会备份数据库
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
内存不是持久存储。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
持久化要落到数据库（或同类存储）。
}
}
