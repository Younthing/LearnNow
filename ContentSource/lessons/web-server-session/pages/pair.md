入门配对模型：

```text
Cookie
└─ 浏览器保存并自动带回的小记号

Session
└─ 服务器侧保存的会话数据（常靠记号找到）
```

浏览器持有记号（Cookie），服务器用记号找到会话内容（Session）。具体框架细节各异，但这条分工稳。

## 安全钩子

记号被盗等于会话被盗。后面安全课会谈更严的防护；这里先立：会话机制让「登录态」成为可能，也引入了保护记号的责任。

## 分工怎么记

```text
Cookie：浏览器保存并带回的记号
Session：服务器侧的会话数据
```

记号像钥匙，会话像柜子。下次请求带回钥匙，服务器打开柜子看到 `userId`。

## 安全钩子

钥匙被盗，柜子也被打开。后面安全课会谈保护；这里先立：会话让登录态成为可能，也带来保护记号的责任。

## 退出登录在做什么

清除或作废记号与会话，下一次请求就不再自动认你。这是会话机制的对称动作。

回到本页的目标：围绕「Cookie 和 Session 解决什么问题？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "记号在浏览器，会话在服务器", tone: "information", accent: "mint") {
常见做法是浏览器回传 Cookie 记号，服务器据此找到 Session 数据。
}

@Quiz(id: "web-server-session-page-pair.quiz-1", kind: "singleChoice") {
登录后服务器在会话里记下 userId，浏览器保存会话记号。下次请求怎样认出你？

@Option(id: "web-server-session-q2-token", correct: true) {
浏览器带回记号，服务器用记号找到会话里的 userId

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
记号是钥匙，会话是柜子。
}
}

@Option(id: "web-server-session-q2-guess") {
服务器靠猜你的生日
}

@Option(id: "web-server-session-q2-css") {
靠 CSS 变量保存 userId
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
记号 ↔ 会话数据，是跨请求识别的常用桥。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
CSS 不负责身份会话。
}
}
