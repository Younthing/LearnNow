地址栏输入 `notes.example.com` 回车，屏幕转一下，留言板出来。中间这几秒发生了什么？

可以先记一条短链：**解析地址 → 连上服务器 → 发出请求 → 收到响应 → 画成页面**。细节后面两课再拆；这一页先把顺序立住。

## 五步顺序

用「小记」走一遍最小顺序：

```text
1 读懂你要去哪
  ↓
2 找到并连上服务器
  ↓
3 浏览器说出要什么
  ↓
4 服务器回送内容
  ↓
5 浏览器画到屏幕
```

少任一步，你都看不到完整页面。平时觉得「打开很快」，是这五步被压进了很短的时间。

## 你看见的「转圈」落在哪

转圈多半发生在第 2～4 步：还在找路、还在等服务器、或内容还在路上。第 5 步开始后，你会看到标题、列表一点点出现。

## 用「小记」默念一遍

输入域名后，心里按五步走：读懂去向、连上服务器、发出请求、收到响应、画到屏幕。平时很快，是因为五步被压进短时间。

## 和前后课的接口

「读懂去向」里的名字与门牌，是 DNS 课；「请求与响应」的约定，是 HTTP 课。本课只立总顺序。

@Callout(title: "先记顺序", tone: "information", accent: "mint") {
打开网址＝找到服务器、要内容、拿内容、再画出来。顺序比术语更重要。
}

@Quiz(id: "web-internet-url-flow-page-steps.quiz-1", kind: "singleChoice") {
地址栏回车之后，浏览器还没画出任何留言，但状态栏显示「正在等待 notes.example.com」。按五步模型，最可能停在哪一段？

@Option(id: "web-internet-url-flow-q1-wait", correct: true) {
已发出请求，仍在等服务器返回

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
「正在等待」说明要的动作已发生，给的动作还没完成。
}
}

@Option(id: "web-internet-url-flow-q1-paint") {
已经在画页面，只是你没看见
}

@Option(id: "web-internet-url-flow-q1-done") {
五步都结束了，只是故意转圈
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
等待服务器，落在「要了之后、给了之前」这一段。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
对照五步：已经画出来了吗？没有。还在等谁？等回送内容的那一端。
}
}
