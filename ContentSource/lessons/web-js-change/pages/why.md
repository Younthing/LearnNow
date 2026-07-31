HTML 定内容，CSS 定外观。若要点「发布」后立刻提示「字数超了」，或把按钮变成「发送中…」，需要页面在浏览器里**当场变化**。这是 JavaScript 常见职责。

JS 在你的浏览器里运行，可以读取页面现状、修改元素、响应点击等操作——不必每次都整页向服务器再要一份全新 HTML（当然也可以配合请求）。

## 变化发生在浏览器端

```text
你点击
  ↓
JS 运行一段逻辑
  ↓
页面上的字/状态立刻改
```

这种即时反馈，单靠静态 HTML+CSS 很难表达完整。

## 它不取代服务器

JS 很强，但不能单独保证「所有人看到的留言库」一致——共享数据仍要服务器与数据库。本单元先抓：浏览器里的变化从哪来。

## 落到「小记」上

输入时字数从 `0` 变成 `12`，发布按钮短时间显示「发送中…」——这些都是当前页上的即时变化。整页刷新再回来当然也能变，但体验会顿一下。

## 和服务器的边界

JS 不能单独保证全站留言库一致。它擅长的是：在浏览器里快速反应。持久共享仍走服务器。

@Callout(title: "JS 让页面会反应", tone: "information", accent: "mint") {
JavaScript 在浏览器里运行，使页面能响应操作并即时改内容或状态。
}

@Quiz(id: "web-js-change-page-why.quiz-1", kind: "singleChoice") {
输入留言时，字数统计在输入过程中从 0 变成 12，没有刷新整页。更可能是谁在起作用？

@Option(id: "web-js-change-q1-js", correct: true) {
浏览器里的 JavaScript 在响应输入并改页面文字

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
即时改字数是典型的端上脚本行为。
}
}

@Option(id: "web-js-change-q1-css") {
只靠 CSS 颜色规则自动数数
}

@Option(id: "web-js-change-q1-dns") {
域名解析在计数
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
不整页刷新却改文字，通常是 JS。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
CSS 不管「数多少个字」这种逻辑。
}
}
