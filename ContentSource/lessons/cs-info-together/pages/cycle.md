硬件怎么「听从」程序？简化模型：反复**取出下一条步骤并执行**。

## 一小步循环

从程序里取下一条指令，硬件执行它对数据的操作，再取下一条。计算器加法就是若干条这样的小步串起来。

```text
取下一条指令
  ↓
执行（可能读写数据）
  ↓
再取下一条
  ↓
…
```

## 程序是待执行的数据

存在存储器里的程序，对硬件来说也是可读的比特。关键在于硬件把其中一部分解释为「指令」而不是普通数字——这又是约定与电路设计共同保证的。

@Callout(title: "取指—执行", tone: "information", accent: "mint") {
运行中的机器在循环：取下一条，做一次，再取下一条。
}

@Quiz(id: "cs-info-together-cycle.quiz-1", kind: "singleChoice") {
程序中途少写了「显示结果」这一步。按循环模型，会发生什么？

@Option(id: "cs-info-together-cycle-q1-skip", correct: true) {
硬件不会自动补上；没有取到的步骤就不会执行

@Feedback(title: "没有指令就没有动作", tone: "success", accent: "mint") {
循环只执行取到的指令，不会臆造你的意图。
}
}

@Option(id: "cs-info-together-cycle-q1-guess") {
硬件会猜测你想看结果并自行显示
}

@Option(id: "cs-info-together-cycle-q1-stopchip") {
芯片会永久停止一切运算能力
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺步骤就缺动作；要补的是程序，不是祈盼硬件领悟。
}

@Feedback(when: "incorrect", title: "跟一次循环", tone: "warning", accent: "amber") {
问：显示结果对应的那条指令是否曾被取到？
}
}
