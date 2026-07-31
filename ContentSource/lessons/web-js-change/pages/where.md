JS 可以写在页面里，或放在独立文件由页面引入。对「小记」来说，更常见的是独立文件：结构、外观、行为三者分开维护。

## 三层再对齐

| 层 | 问题 |
| --- | --- |
| HTML | 有什么 |
| CSS | 长什么样 |
| JS | 怎样变化与响应 |

## 本单元路线

变量与函数 → 读写页面元素 → 事件 → 提交前检查。先记住：JS 是让已有页面「动起来」的那一层。

## 分层对照再钉一次

```text
HTML  页面上有什么
CSS   长什么样
JS    怎样变化与响应
```

把点击逻辑塞进一长串标签属性里，改起来会痛：行为、结构、外观缠在一起。

## 文件怎么放（入门）

独立 `.js` 文件由页面引入，是常见做法。本课不绑某一家打包工具；先立「行为单独成层」即可。

行为单独成层后，改交互不必重写 HTML 骨架，改文案也不必翻开脚本。三层边界越清，协作成本越低。

回到本页的目标：围绕「JavaScript 为什么能让网页发生变化？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "行为也是一层", tone: "information", accent: "mint") {
把「怎样反应」从内容和外观中分开，页面才好维护。
}

@Quiz(id: "web-js-change-page-where.quiz-1", kind: "singleChoice") {
有人把所有点击逻辑都写成很长的 HTML 属性字符串，改起来极痛苦。按分层思路，更好的方向是？

@Option(id: "web-js-change-q2-sep", correct: true) {
把行为收到 JS 中，与结构外观分离

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
行为独立后更好改、更好测。
}
}

@Option(id: "web-js-change-q2-more-html") {
继续把逻辑塞进更多标签名里
}

@Option(id: "web-js-change-q2-delete") {
删除所有按钮，就没有逻辑问题了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
行为单独一层，是可维护性的关键一步。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
标签名表达「是什么」，不适合塞完整程序逻辑。
}
}
