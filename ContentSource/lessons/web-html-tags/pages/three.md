写「小记」标题时，你会碰到三个常混的词：**标签**、**元素**、**属性**。

先看最小例子：

```text
<p class="note">今天学了 HTML。</p>
```

`p` 出现在尖括号里，叫标签名；从头到尾这一整块（含文字）叫一个元素；`class="note"` 这种写在开始标签里的附加信息叫属性。

## 三个词各指什么

```text
标签   尖括号里的名字与写法
  ↓
元素   标签加上中间的内容（及结束标签）
  ↓
属性   写在开始标签里的额外说明
```

口语里有人把三者混称「标签」，排查问题时要能分开指。

## 成对出现的常见形状

多数元素有开始标签与结束标签，内容夹在中间。结束标签带斜线。少数空元素（如图片）形状不同，下一课链接与图片时再遇。

## 用手指指着说

拿一行示例，分别指：哪个是标签名，整块元素到哪里结束，有哪些属性。三者分清，后面读报错信息才听得懂。

## 为何口语会混

大家都说「改一下标签」，其实可能指改属性、改元素内容或改标签名。排错时改用精确说法。

@Callout(title: "标签 ≠ 元素", tone: "information", accent: "mint") {
标签是写法；元素是页面上的那一块；属性是开始标签上的附加说明。
}

@Quiz(id: "web-html-tags-page-three.quiz-1", kind: "singleChoice") {
在一段 `p` 元素里写了 `class="note"`，这段属性属于哪一类？

@Option(id: "web-html-tags-q1-attr", correct: true) {
属性：写在开始标签里的附加说明

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
它修饰这个段落元素，本身不是另一段正文。
}
}

@Option(id: "web-html-tags-q1-el") {
元素：因为它出现在页面里
}

@Option(id: "web-html-tags-q1-only-tag") {
只是结束标签的另一种写法
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
附加在开始标签上的 name="value" 是属性。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
先找尖括号里的额外名值对：那就是属性。
}
}
