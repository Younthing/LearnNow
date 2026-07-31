字符串也常用下标取字符。`"Lin"` 的第 `0` 个字符是 `"L"`（在从 0 编号的约定下）。

## 长度与合法下标

长度为 `3` 时，合法下标 `0..2`。取字符与取数组元素同一心智模型。

```text
 0   1   2
 L   i   n
```

## 注意空串

长度为 `0` 的字符串没有合法下标。对空串取字符是边界错误的常见来源。

## 和数组同一套数法

从 `0` 编号时，字符串与数组共用「长度减一是最后位置」这条规则。空串长度为 `0`，没有任何合法下标。

取字符前先问长度：长度不够就不要硬取，否则边界错误会伪装成「读到了奇怪字符」。

@Callout(title: "下标取字", tone: "information", accent: "mint") {
字符位置用下标表示；空串要单独防越界。
}

@Quiz(id: "cs-data-string-index.quiz-1", kind: "singleChoice") {
`"Lin"` 从 0 编号，下标 `1` 的字符是？

@Option(id: "cs-data-string-index-q1-i", correct: true) {
`i`

@Feedback(title: "数位置", tone: "success", accent: "mint") {
0→L，1→i，2→n。
}
}

@Option(id: "cs-data-string-index-q1-l") {
`L`
}

@Option(id: "cs-data-string-index-q1-n") {
`n`
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
与数组下标同一套数法。
}

@Feedback(when: "incorrect", title: "写编号", tone: "warning", accent: "amber") {
在每个字母上方标 0、1、2。
}
}
