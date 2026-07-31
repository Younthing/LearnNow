HTTP 请求默认很「健忘」：这一次请求和上一次之间，服务器并不自动知道是同一个人。可「小记」登录后希望连续几步都认得你。

**Cookie** 与 **Session** 就是为了在多次请求之间**保持可识别的状态**。

```text
第一次登录成功
  ↓
服务器记住你，并让浏览器持有一个可回传的记号
  ↓
之后每次请求带上记号
  ↓
服务器认出是你
```

## 问题先于机制

先记住要解决的问题：跨请求识别「还是同一个人 / 同一会话」。机制名称次之。

## 落到「小记」上

登录后点「我的留言」，应仍认得你。若每次请求都被当成陌生人，就只好反复登录，体验崩掉。

## 问题定义

```text
多次 HTTP 请求之间
如何保持可识别的状态
```

Cookie / Session 是常见答案；先记住问题，再记名词。

## 没有会话时的笨办法

每次请求都带用户名密码——既不安全也难用。会话机制就是为了避免这种笨办法。

回到本页的目标：围绕「Cookie 和 Session 解决什么问题？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "跨请求还认得你", tone: "information", accent: "mint") {
Cookie/Session 用来在多次 HTTP 请求之间保持可识别的登录或会话状态。
}

@Quiz(id: "web-server-session-page-problem.quiz-1", kind: "singleChoice") {
若完全没有会话机制，每次点「我的留言」都像陌生人。根因更接近？

@Option(id: "web-server-session-q1-stateless", correct: true) {
单次请求之间默认互不自动关联身份

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
HTTP 请求默认不记得你。
}
}

@Option(id: "web-server-session-q1-color") {
按钮颜色不对
}

@Option(id: "web-server-session-q1-ul") {
列表该用 ol
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺的是跨请求身份关联。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
样式与列表类型不解决身份记忆。
}
}
