要在「小记」里记住当前字数，脚本需要**变量**：一个有名字的盒子，里面装着当前值，值可以更新。

```text
let count = 0
输入一个字
count 变成 1
```

变量让程序能把「此刻的状态」留下来，下一步继续用。

## 名字要达意

`count` 比 `x` 更好。写给几周后的自己看：这个名字是不是一看就知道装着什么。

## 赋值就是放进盒子

把新值放进变量，旧值被替换（入门模型）。之后读这个名字，拿到的是新值。

## 落到「小记」上

字数统计要记住「现在是几个字」。每输入一次，就更新这个值，再反映到页面上。没有变量，程序就像金鱼，记不住上一秒。

## 赋值与读取

```text
写入：把新值放进名字
读取：用这个名字取当前值
```

名字要达意：`count` 比 `x` 更容易在三天后读懂。

变量的价值是：同一步骤在不同时刻读到不同值。字数从 0 到 12，靠的就是可更新的存放处。

回到本页的目标：围绕「怎样在网页中使用变量和函数？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "变量保存此刻的值", tone: "information", accent: "mint") {
变量用名字保存可更新的值，供后面的步骤读取和修改。
}

@Quiz(id: "web-js-vars-page-var.quiz-1", kind: "singleChoice") {
字数统计要从 0 加到 1 再加到 2。没有变量会怎样？

@Option(id: "web-js-vars-q1-need", correct: true) {
缺少可更新的存放处，很难记住当前数到几

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
状态需要地方放。
}
}

@Option(id: "web-js-vars-q1-css") {
只用 CSS 边距也能记住数字
}

@Option(id: "web-js-vars-q1-ok") {
完全不需要记住，每次都从月亮上读
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
累计状态依赖可更新的变量。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
CSS 不管程序状态累计。
}
}
