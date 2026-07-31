内边距撑的是「边框以内的空白」；外边距撑的是「盒子与邻居之间的空白」。边框则是可见的那圈线。

## 对照

| 层 | 主要影响 |
| --- | --- |
| padding | 内容与边框的距离 |
| border | 可见边界 |
| margin | 与外部邻居的距离 |

## 排错口诀

「里面空」先看 padding；「外面空」先看 margin；「有没有线」看 border。

## 先画再改

把一只留言盒子画成四层，改空白时先问：空在边框**里面**还是**外面**？

```text
内容
↑ padding（里面空）
↑ border
↑ margin（外面空）
```

## 常见混法

有人用很大的 `padding` 去硬撑两条留言的间距，结果每条盒子内部空荡荡，列表却仍可能不够疏。列表项之间的缝，优先看 `margin`。

上一条和下一条之间的缝，优先调外边距；某条留言文字贴着自己边框，优先调内边距。先分清「盒与盒」还是「字与框」，再动手。

回到本页的目标：围绕「盒模型是什么？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "里面空还是外面空", tone: "information", accent: "mint") {
先判断空白在边框内还是边框外，再选择 padding 或 margin。
}

@Quiz(id: "web-css-box-page-space.quiz-1", kind: "singleChoice") {
留言盒子有边框。文字贴着边框太挤，但与下一条留言的间距已经合适。该优先加什么？

@Option(id: "web-css-box-q2-pad", correct: true) {
增大 padding

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
内容与边框太近＝内边距不足。
}
}

@Option(id: "web-css-box-q2-mar") {
只增大 margin
}

@Option(id: "web-css-box-q2-href") {
给盒子加 href
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
贴边框＝边框内空白问题。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
margin 会改变与邻居的距离，而题干说邻居间距已合适。
}
}
