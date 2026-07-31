第三条：**保护机密与会话**。密码不可明文存库；传输用加密通道；会话记号防盗与过期。

```text
密码  →  单向处理后再存
传输  →  避免明文口令上路
会话  →  防盗、可过期、可退出
```

## 收口：浏览器可用的应用

回看整门课：HTML 结构、CSS 外观、JS 行为、服务器路由与模板、数据库读写与账户——再加这些安全底线，才是「可以通过浏览器使用」且站得住的应用。

## 三条底线收口

```text
密码：不可明文存库
传输：避免口令明文上路
会话：防盗、可过期、可退出
```

## 回看整门课

HTML 结构、CSS 外观、JS 行为、服务器路由与模板、数据库读写与账户——再加上输入不可信、授权要检查、机密要保护，才是站得住的、可通过浏览器使用的应用。

## 和整门课的最后一扣

浏览器可用只是入口；站得住还要数据可信、权限正确、机密不裸奔。安全不是贴花，是底座。

回到本页的目标：围绕「Web 应用需要注意哪些基础安全问题？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "安全是底线不是附加题", tone: "warning", accent: "amber") {
校验输入、检查授权、保护密码与会话——与功能一起设计，而不是上线后再补。
}

@Quiz(id: "web-db-security-page-secret.quiz-1", kind: "singleChoice") {
用户表用明文保存密码。主要问题是？

@Option(id: "web-db-security-q3-leak", correct: true) {
库一旦泄露，密码可被直接滥用

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
明文密码不可接受。
}
}

@Option(id: "web-db-security-q3-ok") {
明文最安全，因为好核对
}

@Option(id: "web-db-security-q3-html") {
HTML 会自动加密数据库
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
密码必须经安全处理后存储。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
HTML 不会替你加密用户表。
}
}
