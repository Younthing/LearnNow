容易混的一点：看见页面好看，就以为全是 HTML 干的。其实 HTML 把骨架立好，外观大多另说。

## 分工预习

| 技术 | 主要回答 |
| --- | --- |
| HTML | 页面上有什么 |
| CSS（后一单元） | 长什么样 |
| JavaScript（再后） | 怎样变化与响应 |

本单元只把「有什么」讲清楚：标签、结构、链接、表单。

```text
小记页面
├─ HTML：标题、列表、输入框
├─ CSS：间距、颜色、字体
└─ JS：点击后立刻检查字数
```

## 为什么从内容开始

没有结构，样式和脚本不知道作用在哪一段上。先学会用 HTML 把「小记」的标题、段落、列表、链接和表单说清楚，后面两单元才有附着点。

## 预习后面两单元

CSS 课会专门讲长相；JS 课会讲变化。本单元五课只把骨架立稳：标签、结构、链接、表单。

## 顺序不能反的原因

没有「这是按钮」的标记，样式不知道涂谁，脚本不知道绑谁。先内容，后外观与行为。

回到本页的目标：围绕「HTML 怎样描述网页内容？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "先骨架后皮肤", tone: "information", accent: "mint") {
先用 HTML 标出内容块，再谈外观和交互；顺序反了会失去挂载点。
}

@Quiz(id: "web-html-content-page-not-style.quiz-1", kind: "singleChoice") {
有人说「我只用 HTML 就把按钮做成渐变发光动画了」。按本课分工，这句话哪里可疑？

@Option(id: "web-html-content-q2-mix", correct: true) {
渐变发光更像外观与动效，不该全算成 HTML 的本职

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
HTML 标出「这是按钮」；发光渐变通常靠 CSS/JS。
}
}

@Option(id: "web-html-content-q2-ok") {
完全正确，HTML 本来就专管动画
}

@Option(id: "web-html-content-q2-dns") {
其实那是域名解析做的动画
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
把外观全塞给 HTML，会模糊三层分工。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
回到表：动画和渐变落在「长什么样 / 怎样变化」，不是「是什么」。
}
}
