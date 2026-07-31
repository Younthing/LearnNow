连接时，程序需要知道：库在哪、用什么账号、连哪一个库。这些配置应放在服务器环境中，**不要写进可公开的前端代码**。

```text
服务器启动或首次需要时
  ↓
用配置建立连接
  ↓
后续请求复用连接（或连接池）
```

## 入门边界

具体驱动与 SQL 方言后面可深挖。本课只要会画：请求 → 程序 → 数据库。

## 连接需要哪些信息

库在哪、用什么账号、连哪个库名——这些是配置。它们只应出现在服务器环境，不能写进可下载的前端脚本。

## 时机

```text
启动或首次需要时建立连接
  ↓
后续请求复用（或连接池）
```

本课不展开某一家驱动 API；先抓住「谁持有连接配置」。

## 泄密的典型写法

把口令写进公开仓库、写进前端打包文件、写进可分享的截图——都是同一类错：机密离开了服务器边界。

回到本页的目标：围绕「服务器怎样连接数据库？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "连接配置放服务器", tone: "warning", accent: "amber") {
数据库地址与口令属于机密配置，只留在服务器侧。
}

@Quiz(id: "web-db-connect-page-how.quiz-1", kind: "singleChoice") {
有人把数据库密码写进公开的前端 JS。问题是？

@Option(id: "web-db-connect-q2-leak", correct: true) {
任何人都能看到并可能滥用连接信息

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
前端公开等于泄密。
}
}

@Option(id: "web-db-connect-q2-fine") {
完全没问题，因为有 CSS
}

@Option(id: "web-db-connect-q2-faster") {
这样连接会更快且更安全
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
数据库凭证绝不能放进公开前端。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
能被下载的 JS 不是藏机密的地方。
}
}
