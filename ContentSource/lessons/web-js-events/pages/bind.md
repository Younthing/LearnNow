**绑定**就是：指定「哪个元素上的哪类事件，调用哪个函数」。

```text
留言框 + 输入事件 → calculateCount
发布按钮 + 点击事件 → handleSubmit
```

绑错元素或绑错事件类型，函数不会在你期望的时刻运行。

## 提交事件

表单提交也是事件。可在提交时先跑检查，再决定是否真正送出——下一课展开。

## 绑定三件套

```text
哪个元素
+ 哪类事件
+ 哪个函数
```

三件缺一，导线就没搭上。「小记」里应把字数函数绑到留言框的输入事件，而不是绑到导航点击。

## 提交事件预告

表单提交也是事件。下一课会在提交时先检查，再决定是否真的送出。

## 排错口诀

函数从不运行时，先看绑定的元素和事件类型是否匹配真实操作，再打开函数内部逐行看。

回到本页的目标：围绕「事件怎样响应用户操作？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "绑定＝搭导线", tone: "information", accent: "mint") {
把元素、事件类型与处理函数接在一起，操作发生时逻辑才会跑。
}

@Quiz(id: "web-js-events-page-bind.quiz-1", kind: "singleChoice") {
你把 calculateCount 绑到了导航链接的点击上，结果敲留言时字数不更新。问题更可能是？

@Option(id: "web-js-events-q2-bind", correct: true) {
绑错了元素或事件，函数没在输入时触发

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
导线接错，信号到不了。
}
}

@Option(id: "web-js-events-q2-html") {
HTML 无法与 JS 共存
}

@Option(id: "web-js-events-q2-ok") {
这是正常的，字数本就不该更新
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
绑定目标必须匹配真实操作发生的位置。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问：敲字发生在留言框，还是发生在导航链接？
}
}
