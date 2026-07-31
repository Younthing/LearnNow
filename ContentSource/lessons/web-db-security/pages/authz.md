第二条：**鉴权之后还要授权**。知道你是谁，不等于你能删别人的留言。

```text
鉴权  你是谁（登录会话）
授权  你能做什么（本人/管理员）
```

每个会改数据的路由都要检查授权，不能只藏按钮。

## 两个词拆开

```text
鉴权：你是谁（会话）
授权：你能做什么（本人 / 管理员）
```

已登录只说明鉴权过了。删除别人的留言，还要授权检查失败并拒绝。

## 藏按钮不够

界面隐藏删除键，挡不住直接构造的请求。每个改数据的路由都要在服务器做授权。

## 落到删除接口

处理函数里应顺序想：会话里是谁？这条留言的作者是谁？当前身份是否允许删？任一否，就拒绝。

## 用自己的话收一下

回到本页的目标：围绕「Web 应用需要注意哪些基础安全问题？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。把例子再在脑子里走一遍，比急着记术语更有用。

@Callout(title: "认得你 ≠ 什么都能做", tone: "warning", accent: "amber") {
登录只解决身份；改数据前还要检查权限。
}

@Quiz(id: "web-db-security-page-authz.quiz-1", kind: "singleChoice") {
已登录用户调用删除接口想删别人的留言。服务器应？

@Option(id: "web-db-security-q2-deny", correct: true) {
检查授权并拒绝越权删除

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
登录≠可删任意内容。
}
}

@Option(id: "web-db-security-q2-allow") {
只要登录就允许删任何一条
}

@Option(id: "web-db-security-q2-css") {
用 CSS 隐藏就足够安全
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
越权必须在服务器拒绝。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
藏按钮挡不住直接请求。
}
}
