前面分别谈了任务链条、表示和二进制。这一课把三个角色放回同一场景：程序、硬件、数据。

计算器里：`26` 与 `12` 是数据，加法步骤是程序，芯片与屏幕是硬件。

## 各管一件事

程序规定「做什么、按什么顺序」。硬件提供运算与存储能力。数据是被读入、被改写、被输出的对象。

```text
程序   规定步骤
  ↓ 指挥
硬件   实际执行
  ↓ 作用于
数据   26、12 → 38
```

## 缺一不可

没有程序，硬件不知下一步。没有硬件，程序只是文本。没有数据，程序空转无对象。

@Callout(title: "三角色", tone: "information", accent: "purple") {
程序指挥，硬件执行，数据被处理。
}

@Quiz(id: "cs-info-together-roles.quiz-1", kind: "singleChoice") {
把加法程序原封不动留下，只把输入从 `26` 改成 `40`。变的是哪一角？

@Option(id: "cs-info-together-roles-q1-data", correct: true) {
数据变了，程序与硬件角色未换

@Feedback(title: "原料变了", tone: "success", accent: "mint") {
同一步骤清单，作用于新的输入数据。
}
}

@Option(id: "cs-info-together-roles-q1-prog") {
程序定义自动变成了乘法
}

@Option(id: "cs-info-together-roles-q1-hw") {
硬件从此只认识数字 40
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先分清：改输入是改数据，不是改步骤定义。
}

@Feedback(when: "incorrect", title: "三角色对照", tone: "warning", accent: "amber") {
问：步骤清单有没有改写？机身有没有换？还是只有数字变了？
}
}
