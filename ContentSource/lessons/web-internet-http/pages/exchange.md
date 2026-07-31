连上服务器之后，浏览器和服务器要按同一套说话方式交换内容。这套在 Web 里最常见的约定叫 **HTTP**：浏览器发出**请求**，服务器返回**响应**。

打开「小记」首页，可以想成一问一答：浏览器问「请给我首页」；服务器答「给你，这是内容，状态是成功」。

## 请求里至少有什么

入门先抓三件：

```text
请求
├─ 要做什么（例如获取）
├─ 要哪一个路径（例如 / ）
└─ 其他说明（稍后细讲）
```

你不必背字段名。先建立：请求＝有目的地的一次「我要…」。

## 响应里至少有什么

```text
响应
├─ 结果状态（成功 / 找不到 / 出错…）
└─ 正文内容（页面、数据等）
```

状态和正文是两层信息：正文可能是空的，但状态仍会告诉你「为什么空」。

## 落到「小记」上

地址栏回车后，浏览器发出「给我首页」的请求；服务器返回状态与正文。你看见的留言列表，就在那次响应的正文里（或由其再引发的后续请求里）。

## 状态和正文都重要

正文可能为空，但状态仍会说明「找不到」或「出错」。排错时两者都要看。

@Callout(title: "一问一答", tone: "information", accent: "mint") {
HTTP 把浏览器和服务器的对话约定成：先有请求，再有响应。
}

@Quiz(id: "web-internet-http-page-exchange.quiz-1", kind: "singleChoice") {
打开「小记」时，浏览器向服务器要首页。按本课说法，这件事首先是一次什么？

@Option(id: "web-internet-http-q1-req", correct: true) {
一次 HTTP 请求

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
「我要首页」是浏览器发出的请求。
}
}

@Option(id: "web-internet-http-q1-resp-only") {
只是一次响应，因为页面马上就出现了
}

@Option(id: "web-internet-http-q1-dns") {
只是一次域名解析，还没有请求
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
要页面＝发请求；随后才有响应带回内容。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
解析发生在连接前；已经在「要首页」时，你已经进入请求这一步。
}
}
