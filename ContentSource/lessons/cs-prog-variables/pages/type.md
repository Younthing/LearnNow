格子里放的是整数、文字还是真假值，决定了**能做哪些运算**。这就是数据类型的作用。

## 类型约束操作

两个整数可以相加；把一段文字和苹果的重量直接「相加」通常无意义，语言会阻止或要求你先转换。

```text
amount : 整数
count  : 整数
label  : 文字
```

## 类型也是约定

类型告诉解释规则：同一串比特，按整数读还是按文字读，结果不同。这与「表示需要约定」一脉相承。

| 类型 | 典型运算 | 不宜直接做 |
| --- | --- | --- |
| 整数 | 加减比较 | 当句子朗读 |
| 文字 | 拼接、截取 | 直接数值加减 |
| 真假 | 条件判断 | 当金额累加 |

@Callout(title: "类型管运算", tone: "information", accent: "mint") {
类型声明「这个值按什么规则解释、允许什么操作」。
}

@Quiz(id: "cs-prog-variables-type.quiz-1", kind: "singleChoice") {
变量 `label` 保存文字「茶叶」。直接做 `label + 3` 在多数语言里会出问题。原因是？

@Option(id: "cs-prog-variables-type-q1-mismatch", correct: true) {
类型不同，文字与整数的加法规则通常未直接定义

@Feedback(title: "运算要匹配类型", tone: "success", accent: "mint") {
先确认操作是否对该类型有意义。
}
}

@Option(id: "cs-prog-variables-type-q1-always") {
任何两个值在任何语言里都可以无条件相加
}

@Option(id: "cs-prog-variables-type-q1-name") {
只因为变量名太短
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
类型保护你免于无意义运算。
}

@Feedback(when: "incorrect", title: "问运算是否有定义", tone: "warning", accent: "amber") {
文字与整数的「+」指拼接还是数值加？多数情况需明确。
}
}
