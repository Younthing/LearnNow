「小记」里从列表点进某一条，靠的是**链接**。链接元素常用 `a`，用属性 `href` 写出要点到的地址。

```text
<a href="/notes/2">查看第二条</a>
```

浏览器渲染后，「查看第二条」可点；点击通常触发新的 HTTP 请求，去取目标内容。

## 链接是内容的一部分

链接文字应说明去向，而不是满屏「点击这里」。对「小记」来说，「查看第二条」比「点我」更清楚。

```text
好的链接文字
└─ 说明目的地或动作

弱的链接文字
└─ 只有「点我」「这里」
```

## href 决定去哪

没有可用的 `href`，它就不像一个真正的去处。路径可以是站内路径，也可以是完整网址——入门先会写站内路径即可。

## 点击之后发生什么

点链接通常触发新的请求，去取 `href` 指向的资源。这把 HTML 结构与上一单元的 HTTP 成对模型接起来。

## 链接文字要说人话

「查看第二条」说明去向；满屏「点击这里」会让人迷失，也对辅助技术不友好。

回到本页的目标：围绕「链接和图片怎样加入网页？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "a + href", tone: "information", accent: "mint") {
链接由 a 标出身份，由 href 给出目标；点它通常会发起新的请求。
}

@Quiz(id: "web-html-links-page-anchor.quiz-1", kind: "singleChoice") {
列表项要链到 /notes/2。哪一项是关键结构？

@Option(id: "web-html-links-q1-ahref", correct: true) {
用 a 元素，并把 href 设为 /notes/2

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
身份与目标都齐了。
}
}

@Option(id: "web-html-links-q1-p") {
只用 p 包住地址文字，不需要 a
}

@Option(id: "web-html-links-q1-h1") {
把整页改成 h1 就会自动变成链接
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
链接需要 a，目标写在 href。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
段落里的纯文字地址，默认并不会变成可导航链接。
}
}
