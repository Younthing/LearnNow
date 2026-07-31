请求和响应成对出现：先问后答。浏览「小记」时，点一条留言链接往往会再发起一次新的请求，服务器再给一次新的响应。

## 成对，但不等于「只问一次」

一次打开页面可能触发多次请求：正文、图片、样式等可以各问一次。入门模型仍是：**每一次要东西，都是一次请求，并对应一次响应**。

| 动作 | 角色 |
| --- | --- |
| 我要… | 请求 |
| 给你…（含状态） | 响应 |

## 和后面课程的接口

HTML、CSS、JavaScript 常作为响应正文来到浏览器；表单提交会变成新的请求；服务器程序决定响应里放什么。本课只把「请求/响应」这对词钉牢。

## 一次页面里的多次请求

打开「小记」时，正文、样式、图标可能各问一次。模型仍然是：每一次要东西，都是一对请求与响应。

```text
要首页 HTML  →  一对
要样式文件  →  一对
要点进详情  →  新的一对
```

## 和后面课程的接口

HTML/CSS/JS 常作为响应正文到达；表单提交变成新的请求。先把「成对」钉牢。

@Callout(title: "每次要东西都是一对", tone: "information", accent: "mint") {
点链接、提交表单、刷新页面，通常都会再走一轮请求与响应。
}

@Quiz(id: "web-internet-http-page-pair.quiz-1", kind: "singleChoice") {
你在「小记」点开第二条留言，地址变了，内容也变了。按本课模型，最准确的描述是？

@Option(id: "web-internet-http-q2-new", correct: true) {
浏览器发出了新的请求，服务器给了新的响应

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
换内容通常就是新的一问一答。
}
}

@Option(id: "web-internet-http-q2-local") {
只在手机本地改了显示，服务器完全不知道
}

@Option(id: "web-internet-http-q2-one-forever") {
还在用打开首页那唯一一次响应，从未再请求
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
导航到新地址，通常伴随新的请求/响应对。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
地址变了还只靠旧响应，服务器怎么知道你要第二条？
}
}
