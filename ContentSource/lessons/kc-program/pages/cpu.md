清单已经摊在台面上了。接下来是谁在读它？

机器里干活的那一位叫 CPU。它取出第 1 步，做掉；取出第 2 步，做掉。一次只做一小步，不会把四步一口气想明白。

## 取一条，做一条

```text
取第 1 步（取旧合计） → 执行 → 26
取第 2 步（取新数字） → 执行 → 12
取第 3 步（相加）     → 执行 → 38
```

这个节奏一直重复到清单读完。中间没有哪一步是「同时」发生的，只是每一步都短得你察觉不到。

## 那为什么感觉是瞬间

因为步子小，但数量大：一台今天的手机，CPU 每秒能做的步数在几十亿这个量级。四步这种小事，快到你抬手的工夫就结束了。

你感觉到的快，是很多很小的步骤叠起来的结果，不是某一步特别聪明。这一点很实际：一件事慢，通常是它要做的步数太多，而不是机器某一步偷懒了。

## 顺序不由 CPU 决定

它不会自己跳过第 2 步，也不会改成先做第 3 步。上一课那句「机器不猜」在这里同样成立：清单怎么写，它就怎么走。

一台机器里可以有好几个这样干活的单位，同时各读一份清单。即便如此，每一份清单上的顺序仍然照写下的来。

@Callout(title: "快来自数量", tone: "information", accent: "purple") {
没有哪一步是聪明的。快是因为小步足够小、足够多、足够密。
}

@Quiz(id: "kc-program-cpu.quiz-1", kind: "singleChoice") {
同一个记账 app，在今年的新手机上明显更利索。按这一页的说法，最直接的原因是什么？

@Option(id: "kc-program-cpu-q1-more-steps-per-second", correct: true) {
新手机每秒能做的步数更多，同样的一串步骤走得更快
}

@Option(id: "kc-program-cpu-q1-merge-steps") {
新手机会把那四步合成一步一次算完
}

@Option(id: "kc-program-cpu-q1-skip-steps") {
新手机会跳过其中不必要的步骤
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
换机器不会改写清单。要做的步数没变，变的是每一步花的时间。
}

@Feedback(when: "incorrect", title: "回到那四步", tone: "warning", accent: "amber") {
你可能以为更快意味着做得更少。自检办法：把那四步念一遍，指出哪一步是可以不做的——找不到，就说明快只能来自每一步更短。
}
}

@Quiz(id: "kc-program-cpu.quiz-2", kind: "singleChoice") {
CPU 每秒能做几十亿步，可你打开一个大 app 还是要等两三秒。这两件事怎么同时成立？

@Option(id: "kc-program-cpu-q2-many-steps", correct: true) {
大 app 要做的步数本来就非常多，而且开头还得先把清单和数据搬上台面
}

@Option(id: "kc-program-cpu-q2-fake-number") {
说明几十亿这个数字是夸张的，实际做不到那么多
}

@Option(id: "kc-program-cpu-q2-animation") {
那两三秒和步数无关，是 app 特意留出来播动画的时间
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
每步很快，不等于总时间很短：总时间＝步数 × 每步的时间，再加上搬运的工夫。
}

@Feedback(when: "incorrect", title: "把两个量分开看", tone: "warning", accent: "amber") {
你可能把「每步多快」直接当成了「一共多久」。自检办法：先问这次要做的步数是四步还是几亿步，再决定要不要惊讶。
}
}
