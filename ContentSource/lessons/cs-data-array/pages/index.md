访问数组某一格，用**下标**（位置编号）。许多语言从 `0` 开始：第一格是 `0`，第二格是 `1`。

## 从 0 数起

`steps[0]` 是 `6000`，`steps[2]` 是 `5000`。长度是 `3` 时，合法下标是 `0..2`。

```text
下标   0      1      2
值    6000   7500   5000
```

## 越界是常见错

访问 `steps[3]` 在长度为 3 时通常非法。下标最大是长度减一。

| 长度 | 合法下标 | 非法例 |
| --- | --- | --- |
| 3 | 0,1,2 | 3 |
| 1 | 0 | 1 |
| 0 | 无 | 0 |

## 下标是位置，不是值

`steps[1]` 里的 `1` 只表示「第二格」，不等于步数本身。步数是格子里的内容，下标是门牌号。

改内容时下标不变；换位置读另一天时，变的是下标。把两者分开，越界错误会少很多。

@Callout(title: "下标定位", tone: "information", accent: "mint") {
用下标读写某一格；从 0 起时，最后一格是长度减一。
}

@Quiz(id: "cs-data-array-index.quiz-1", kind: "singleChoice") {
数组长度为 `3`，从 0 编号。最后一个元素的下标是？

@Option(id: "cs-data-array-index-q1-two", correct: true) {
`2`

@Feedback(title: "长度减一", tone: "success", accent: "mint") {
三格的编号是 0、1、2。
}
}

@Option(id: "cs-data-array-index-q1-three") {
`3`
}

@Option(id: "cs-data-array-index-q1-one") {
`1`，因为最后总是 1
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
记住：从 0 起，最大下标 = 长度 - 1。
}

@Feedback(when: "incorrect", title: "列出编号", tone: "warning", accent: "amber") {
写出三格的下标：第一格是几？
}
}
