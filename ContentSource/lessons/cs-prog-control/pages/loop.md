循环让一段语句在条件成立时**反复执行**，对应计算思维里的「重复」。

## 每次都看条件

`当 count <= 3 时：处理；count = count + 1`。每圈开始先看条件，再决定是否继续。

```text
count=1
  ↓
count<=3？──否──→ 结束
  │是
处理并 count+1
  ↓
回到条件
```

## 循环变量要推进

若圈内从不改 `count`，条件可能永远为真，程序停不下来。推进状态是循环的责任。

## 循环也能数次数

有时你事先知道要做 `n` 次，可以用计数器从 `0` 加到 `n-1`。有时你只知道「直到干净」，就用条件循环。

两种都要保证：计数或状态在圈内变化，结束条件最终能成立。

@Callout(title: "循环反复", tone: "information", accent: "mint") {
循环 = 条件控制下的重复；圈内要让状态朝结束推进。
}

@Quiz(id: "cs-prog-control-loop.quiz-1", kind: "singleChoice") {
`count` 从 `1` 起，循环条件 `count <= 3`，每圈 `count = count + 1`。大约处理几圈？

@Option(id: "cs-prog-control-loop-q1-three", correct: true) {
三圈：count 为 1、2、3 时进入

@Feedback(title: "逐步模拟", tone: "success", accent: "mint") {
到 4 时条件失败，循环结束。
}
}

@Option(id: "cs-prog-control-loop-q1-zero") {
零圈，因为条件永远假
}

@Option(id: "cs-prog-control-loop-q1-inf") {
无限圈，即便 count 在增加
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用纸模拟 count 的变化最稳。
}

@Feedback(when: "incorrect", title: "列表模拟", tone: "warning", accent: "amber") {
写出每圈开始时的 count，看是否满足条件。
}
}
