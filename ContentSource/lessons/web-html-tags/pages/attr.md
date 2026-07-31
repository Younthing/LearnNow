属性用来补充「这是什么」之外的信息：给元素起个可查找的名字、指明链接去哪、图片源在哪。

## 属性不改变「基本身份」

`p` 仍然是段落；加了 `class="note"` 只是多了一个可供样式或脚本识别的记号。身份由标签名定，属性是补充。

```text
元素身份   由标签名决定（如 p、a、img）
补充信息   由属性提供（如 class、href、src）
```

## 常见误解

以为属性是另一套标签，或以为只有外观才用属性。其实链接地址、图片地址都是属性，它们首先是内容结构的一部分。

## 落到链接与图片

`href`、`src`、`alt`、`class` 都是属性：它们补充信息，但不替代标签名给出的身份。

## 没有属性会怎样

许多元素仍可存在，只是信息变少：链接缺 `href` 就没有明确去处，图片缺 `src` 就没有图可取。

`href` 的值是地址，`class` 的值是类别名。写错值与写错属性名一样会导致功能对不上。

回到本页的目标：围绕「标签、元素和属性有什么区别？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "属性是补充说明", tone: "information", accent: "mint") {
标签名定身份，属性加说明；没有属性，元素往往仍在，只是信息更少。
}

@Quiz(id: "web-html-tags-page-attr.quiz-1", kind: "singleChoice") {
「小记」里一条链接用 `a` 元素，并带有 `href="/notes/2"`。其中决定「这是链接」的主要是什么？

@Option(id: "web-html-tags-q2-tag", correct: true) {
标签名 a

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
身份由 a 决定；href 告诉它去哪里。
}
}

@Option(id: "web-html-tags-q2-href") {
只有 href，没有 a 也能当链接
}

@Option(id: "web-html-tags-q2-text") {
只有文字「第二条」本身
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
标签名定身份，属性补目标地址。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
去掉 a、只留文字，还能点出跳转吗？不能。
}
}
