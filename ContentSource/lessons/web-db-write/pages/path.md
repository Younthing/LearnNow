发布留言的完整链可以收成：

```text
表单 POST
  ↓
服务器校验
  ↓
写入数据库
  ↓
返回成功响应
```

写入时，程序把字段（如 `body`、`author_id`）组成一条记录插入表中。成功后，列表查询才能读到它。

## 表单到字段

HTML 的 `name` 对上程序变量，再对上数据库列。任一环名字错了，就会写空或写错列。

## 完整链

```text
表单 POST
  ↓
服务器校验
  ↓
写入数据库
  ↓
返回成功响应
```

缺了写入，列表再怎么刷新也不会出现新行。字段名还要和表单 `name`、程序变量、列名对齐。

## 落到「小记」上

`body`、`author_id` 对不上列，就会写空或写错位置。三连对齐是排错第一招。

## 成功后的响应

写库成功后，可以重定向回列表，或返回成功页。无论哪种，列表下一次查询应能读到新行。

回到本页的目标：围绕「表单数据怎样写入数据库？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "提交最终要落到写入", tone: "information", accent: "mint") {
通过校验的表单数据，由服务器写成数据库里的记录。
}

@Quiz(id: "web-db-write-page-path.quiz-1", kind: "singleChoice") {
校验已通过，但列表始终没有新留言。日志显示从未执行写入。问题卡在？

@Option(id: "web-db-write-q1-write", correct: true) {
服务器没有把数据写入数据库

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
通过校验还不够，必须执行写入。
}
}

@Option(id: "web-db-write-q1-font") {
字体未加载
}

@Option(id: "web-db-write-q1-alt") {
img 缺 alt
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺写入步骤就不会出现新记录。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
外观问题不会阻止记录出现在库里。
}
}
