需要并排时，常见工具是弹性布局（flex）或网格（grid）。入门不必背完所有属性，先立用途：

```text
竖排为主   → 文档流
一行并排   → flex 常够用
二维对齐   → grid 更合适
```

## 「小记」侧栏例子

主栏放留言，侧栏放「热门标签」。可以用 flex 把两栏放进同一行，再规定主栏更宽。

| 需求 | 更常想到 |
| --- | --- |
| 两栏并排 | flex / grid |
| 仍是一条留言流 | 文档流 |
| 微调某盒子内外空白 | 盒模型 |

## 需求先于工具

先用一句话说清：「主栏与侧栏左右并排，主栏更宽」。这句话会自然指向 flex 或 grid，而不是先背属性表。

## 对照三种选择

```text
只要竖排        → 文档流
一行两栏        → flex 常够用
行列二维对齐    → grid 更合适
```

## 落到「小记」上

宽屏加「热门标签」侧栏时，用并排工具；窄屏时再拆回单栏——那是下一课响应式的事。

没有并排需求时，硬上 flex/grid 只会增加概念负担。文档流能说清的顺序，就让它继续说清。

回到本页的目标：围绕「怎样控制元素的位置和布局？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "工具跟需求走", tone: "information", accent: "mint") {
先描述排布需求，再选文档流、flex 或 grid；不要为用工具而用工具。
}

@Quiz(id: "web-css-layout-page-tools.quiz-1", kind: "singleChoice") {
要把「留言列表」和「热门标签」左右并排。更合理的第一步是？

@Option(id: "web-css-layout-q2-flex", correct: true) {
用并排布局工具（如 flex）安排两栏

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
左右并排超出单纯竖排默认。
}
}

@Option(id: "web-css-layout-q2-pad") {
只加大标题的 padding
}

@Option(id: "web-css-layout-q2-alt") {
给列表写 alt
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
并排是布局问题，不是单靠内边距能解决的。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
padding 改变盒内空白，不会 magically 变成两栏。
}
}
