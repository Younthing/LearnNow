「小记」每条详情页结构相似，只有标题和正文不同。服务器可以用**模板**：一份带占位符的 HTML 样子，填入本次数据后再当作响应正文送出。

```text
模板：标题＝{{title}}
  ↓ 填入第 2 条数据
成品 HTML
  ↓
作为响应送回浏览器
```

这样不必为每条留言手写一个完整静态文件。

## 动态页 ≠ 必须上复杂前端框架

入门模型足够：请求进来 → 取数据 → 填模板 → 返回 HTML。浏览器仍接收 HTML，只是这份 HTML 是现场生成的。

## 落到「小记」上

一百条详情页，结构几乎一样，变的是标题和正文。模板让你维护一份结构，按数据生成多次页面。

## 生成发生在服务器

```text
取到第 2 条数据
  ↓
填进模板
  ↓
得到这一次的 HTML 响应
```

浏览器仍在接收 HTML；这份 HTML 是现场生成的，不是手写一百份静态文件。

## 和静态文件的差别

静态 HTML 改一条字段要改文件；模板改的是数据源，结构仍是一份。数据一变，页面跟着变。

回到本页的目标：围绕「模板怎样生成动态网页？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "模板生成响应正文", tone: "information", accent: "mint") {
模板提供结构，数据填入占位符，得到这一次的 HTML 响应。
}

@Quiz(id: "web-server-templates-page-dynamic.quiz-1", kind: "singleChoice") {
有 100 条留言详情结构相同。用模板的主要好处是？

@Option(id: "web-server-templates-q1-one", correct: true) {
维护一份结构，按数据生成多次页面

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
结构复用，数据变化。
}
}

@Option(id: "web-server-templates-q1-hundred") {
必须手写 100 份完全无关的 HTML 文件
}

@Option(id: "web-server-templates-q1-no") {
模板会禁止使用 HTML
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
模板解决结构重复。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
手写 100 份最难维护。
}
}
