查到记录后，填进模板循环，生成列表 HTML；或返回 JSON 由前端渲染。入门先掌握模板循环这条路。

```text
记录们
  ↓ 模板循环
一条条 <li>
  ↓
完整列表页
```

## 空结果也是结果

查询成功但没有行，应显示「暂无留言」，而不是当成服务器错误。错误与空列表要分开处理。

## 查询结果怎么变成页面

```text
得到一排记录
  ↓
模板循环生成列表项
  ↓
完整列表 HTML
```

也可以返回 JSON 由前端渲染；入门先掌握模板循环。

## 空结果

查询成功但零行，应显示「暂无留言」。把它当成服务器宕机，会误导排查。

## 展示层别偷偷改数据

模板负责把已查到的记录填进页面，不应在展示时「顺便」改数据库。读与写保持对称，排错更清晰。

回到本页的目标：围绕「怎样从数据库读取并展示数据？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "空列表不是宕机", tone: "information", accent: "mint") {
查不到行时展示空状态；只有查询真正失败才走错误提示。
}

@Quiz(id: "web-db-read-page-render.quiz-1", kind: "singleChoice") {
数据库连着，查询成功，但表是空的。首页应怎样？

@Option(id: "web-db-read-q2-empty", correct: true) {
显示暂无留言之类的空状态

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
空结果≠故障。
}
}

@Option(id: "web-db-read-q2-500") {
必须显示服务器内部错误
}

@Option(id: "web-db-read-q2-crash") {
故意让进程崩溃
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
空表用空状态，不用错误页。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
成功的空查询不是 500。
}
}
