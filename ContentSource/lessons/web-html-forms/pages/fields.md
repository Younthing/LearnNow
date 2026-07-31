常见控件：单行文本用 `input`，多行留言用 `textarea`，选项可用 `select` 等。入门先抓住文本输入。

## name 很重要

控件要有 `name`，提交时服务器才知道「哪一个字段叫什么」。只有框、没有名字，数据很难对上号。

```text
textarea name="body"
→ 提交时带上 body=用户写的字
```

## label 说清用途

用标签文字说明「这是留言正文」，不要只留一个空白框。清楚的说明减少填错。

## 落到「小记」上

多行留言用合适的控件，并给它 `name="body"`。提交后服务器才能把内容认作正文，而不是无名数据。

## label 也是结构的一部分

清楚的文字说明减少填错。空白框加一个「留言正文」标签，比只有框更可用。

同一个 `body`，会从 HTML 走到服务器变量，再走进数据库列。中途改名一次，就多一次对不齐的风险。

回到本页的目标：围绕「怎样创建网页表单？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "有框还要有名", tone: "information", accent: "mint") {
输入控件既要能填，也要有 name，提交后才能对上字段。
}

@Quiz(id: "web-html-forms-page-fields.quiz-1", kind: "singleChoice") {
留言框能输入，但提交后服务器完全不知道这是「正文」还是别的字段。最可能缺了什么？

@Option(id: "web-html-forms-q2-name", correct: true) {
控件缺少 name（或 name 不对）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
没有字段名，后端难以对号入座。
}
}

@Option(id: "web-html-forms-q2-h2") {
页面少了一个 h2
}

@Option(id: "web-html-forms-q2-alt") {
input 缺少 alt
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
字段名是提交数据可识别的关键部分。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
alt 是图片的事；这里问的是提交字段身份。
}
}
