字符串常见操作：**拼接**与**截取**。拼接把两段接成更长；截取取出片段。

## 拼接

`"Lin"` 与 `" Wei"` 拼成 `"Lin Wei"`。顺序有意义：谁在前谁在后。

```text
"Lin" + " Wei"
  ↓
"Lin Wei"
```

## 截取

取前两个字符得 `"Li"`。截取仍受长度与下标约束。

| 操作 | 作用 | 注意 |
| --- | --- | --- |
| 拼接 | 接成更长 | 顺序 |
| 截取 | 取片段 | 边界 |
| 比长度 | 量字符数 | 空串为 0 |

## 拼接不是数值加法

`"12" + "3"` 若按字符串拼接，得到的是 `"123"`，不是数字 `15`。类型决定 `+` 的含义。

做文字拼接前确认两边都是字符串意图；若要算数值，先转成数字类型再运算。

@Callout(title: "拼与切", tone: "warning", accent: "amber") {
字符串运算多是在序列上接段或取段。
}

@Quiz(id: "cs-data-string-ops.quiz-1", kind: "singleChoice") {
希望显示全名「Lin Wei」，已有 `"Lin"` 与 `" Wei"`。该用？

@Option(id: "cs-data-string-ops-q1-concat", correct: true) {
按顺序拼接两段

@Feedback(title: "拼接成新串", tone: "success", accent: "mint") {
顺序决定最终文字。
}
}

@Option(id: "cs-data-string-ops-q1-sub") {
只截取 `"Lin"` 的第一个字符就结束
}

@Option(id: "cs-data-string-ops-q1-num") {
把两段当整数相加
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
多段文字合成一段，本质是拼接。
}

@Feedback(when: "incorrect", title: "看目标串", tone: "warning", accent: "amber") {
目标是否等于两段首尾相接？
}
}
