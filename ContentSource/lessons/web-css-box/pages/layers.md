在 CSS 眼里，许多元素都是一个**盒子**：内容在中间，外面可以有内边距、边框、外边距。这就是**盒模型**。

「小记」两条留言之所以隔开，常常是盒子的外边距或内边距在起作用，而不只是你「感觉空了一下」。

## 由内到外

```text
内容 content
  ↑ 内边距 padding
  ↑ 边框 border
  ↑ 外边距 margin
```

改「盒子总占地」，要分清你改的是哪一层。

## 为什么要拆层

只说「弄大一点」会混：是字变大、空白变多，还是边框变厚？拆层后指令才精确。

## 落到「小记」上

两条留言看起来「粘在一起」，往往不是字太小，而是盒子的外边距太小。边框画出来之后，你更容易分清：挤的是框内，还是框与框之间。

## 改之前先指层

```text
想让字离边框远一点  →  padding
想让两条留言分开    →  margin
想看见一圈线        →  border
```

同一句「弄大一点」，落在不同层，结果完全不同。

跟别人描述间距问题时，试着说「我想加大外边距」或「我想加大内边距」，而不是只说「再空一点」。词汇精确，沟通成本会下降。

@Callout(title: "元素是盒子", tone: "information", accent: "mint") {
内容、内边距、边框、外边距一层层向外；间距问题先问改的是哪一层。
}

@Quiz(id: "web-css-box-page-layers.quiz-1", kind: "singleChoice") {
两条留言之间要拉开距离，但留言文字本身与边框的距离保持不变。更该动哪一层？

@Option(id: "web-css-box-q1-margin", correct: true) {
外边距 margin（盒子与盒子之间）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
盒与盒的空隙主要看外边距。
}
}

@Option(id: "web-css-box-q1-content") {
只把正文字号加到极大
}

@Option(id: "web-css-box-q1-dns") {
改域名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
盒间距优先看 margin。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
文字到边框的距离是 padding；题干说那部分不变。
}
}
