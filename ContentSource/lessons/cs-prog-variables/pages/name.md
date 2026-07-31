程序要反复提到同一个数据，就给它一个名字。这个命名的可变存放处叫**变量**。

记账时，`amount` 保存当前金额；数字可变，名字稳定，方便步骤引用。

## 名字指向格子

变量不是「永远不变」——变的是格子里的值。名字让算法说「把 amount 加 10」，而不是每次重抄具体数字。

```text
名字 amount
  ↓ 指向
格子  [ 26 ]
```

## 为什么需要

没有变量，每一步都得盯着具体比特位置，程序又臭又长。名字是给人看的把手，背后仍是存储中的数据。

@Callout(title: "命名的格子", tone: "information", accent: "purple") {
变量 = 名字 + 可更新的当前值。
}

@Quiz(id: "cs-prog-variables-name.quiz-1", kind: "singleChoice") {
步骤要多次使用「当前金额」。用变量的主要好处是？

@Option(id: "cs-prog-variables-name-q1-ref", correct: true) {
用稳定名字引用可变的当前值

@Feedback(title: "名稳值可变", tone: "success", accent: "mint") {
算法写 amount，运行时读到的是格子里最新的数。
}
}

@Option(id: "cs-prog-variables-name-q1-freeze") {
变量会让数值永远不能再改
}

@Option(id: "cs-prog-variables-name-q1-hw") {
变量能替代所有硬件
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
名字服务引用；值服务状态。
}

@Feedback(when: "incorrect", title: "看定义", tone: "warning", accent: "amber") {
变量强调的是可更新的命名存放，不是永久冰封。
}
}
