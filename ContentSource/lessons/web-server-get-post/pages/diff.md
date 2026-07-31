HTTP 请求带有**方法**。入门最常见的两个：`GET` 与 `POST`。

打开「小记」列表，多半是 GET：主要意图是**取回**资源来看。提交新留言，多半是 POST：主要意图是**提交数据让服务器处理/创建**。

```text
GET   偏向取回
POST  偏向提交并引发处理
```

（现实中还有 PUT、DELETE 等，本课先抓住这一对。）

## 差异不止名字

GET 的参数常出现在 URL 查询串，易被收藏、缓存、出现在日志；POST 的主体数据放在请求体，更适合送表单内容。入门先记意图差异。

## 落到「小记」上

打开列表看留言，意图是取回；点发布送出正文，意图是提交处理。方法名提醒的是意图，而不只是拼写。

## 参数放哪（入门印象）

GET 的查询常出现在 URL 里，方便分享，也更容易进日志；POST 的主体更适合放表单正文。细节框架各异，先记意图差异。

## 用自己的话收一下

回到本页的目标：围绕「GET 和 POST 有什么区别？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "取回 vs 提交", tone: "information", accent: "mint") {
GET 侧重取回查看；POST 侧重提交数据让服务器处理。
}

@Quiz(id: "web-server-get-post-page-diff.quiz-1", kind: "singleChoice") {
用户只是刷新「小记」首页看最新列表。更常见的是哪种方法？

@Option(id: "web-server-get-post-q1-get", correct: true) {
GET：取回列表

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
看列表是取回。
}
}

@Option(id: "web-server-get-post-q1-post") {
POST：即使只看也要提交空表单
}

@Option(id: "web-server-get-post-q1-dns") {
既不是 GET 也不是 POST，而是 DNS
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
查看列表用 GET。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
DNS 不是 HTTP 方法。
}
}
