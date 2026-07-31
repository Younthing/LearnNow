登录：提交账号密码 → 服务器取出用户记录比对 → 成功则**建立会话**（Cookie/Session）→ 后续请求认得你。

```text
登录表单
  ↓
查找用户并核验
  ↓
成功：建立会话
失败：提示错误（勿泄露过多细节）
```

登录不「重新注册」，只是核验并打开会话。

## 与留言的关系

有了会话里的 userId，发留言时可记录作者，删改时可检查是否本人或管理员。

## 登录不是再注册一次

```text
提交凭证
  ↓
查找并核验
  ↓
成功则建立会话
```

核验通过后，靠 Cookie/Session 让后续请求仍认得你。失败时提示宜谨慎，避免泄露「用户名是否存在」过多细节（进阶话题，此处点到为止）。

## 和留言的关系

会话里有了 `userId`，发帖可记作者，删帖可查是否本人。

## 失败也要有路径

密码错误时应回到可重试的状态，并给出可读提示。不要静默失败，也不要在提示里泄露过多账户信息。

回到本页的目标：围绕「用户注册和登录怎样实现？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "登录＝核验并开会话", tone: "information", accent: "mint") {
登录成功后建立会话，而不是再插一条重复用户。
}

@Quiz(id: "web-db-auth-page-login.quiz-1", kind: "singleChoice") {
密码正确后，为让后续请求认得用户，服务器还应做什么？

@Option(id: "web-db-auth-q2-session", correct: true) {
建立会话（并让浏览器持有相应记号）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
会话连接多次请求。
}
}

@Option(id: "web-db-auth-q2-only") {
什么都不做，靠用户改自己的 HTML
}

@Option(id: "web-db-auth-q2-css") {
把密码写进 CSS 注释
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
登录成功要落到会话。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
不建会话，下一请求又成陌生人。
}
}
