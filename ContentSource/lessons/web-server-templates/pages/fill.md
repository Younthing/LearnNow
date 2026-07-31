填模板时，占位符对应数据字段：`title`、`body`、`author`。缺字段或字段名不一致，页面会出现空白或报错。

```text
数据 title = 今天的笔记
模板 {{title}}
  ↓
页面显示：今天的笔记
```

## 与前端渲染的边界

也可以让服务器只返回数据，由浏览器 JS 生成 DOM。那是另一种路线。本课先掌握：服务器用模板直接生成 HTML 的经典路径。

## 字段必须对齐

模板占位符叫 `author`，数据却只有 `name`，作者栏就会空或报错。没有自动改名魔法。

```text
数据字段 ──对齐──→ 占位符
```

## 另一条路线（只识别）

也可以让服务器只返回数据，由浏览器 JS 生成 DOM。那是另一条架构。本课先掌握服务器填模板出 HTML 的经典路径。

## 缺字段时怎么表现

要么显示占位文案，要么在生成前校验数据完整。空白静默通过，会让页面看起来「坏了一块」却难查。

回到本页的目标：围绕「模板怎样生成动态网页？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "字段名要对齐", tone: "information", accent: "mint") {
模板占位符与数据字段名一致，才能填出完整页面。
}

@Quiz(id: "web-server-templates-page-fill.quiz-1", kind: "singleChoice") {
模板写了作者 {{{{author}}}}，但数据里只有 name 字段。最可能出现什么？

@Option(id: "web-server-templates-q2-miss", correct: true) {
作者位置空白或渲染失败

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
名字对不上就填不进。
}
}

@Option(id: "web-server-templates-q2-auto") {
会自动把 name 改名叫 author
}

@Option(id: "web-server-templates-q2-css") {
CSS 会补上作者
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
占位符与字段必须对齐。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
没有魔法重命名。
}
}
