写入前再强调：服务器必须校验。空内容、超长、无权限，都不应写成正式记录。

```text
不通过 → 返回错误提示，不写库
通过 → 写库 → 成功响应
```

写库失败（连接断开等）也要有明确错误处理，避免用户以为成功了。

## 不通过就不写

```text
空 / 超长 / 无权限
  ↓
返回错误，不写库
```

写库失败（连接断开等）也要明确失败，避免用户以为成功了。

## 前端检查不够

浏览器拦一层体验更好；服务器必须再拦一层。否则绕过前端就能塞进脏数据。

## 错误响应也是产品

告诉用户「正文不能为空」，比返回含糊的失败更有用。校验规则与提示文案应一起设计。

## 用自己的话收一下

回到本页的目标：围绕「表单数据怎样写入数据库？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。把例子再在脑子里走一遍，比急着记术语更有用。

@Callout(title: "先验再写", tone: "information", accent: "mint") {
校验失败就不要写入；写入失败也要明确告诉用户。
}

@Quiz(id: "web-db-write-page-check.quiz-1", kind: "singleChoice") {
正文为空却仍插入了一行空留言。缺了哪一步？

@Option(id: "web-db-write-q2-validate", correct: true) {
服务器侧校验未拦住空内容

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
空内容不应写库。
}
}

@Option(id: "web-db-write-q2-mq") {
媒体查询写错
}

@Option(id: "web-db-write-q2-h1") {
少了一个 h1
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
空内容写库说明校验缺失或失效。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
布局与标题标签不负责拦空提交。
}
}
