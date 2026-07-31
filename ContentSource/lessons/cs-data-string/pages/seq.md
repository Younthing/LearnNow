屏幕上的词，在程序里常是**字符串**：一串排好序的字符。

`"Lin"` 可以看成三个字符的序列。它与数组同源：都是有序集合，只是元素是字符。

## 字符来自编码约定

每个字符对应编码表中的编号，最终仍是比特。这一课站在程序视角：把它当字符序列用。

```text
"L" "i" "n"
  ↓ 组成
字符串 "Lin"
```

## 为何单独讲

文字处理极常见：名字、地址、消息。专用字符串类型提供更贴切的操作与可读写法。

@Callout(title: "字符序列", tone: "information", accent: "purple") {
字符串把文字存成有序字符，便于程序处理。
}

@Quiz(id: "cs-data-string-seq.quiz-1", kind: "singleChoice") {
按这一页，字符串最接近哪种结构直觉？

@Option(id: "cs-data-string-seq-q1-arr", correct: true) {
有序的字符序列，类似数组

@Feedback(title: "同源直觉", tone: "success", accent: "mint") {
位置、长度、遍历这些想法都适用。
}
}

@Option(id: "cs-data-string-seq-q1-onebit") {
永远只占一个比特
}

@Option(id: "cs-data-string-seq-q1-nolength") {
没有长度概念的一团混沌
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先建立「序列」模型，再学具体库函数。
}

@Feedback(when: "incorrect", title: "看组成", tone: "warning", accent: "amber") {
`"Lin"` 能否拆成逐个字符？能，就是序列。
}
}
