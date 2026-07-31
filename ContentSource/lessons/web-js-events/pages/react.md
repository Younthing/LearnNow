用户一点「发布」、一敲键盘，浏览器会产生**事件**：在某个时刻发生了某类事情。JS 可以监听事件并运行函数。

```text
用户点击按钮
  ↓
产生 click 事件
  ↓
你绑定的函数运行
```

没有事件，脚本不知道「何时」该动。

## 常见事件族

点击、输入、提交、键盘——入门先掌握点击与输入。对「小记」字数统计，监听输入事件最贴切。

## 落到「小记」上

敲字时要更新字数，就应监听输入变化；点击发布才应走提交相关逻辑。事件类型选错，函数会在错误的时机跑，或根本不跑。

## 事件是信号不是魔法

```text
用户做了某事
  ↓
浏览器发出事件信号
  ↓
你监听了，才会跑函数
```

没有监听，事件发生了你也毫无反应。

## 一种操作一类事件

点击、输入、提交各有适用场景。不要用「随便绑一个点击」去覆盖所有时机，信号会对不准。

回到本页的目标：围绕「事件怎样响应用户操作？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "事件标记何时发生", tone: "information", accent: "mint") {
事件把用户操作变成可监听的信号；你的函数在信号出现时运行。
}

@Quiz(id: "web-js-events-page-react.quiz-1", kind: "singleChoice") {
希望每敲一个字就更新字数。应优先监听哪类时机？

@Option(id: "web-js-events-q1-input", correct: true) {
输入变化相关的事件

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
敲字属于输入过程。
}
}

@Option(id: "web-js-events-q1-only-load") {
只在整页第一次打开时算一次
}

@Option(id: "web-js-events-q1-dns") {
域名解析成功事件
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
跟敲字同步，就要听输入类事件。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
只在加载时算一次，无法跟上后续敲字。
}
}
