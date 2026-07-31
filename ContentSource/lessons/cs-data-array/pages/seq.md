单个变量装一个值。一组相关值——三天步数——更适合放进**数组**：按顺序排好的一串格子。

## 一组，而不是一堆散名

`steps[0]`、`steps[1]`、`steps[2]` 共享一个名字，用位置区分。比 `stepsMon`、`stepsTue` 更易批量处理。

```text
steps
├─ [0] 6000
├─ [1] 7500
└─ [2] 5000
```

## 同型更易统一处理

数组里通常放同一类型的值，这样遍历时运算规则一致。

## 为什么不用一堆散变量

三天步数若写成 `stepsMon`、`stepsTue`、`stepsWed`，求和时要写三行几乎一样的加法。
数组把它们收成一个名字，循环一次就能处理完全部格子。

批量数据一出现，就优先问：它们是否同型、是否值得排成序列？

@Callout(title: "有序一组", tone: "information", accent: "purple") {
数组把多个同型值排成可统一处理的序列。
}

@Quiz(id: "cs-data-array-seq.quiz-1", kind: "singleChoice") {
要保存一周每天的步数并求总和，更合适的是？

@Option(id: "cs-data-array-seq-q1-arr", correct: true) {
用数组按天存放，再循环累加

@Feedback(title: "批量数据", tone: "success", accent: "mint") {
一组同型值正是数组的用武之地。
}
}

@Option(id: "cs-data-array-seq-q1-one") {
只用一个变量反复覆盖，不保留每天
}

@Option(id: "cs-data-array-seq-q1-no") {
禁止保存多个数字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
要保留并批量处理，就用序列结构。
}

@Feedback(when: "incorrect", title: "问是否多值", tone: "warning", accent: "amber") {
需要同时保留多个值时，单个变量不够。
}
}
