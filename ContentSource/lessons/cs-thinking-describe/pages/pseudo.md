伪代码用接近自然语言的语句写步骤，强调**顺序与结构词**，但不绑死某门编程语言。

## 结构词要齐

用「若 / 否则 / 当…时重复」写出选择与重复。泡茶的伪代码可以是：

```text
烧水
当 水未开 时
  继续加热
放入茶叶
冲泡
端出
```

## 图与伪代码互补

| 形式 | 更擅长 | 更弱于 |
| --- | --- | --- |
| 流程图 | 看见路径 | 细语句 |
| 伪代码 | 写清步骤 | 一眼看环 |

两者描述同一算法；下一课用它们来检查「是否正确」。

@Callout(title: "文看语句", tone: "warning", accent: "amber") {
伪代码用结构词把顺序、选择、重复写清楚。
}

@Quiz(id: "cs-thinking-describe-pseudo.quiz-1", kind: "singleChoice") {
要把「杯子不干净就继续洗」写成伪代码，哪句更合适？

@Option(id: "cs-thinking-describe-pseudo-q1-while", correct: true) {
当杯子不干净时：清洗一次

@Feedback(title: "重复结构词", tone: "success", accent: "mint") {
「当…时」表达了重复与条件。
}
}

@Option(id: "cs-thinking-describe-pseudo-q1-poem") {
杯子啊，愿你洁净
}

@Option(id: "cs-thinking-describe-pseudo-q1-hide") {
处理杯子（细节以后再说，永不写清）
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
伪代码要保留可执行的结构，而不是省略关键条件。
}

@Feedback(when: "incorrect", title: "保留结构词", tone: "warning", accent: "amber") {
看句子里有没有表达重复或选择的词。
}
}
