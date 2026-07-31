上一页把这次记账拆成了三段，其中最不透明的是中间那一段：26 加 12 得到 38，这个「加」是谁决定的？

不是机器自己想到要相加。有人事先把步骤一条条写下来了，机器只是照着做。写下来的那几步之外，它什么都不做。

## 把那几步写出来看看

那份步骤大致长这样。

```text
第 1 步   取出旧合计            26
第 2 步   取出你刚输入的数字      12
第 3 步   两个数相加            38
第 4 步   把 38 交给屏幕
```

这四步里没有一处提到「记账」这两个字。机器执行它们的时候，也不需要知道 26 和 12 是钱。

## 它不会替你怀疑

你手一抖输成 1200，机器照样把 1200 加进去，合计变成 1226。它不会停下来问「这笔是不是多打了个零」——第 3 步只写了相加。

想让它提醒你，得有人事先补一步：如果新数字大于 1000，先弹一句确认。app 里所有看起来贴心的地方，背后都是有人事先写下的一步。

## 所以，计算机是什么

到这里可以给它一句定义：计算机是一台接收输入、按事先写好的步骤处理、再给出输出的机器。

它的强项是把很小的步骤重复很多次而几乎不出错。它不擅长的是猜你想干什么：步骤里没写的情况，通常就是不会发生的情况。

@Callout(title: "聪明和笨是同一件事", tone: "information", accent: "purple") {
机器严格照步骤做，不多做也不少做。它的可靠和它的死板，来自同一个原因。
}

@Quiz(id: "kc-machine-steps.quiz-1", kind: "singleChoice") {
你和朋友用同款手机，各装了一个记账 app。你输入大额时你的会先问一句「确认吗」，他的从来不问。最合理的解释是什么？

@Option(id: "kc-machine-steps-q1-new-step", correct: true) {
两份清单不一样，你这份里写了检查金额这一步
}

@Option(id: "kc-machine-steps-q1-machine-doubts") {
你手机用得久，摸清了你的消费习惯，所以主动提醒你
}

@Option(id: "kc-machine-steps-q1-builtin") {
提醒是手机本来就有的能力，你朋友大概是把它关掉了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
同款手机、不同表现，差别只可能在清单上。行为的来源是步骤，不是机器的脾气。
}

@Feedback(when: "incorrect", title: "先找不同的那一样", tone: "warning", accent: "amber") {
你可能把这个行为当成了机器自己的判断。自检办法：两台机器一模一样，两个 app 表现不同，那不一样的只能是它们各自照着的那份步骤。
}
}

@Quiz(id: "kc-machine-steps.quiz-2", kind: "singleChoice") {
把上面那四步原样搬到仓库的机器上，只把「旧合计」换成「货架上的旧数量」，其他一个字不改。机器会算出什么？

@Option(id: "kc-machine-steps-q2-stock", correct: true) {
新的库存数量，因为这几步只管取两个数、相加、交出去
}

@Option(id: "kc-machine-steps-q2-still-money") {
还是本月合计，因为这几步本来是给记账写的
}

@Option(id: "kc-machine-steps-q2-fails") {
什么都算不出来，步骤里从来没提过仓库
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
步骤不知道那两个数叫什么名字。数的含义在你这边，不在机器那边。
}

@Feedback(when: "incorrect", title: "逐步读一遍", tone: "warning", accent: "amber") {
把四步再读一次，找出哪一步写了「钱」或「仓库」。一处都找不到，说明含义不是机器带来的。
}
}
