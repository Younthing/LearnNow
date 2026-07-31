「小记」的 HTML 已经标出标题和列表。若要拉开间距、换字体颜色，轮到 **CSS**：它回答页面**长什么样**。

CSS 用规则描述：选中哪些元素，对这些元素设置哪些外观属性。

## 一条规则的形状

```text
选中谁
  ↓
改哪些外观
例如 颜色、字号、间距
```

同一段 HTML，换一套 CSS，观感可以完全不同，内容结构仍在。

## 外观不是内容

把「留言正文」改成蓝色，并不改变它仍是段落。CSS 改的是呈现，不是把段落变成链接。

## 为什么要单独学这一层

如果把颜色全写进每个 HTML 标签，改一版皮肤就要翻遍全文。「小记」换深色模式时，你希望改一处规则，而不是改一百条留言标记。

| 改变 | 更像谁的活 |
| --- | --- |
| 颜色、间距、字体 | CSS |
| 标题还是段落 | HTML |
| 点击后字数变化 | JavaScript |

## 先问改的是不是长相

下一单元之前，遇到「变色、变空、变字体」优先想到 CSS；遇到「这是不是按钮」仍回 HTML。

回到本页的目标：围绕「CSS 怎样控制网页外观？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "CSS 管长相", tone: "information", accent: "mint") {
CSS 给已有内容块设置外观；它不替代 HTML 去描述「这是什么」。
}

@Quiz(id: "web-css-style-page-look.quiz-1", kind: "singleChoice") {
希望「小记」所有留言正文变成更深的灰色，但结构不变。这首先是谁的职责？

@Option(id: "web-css-style-q1-css", correct: true) {
CSS：改外观，不改内容角色

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
颜色属于长相。
}
}

@Option(id: "web-css-style-q1-html-only") {
只能改 HTML 标签名才能变色
}

@Option(id: "web-css-style-q1-dns") {
改 IP 地址就会变色
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
变色是外观问题，交给 CSS。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
标签名改了会改变「是什么」，不是改颜色的正道。
}
}
