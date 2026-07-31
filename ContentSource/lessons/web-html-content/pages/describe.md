服务器把「小记」首页送回浏览器时，正文常常是一段 HTML：它不负责好看，只负责**说清楚页面里有什么**。

HTML 用带尖括号的标记，把「这是标题」「这是一段话」「这是一个按钮」标出来。浏览器读懂这些标记，才知道该把哪些字当成标题、哪些当成正文。

## 内容先于长相

同一段留言，可以换成完全不同的颜色和字体，但「这是一条留言、这是作者名」这些结构还在。结构由 HTML 描述；长相主要交给后面的 CSS。

```text
HTML 在说
├─ 这里是标题
├─ 这里是段落
└─ 这里是提交按钮

还没说
├─ 字体多大
└─ 按钮什么颜色
```

## 最小印象

看一行示意（不必背语法细节）：

```text
<h1>小记</h1>
<p>今天学了 Web。</p>
```

尖括号里的词告诉浏览器：上一行是一级标题，下一行是段落。

## 落到「小记」上

首页至少要标出：站点标题、留言列表、发布入口。先把这些「是什么」说清，颜色和动效才有附着点。

## 读标记的是浏览器

你写尖括号，用户看到的是渲染结果。标记的价值是给浏览器（以及后续 CSS/JS）可识别的结构。

@Callout(title: "HTML 说「是什么」", tone: "information", accent: "mint") {
HTML 描述页面上有哪些内容块；它不负责最终好不好看。
}

@Quiz(id: "web-html-content-page-describe.quiz-1", kind: "singleChoice") {
「小记」首页需要标明「留言列表」和「发布按钮」各是什么。按本课，这件事首先该由谁承担？

@Option(id: "web-html-content-q1-html", correct: true) {
HTML：先把内容和角色说清楚

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
先标明是什么，浏览器和其他技术才有依附点。
}
}

@Option(id: "web-html-content-q1-css") {
只写 CSS 颜色，不标内容也能自动懂
}

@Option(id: "web-html-content-q1-dns") {
改域名解析就会自动生成内容结构
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
内容和角色是 HTML 的活；颜色是后话。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问：我们要先让浏览器知道「这是按钮」还是先让它变蓝？先知道是什么。
}
}
