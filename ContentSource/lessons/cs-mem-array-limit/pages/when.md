数组仍很适合：长度稳定、主要按下标读、很少中间插入。步数按天追加在末尾，往往仍可用数组或动态数组。

## 选型直觉

| 需求 | 更倾向数组？ |
| --- | --- |
| 按下标随机读 | 是 |
| 频繁中间插入 | 否 |
| 长度几乎固定 | 是 |
| 长度狂飙且常改结构 | 考虑链表等 |

```text
主操作 = 下标读
  + 长度稳定
  → 优先数组
主操作 = 中间插入
  → 考虑链表
```

## 下一课预告

下一课看链表怎样用「指向下一格」避免大搬家，以及它在按位访问上付什么代价。

@Callout(title: "擅长随机访问", tone: "warning", accent: "amber") {
数组用连续换取下标速度；灵活插入不是它的强项。
}

@Quiz(id: "cs-mem-array-limit-when.quiz-1", kind: "singleChoice") {
数据长度固定，且几乎只按下标读取。选数组合适吗？

@Option(id: "cs-mem-array-limit-when-q1-yes", correct: true) {
合适：正好发挥连续存放与下标换算

@Feedback(title: "扬长避短", tone: "success", accent: "mint") {
没有频繁中间插入时，数组很稳。
}
}

@Option(id: "cs-mem-array-limit-when-q1-no") {
不合适，因为数组在任何场景都最差
}

@Option(id: "cs-mem-array-limit-when-q1-only-link") {
此时必须改用链表，否则无法读取
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结构选择看操作组合，不看潮流。
}

@Feedback(when: "incorrect", title: "对表需求", tone: "warning", accent: "amber") {
主操作是什么：随机读，还是中间插？
}
}
