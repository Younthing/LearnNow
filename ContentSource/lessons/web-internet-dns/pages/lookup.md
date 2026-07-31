打开「小记」时，浏览器不会凭空知道门牌。它会发起查找：问「`notes.example.com` 现在对应哪个地址？」拿到答案后再去连接。

## 查找发生在连接之前

把上一课的五步补一行细节：

```text
输入域名
  ↓
查找：名字 → IP
  ↓
用 IP 去连接服务器
  ↓
再发请求、收响应、绘制
```

查找失败，后面的连接就不会开始——这常表现为「找不到服务器」。

## 本课边界

真实世界里查找会经过多层缓存与专门的解析服务，细节很多。入门只要抓住：**先解析名字，再连接门牌**。下一课才把「发请求 / 收响应」的约定展开成 HTTP。

## 落到打开失败

提示「无法解析主机名」时，名字还没变成门牌，后面的 HTTP 还没真正开始。这和「已经取到页面但画坏了」不是同一类问题。

## 本课边界

多层缓存与权威解析服务的细节很多。入门只抓顺序：先解析，再连接，再请求。

回到本页的目标：围绕「域名和 IP 地址有什么关系？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "先有门牌再敲门", tone: "information", accent: "mint") {
连服务器之前，通常先把域名解析成 IP；解析失败，请求还发不出去。
}

@Quiz(id: "web-internet-dns-page-lookup.quiz-1", kind: "singleChoice") {
你输入域名后立刻看到「DNS 错误 / 无法解析该主机名」。按本课顺序，问题卡在哪？

@Option(id: "web-internet-dns-q2-lookup", correct: true) {
名字还没变成可用的 IP

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
解析失败时，连接和 HTTP 都还没真正开始。
}
}

@Option(id: "web-internet-dns-q2-paint") {
页面已经下载完，只是颜色画错了
}

@Option(id: "web-internet-dns-q2-html") {
一定是 HTML 标签写错了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
主机名无法解析＝查找名字失败，属于连接前的问题。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
若已经在渲染页面，你通常不会看到「无法解析主机名」这种提示。
}
}
