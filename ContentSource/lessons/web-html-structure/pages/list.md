留言列表适合用列表元素表达「多条并列」，而不是手写一堆无关联段落。

## 无序与有序

```text
ul / li   条目并列，顺序不强调
ol / li   条目有步骤或名次
```

「小记」留言流通常用无序列表；「发留言三步骤」说明可用有序列表。

## 为什么要用列表

屏幕阅读器和后续样式都能识别「这是一组条目」。若只用段落硬挤，机器和人都更难看清边界。

| 内容 | 更合适 |
| --- | --- |
| 多条留言 | ul + li |
| 操作步骤 | ol + li |
| 一段说明 | p |

## 落到「小记」上

留言流是多条并列，适合列表；「发布三步骤」有先后，适合有序列表。不要把一切都挤成无差别段落。

## 机器也受益

列表让「一组条目」对样式和辅助技术更清晰。结构选对了，后面的 CSS 更好写。

每一项可以再包含段落或链接，但不要为了「好看」把无关块硬塞进列表。列表表达的是一组同级条目。

回到本页的目标：围绕「怎样组织网页的标题、段落和列表？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "并列就用列表", tone: "information", accent: "mint") {
多条同级信息用列表；步骤用有序列表；单一说明用段落。
}

@Quiz(id: "web-html-structure-page-list.quiz-1", kind: "singleChoice") {
帮助页要写「发布留言的三步」。按本课，结构上更合适的是？

@Option(id: "web-html-structure-q2-ol", correct: true) {
有序列表，强调步骤顺序

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
有先后的步骤，用 ol 更贴切。
}
}

@Option(id: "web-html-structure-q2-ul") {
无序列表，因为三步谁先谁后无所谓
}

@Option(id: "web-html-structure-q2-h1") {
三个并列的 h1 主标题
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
有顺序的步骤用有序列表表达。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
若打乱三步会做错，就说明顺序重要。
}
}
