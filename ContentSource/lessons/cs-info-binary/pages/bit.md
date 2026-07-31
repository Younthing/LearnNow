信息要表示成机器能存的状态。最常见的底层状态只有两种：开与关，写成 `0` 和 `1`。

一位这样的状态叫**比特**。八个比特常凑成一组便于计数，但这一页先抓住：一切先落成 `0`/`1`。

## 两种状态就够起步

开关多了，就能区分更多组合。两个比特有 `00` `01` `10` `11` 四种组合，足以先映射四个符号。

```text
1 个比特   →  2 种状态
2 个比特   →  4 种组合
3 个比特   →  8 种组合
```

## 比特本身没有媒介属性

一串 `01001100` 不会写着「我是字」或「我是图」。它只是状态序列；解释靠后面的映射表。

@Callout(title: "原料是比特", tone: "information", accent: "purple") {
`0`/`1` 是底层原料；含义仍来自约定。
}

@Quiz(id: "cs-info-binary-bit.quiz-1", kind: "singleChoice") {
只有两个比特可用时，最多能可靠区分多少种不同符号？

@Option(id: "cs-info-binary-bit-q1-four", correct: true) {
四种：`00` `01` `10` `11`

@Feedback(title: "组合数", tone: "success", accent: "mint") {
每个比特两态，两个比特相乘得四种组合。
}
}

@Option(id: "cs-info-binary-bit-q1-two") {
两种，因为比特只有 0 和 1
}

@Option(id: "cs-info-binary-bit-q1-eight") {
八种，因为人们常说八个一组
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
区分能力来自组合，不是单个比特的「名字」。
}

@Feedback(when: "incorrect", title: "列组合", tone: "warning", accent: "amber") {
把两个位置能出现的全部 0/1 搭配写出来，数一数。
}
}
