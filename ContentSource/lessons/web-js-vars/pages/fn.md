把「根据文本算字数并更新页面」写成**函数**：起一个名字，把步骤收进去，需要时调用。

```text
函数 calculateCount
├─ 读入文本
├─ 算出长度
└─ 返回或写回页面
```

函数避免同一串步骤复制粘贴多份；改逻辑时只改一处。

## 变量与函数配合

变量保存状态；函数封装动作。输入事件触发函数，函数更新变量，再反映到页面。

## 落到「小记」上

「根据文本算字数并更新提示」会在输入时反复发生。写成函数后，输入事件只需调用一次名字，不必复制整段步骤。

## 变量与函数如何配合

```text
事件到来
  ↓
调用函数
  ↓
函数更新变量并改页面
```

函数打包动作，变量保存状态——两者一起，页面才「记得」又「会做」。

## 函数名也是文档

`calculateCount`、`clearForm` 这种名字，让调用处读起来像在讲故事。避免 `doStuff` 这类空白名。

回到本页的目标：围绕「怎样在网页中使用变量和函数？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "函数打包步骤", tone: "information", accent: "mint") {
函数把可复用的步骤命名收起；需要时调用，而不是到处复制粘贴。
}

@Quiz(id: "web-js-vars-page-fn.quiz-1", kind: "singleChoice") {
三处不同按钮都要执行「清空留言框」。更好的做法是？

@Option(id: "web-js-vars-q2-fn", correct: true) {
写成一个函数，三处调用它

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
一处维护，三处复用。
}
}

@Option(id: "web-js-vars-q2-copy") {
把同样 20 行代码粘贴三次永不改
}

@Option(id: "web-js-vars-q2-html") {
把清空逻辑改成三个 h1
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
重复动作收进函数。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
复制三份后一改就要改三处，最容易漏。
}
}
