当多条规则打到同一元素，需要知道**谁更具体、谁后写**会影响结果。入门抓一条实用规则：能写得更具体，就少靠「碰巧的顺序」。

## 更具体通常更优先（入门版）

```text
p          较宽
.note      更具体
p.note     又更具体一点
```

（完整优先级规则以后再细化；此处只立「更具体」的直觉。）

## 调试思路

样式没生效时：先看选择器是否命中，再看是否被更具体的规则盖住，最后才怀疑属性写错。

## 落到「小记」上

你给所有 `p` 设了灰色，又给 `.note` 设了黑色。一条留言同时是段落又带 `note` 类时，更具体的那条通常压过更宽的那条。

## 排查三步

```text
1 选择器命中了吗
  ↓
2 有没有更具体的规则盖住
  ↓
3 属性本身是否写错
```

不要一上来就怀疑「浏览器坏了」；大多数时候是选错人或被盖住。

完整优先级表以后再学。现在只要养成习惯：能写得更具体，就少靠「碰巧谁写在后面」。

回到本页的目标：围绕「选择器怎样找到网页元素？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "没命中就谈不上生效", tone: "information", accent: "mint") {
排查样式：先确认选中了目标，再谈属性与覆盖。
}

@Quiz(id: "web-css-selectors-page-specific.quiz-1", kind: "singleChoice") {
你给所有 p 设了灰色，又给 .note 设了黑色，某条留言同时是 p.note。按「更具体」的入门直觉，文字颜色更可能跟谁？

@Option(id: "web-css-selectors-q2-note", correct: true) {
更跟 .note 走

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
类别选择通常比单纯标签更具体。
}
}

@Option(id: "web-css-selectors-q2-p") {
一定跟所有 p 的灰色，类别无效
}

@Option(id: "web-css-selectors-q2-random") {
颜色会随机闪烁
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
更具体的规则通常压过更宽的规则。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
比较：选中「所有段落」宽，还是选中「note 类」窄？
}
}
