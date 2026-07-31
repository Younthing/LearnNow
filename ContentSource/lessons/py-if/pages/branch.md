今日学习目标是 30 分钟。有人学了 40，有人只学了 15——程序怎样说不同的话？

用 **条件语句**：先算出一个是或否，再决定走哪一段代码。

## 最小的分叉

```python
if minutes >= 30:
    print("今日达标")
else:
    print("再学一会儿")
```

`minutes >= 30` 先得到 `True` 或 `False`。为真走上面，为假走下面。

```text
分钟数
  ↓ 比较 ≥ 30
是？ → 打印达标
否？ → 打印再学一会儿
```

## 条件是闸门

闸门问的是「现在是否满足」。比较、布尔变量，都可以当闸门。闸门本身不打印；它只决定后面哪一段会执行。

## 先有问题，再写分支

先问清「根据什么不同而不同」，再写 `if`。否则容易写成永远只走一条的假分支。

@Callout(title: "判断在前，行动在后", tone: "information", accent: "mint") {
条件先给出是/否，**再**决定执行哪一段话。
}

@Quiz(id: "py-if-branch.quiz-1", kind: "singleChoice") {
`minutes` 为 40，执行上面的 if/else 后，屏幕更可能出现？

@Option(id: "py-if-branch-q1-ok", correct: true) {
「今日达标」，因为条件为真，走了 if 那一段
}

@Option(id: "py-if-branch-q1-both") {
两句都会打印，因为写了两段 print
}

@Option(id: "py-if-branch-q1-else") {
「再学一会儿」，因为 else 总是更保险
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
40 ≥ 30 为真，只走 if 分支。
}

@Feedback(when: "incorrect", title: "先算条件再看分支", tone: "warning", accent: "amber") {
自检：把 40 和 30 比一下，条件是 True 还是 False？真走 if，假走 else。
}
}

@Quiz(id: "py-if-branch.quiz-2", kind: "singleChoice") {
没有 if，只写两行 print「达标」和「未达标」。和用条件相比，缺了什么？

@Option(id: "py-if-branch-q2-choice", correct: true) {
缺了根据情况选择只说其中一句的能力
}

@Option(id: "py-if-branch-q2-speed") {
缺了让程序跑得更快的能力
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
条件的价值是选择，不是把两句话都喊出来。
}

@Feedback(when: "incorrect", title: "回到要解决的问题", tone: "warning", accent: "amber") {
我们要的是「有时这句、有时那句」，不是两句总是一起出现。
}
}
