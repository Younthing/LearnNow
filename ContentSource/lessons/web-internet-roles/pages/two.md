你在浏览器里打开「小记」。屏幕上出现留言列表——这些字当时存在你手机里吗？通常不。

浏览器和服务器是两端：**浏览器**在你这边，负责发出请求、把收到的内容画成页面；**服务器**在远端，负责听请求、找出该回的内容再送回来。

## 一次打开，两端分工

把打开 `notes.example.com` 画成两端对话：

```text
你的浏览器
  ↓  我要小记首页
远端服务器
  ↓  这是首页内容
你的浏览器
  →  画成你看见的页面
```

没有浏览器，你看不到页面；没有服务器，浏览器没有东西可画。两端缺一，Web 这一路就断了。

## 别把「网站」理解成一块铁板

口语说「上小记网站」，其实至少有两台角色在配合：你这边的浏览程序，和远端那台（或一群）提供内容的计算机。

本课里「服务器」先当一个角色名用：专门应答浏览器请求的那一端。后面会拆它内部还有程序、数据库等，现在先抓住分工。

## 口语里的「网站」

说「上小记网站」时，至少有两端在配合。排错时问：是浏览器没要到，还是服务器没给对？

## 服务器此处是角色名

先当「应答请求的那一端」。内部还有程序、数据库，后面单元再拆开。

@Callout(title: "一端要，一端给", tone: "information", accent: "mint") {
浏览器负责要和画；服务器负责听和给。页面是两端配合的结果。
}

@Quiz(id: "web-internet-roles-page-two.quiz-1", kind: "singleChoice") {
「小记」首页上的留言文字，在你点开网址之前，通常主要存放在哪一端？

@Option(id: "web-internet-roles-q1-server", correct: true) {
远端服务器那一端

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
浏览器打开前，列表内容一般由服务器保管；浏览器只是来取。
}
}

@Option(id: "web-internet-roles-q1-browser") {
已经完整预装在浏览器里
}

@Option(id: "web-internet-roles-q1-phone-only") {
只存在你手机相册里
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
浏览器是来取和展示的；长久存放留言的，通常是服务器这边。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
回想分工图：谁在「给」内容？给的那一端才是服务器。
}
}
