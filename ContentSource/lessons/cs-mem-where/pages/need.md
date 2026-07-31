程序运行时，变量、数组、中间结果必须待在硬件能快速读写的地方。否则取指—执行循环无法及时拿到数据。

## 工作区需求

计算器要记住 `26` 与 `12`，累加器要放下一步结果。这些都是**此刻正在用的状态**。

```text
程序指令
  ↓ 读写
正在用的数据
  ↓ 需要
可快速访问的存放处
```

## 不是抽象概念而已

「放在哪里」决定快慢与是否还在。下一页给这个存放处命名。

## 与表示课的衔接

上一单元说信息要落成可处理形式。运行时还要把这些形式放进**正在被执行的工作区**，指令才能读写。

没有工作区，表示只是停在长期柜子里的静态比特，进不了取指—执行循环。

@Callout(title: "要有工作区", tone: "information", accent: "purple") {
运行中的状态必须放在可快速读写的地方。
}

@Quiz(id: "cs-mem-where-need.quiz-1", kind: "singleChoice") {
程序正在累加步数，为什么不能「只存在心里、不占任何硬件」？

@Option(id: "cs-mem-where-need-q1-hw", correct: true) {
硬件执行需要可读写的实际存放处

@Feedback(title: "状态要落地", tone: "success", accent: "mint") {
没有存放处，就没有可被指令操作的对象。
}
}

@Option(id: "cs-mem-where-need-q1-ok") {
完全不需要存放，指令会凭空变出数字
}

@Option(id: "cs-mem-where-need-q1-future") {
只把数据留给未来的课，当前禁止存放
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
执行链要求数据在场。
}

@Feedback(when: "incorrect", title: "回到执行", tone: "warning", accent: "amber") {
取指执行时，操作数从哪读？
}
}
