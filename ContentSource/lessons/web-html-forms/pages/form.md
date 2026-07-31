「小记」要让用户写下留言，就要用**表单**：一组用来收集输入并提交的控件。

表单元素常用 `form` 包住输入框和按钮。它回答的是：用户要填什么，以及填完后送到哪里（后续单元会接服务器）。

## 表单是容器

```text
form
├─ 输入控件（文本框等）
└─ 提交控件（按钮）
```

没有容器，控件仍可能显示，但「一起提交」的边界会变模糊。先建立：表单＝一组要一起带走的输入。

## 和普通段落的不同

段落给人读；表单控件供人填。留言区不是一段写死的 `p`，而是可编辑的输入控件。

## 为什么需要容器

输入框和按钮若散落各处，浏览器很难判断「哪些字段属于同一次发布」。`form` 给出边界：这些控件的数据要一起走。

## 和普通正文的差别

段落给人读；控件供人填。留言区是可编辑输入，不是写死的一段 `p`。

回到本页的目标：围绕「怎样创建网页表单？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "表单收集输入", tone: "information", accent: "mint") {
form 把要提交的控件收在一起，准备把用户填写的数据送走。
}

@Quiz(id: "web-html-forms-page-form.quiz-1", kind: "singleChoice") {
「小记」发布区有一个多行文本框和一个「发布」按钮。按本课，它们通常应放在什么结构里？

@Option(id: "web-html-forms-q1-form", correct: true) {
放在同一个 form 里，表示一起提交

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
同一份留言数据应落在同一表单边界内。
}
}

@Option(id: "web-html-forms-q1-h1") {
各自包在单独的 h1 里
}

@Option(id: "web-html-forms-q1-img") {
用 img 代替，因为图片也能输入
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
要一起提交的控件，放进同一个 form。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问：这些控件是不是同一份「发布留言」数据的一部分？
}
}
