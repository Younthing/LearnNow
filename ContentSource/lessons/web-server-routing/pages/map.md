浏览器请求的是一个 URL。服务器程序要决定：**这个路径对应哪段功能**。这种对应常叫路由。

```text
GET /           →  首页留言列表
GET /notes/2    →  第 2 条详情
POST /notes     →  创建新留言
```

同一台服务器，靠路径（以及方法）区分不同动作。

## URL 不只是「文件名」

现代 Web 里，路径常常映射到程序里的处理函数，而不是磁盘上恰好有个同名文件。入门模型：URL → 功能入口。

## 落到「小记」上

`/`、`/notes/2`、`/notes`（提交）指向不同意图。同一台机器靠路径（再配合方法）区分功能，而不是靠「猜用户心情」。

## URL 映射功能，不只是文件名

```text
路径进来
  ↓
路由表匹配
  ↓
进入对应功能
```

现代 Web 里，路径常常对应程序入口，而不是磁盘上恰有同名文件。

## 读项目先画路径表

拿到陌生代码时，先列出路径与意图对照表。路由图画清了，功能地图也就清楚了一半。

回到本页的目标：围绕「URL 怎样对应服务器中的功能？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "路径指向功能", tone: "information", accent: "mint") {
路由把 URL 对到服务器里的某段处理逻辑。
}

@Quiz(id: "web-server-routing-page-map.quiz-1", kind: "singleChoice") {
用户访问 /notes/2。按路由模型，服务器应优先做什么？

@Option(id: "web-server-routing-q1-map", correct: true) {
找到为「笔记详情」准备的那段处理逻辑

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
路径对应功能入口。
}
}

@Option(id: "web-server-routing-q1-random") {
随机返回任意页面
}

@Option(id: "web-server-routing-q1-css") {
只运行 CSS 媒体查询
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
路由的工作是对到正确功能。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
随机返回会打破 URL 的含义。
}
}
