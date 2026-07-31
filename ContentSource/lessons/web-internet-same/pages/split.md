打开手机浏览器，输入 `notes.example.com`，几秒后「小记」留言板出现在屏幕上。你用到了互联网，也用到了 Web——它们是一回事吗？

不是。**互联网**是能让设备互相传数据的网络；**Web** 是跑在这张网上的一种用法：用浏览器打开由链接串起来的页面。网很大，Web 只是其中一条常用通道。

## 先把两样东西分开

把「小记」这件事拆开看：你的手机和远方一台放着留言的计算机之间，需要一条能传数据的通路——这是互联网在做的事。

通路之上，浏览器还要按约定去要页面、渲染文字和链接——这是 Web 在做的事。

```text
互联网
└─ 设备之间能传数据

Web（用法之一）
├─ 浏览器要页面
├─ 服务器回页面
└─ 页面里有可点的链接
```

## 同一条网，不止一种用法

互联网上还能发邮件、传文件、打网络电话。这些都不靠打开网页，但都走同一张网。

Web 只覆盖「用浏览器看带链接的页面」这一类用法。说「上网」时，口语里常把两件事混着说；写程序时必须分开：先有通路，再选用法。

## 为什么这门课要先分清

若把网和 Web 混成一词，后面「浏览器请求」「页面结构」都会失去挂点。先立分界，后续单元才站得住。

## 同一条网的其他用法

邮件、文件传输、通话也可以走互联网，但不等于打开网页。本课只要求你能分开指认。

@Callout(title: "网与用法", tone: "information", accent: "mint") {
互联网是通路；Web 是通路上用浏览器打开链接页面的那一种用法。
}

@Quiz(id: "web-internet-same-page-split.quiz-1", kind: "singleChoice") {
你用邮件客户端收了一封邮件，没有打开任何网页。这件事主要依赖什么？

@Option(id: "web-internet-same-q1-net", correct: true) {
主要依赖互联网传数据；它不一定属于 Web

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
邮件走的是网上的另一套约定，不经过浏览器打开页面。
}
}

@Option(id: "web-internet-same-q1-web") {
主要依赖 Web，因为邮件也算上网
}

@Option(id: "web-internet-same-q1-both") {
必须同时是 Web，否则互联网传不过去
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
通路可以传很多种东西；只有浏览器打开链接页面这一路，才叫 Web。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问自己：这次有没有用浏览器打开一个由链接组成的页面？没有，就别先扣上 Web。
}
}
