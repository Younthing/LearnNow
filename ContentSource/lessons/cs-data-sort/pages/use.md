排序换来什么？常见三类收益：更好找、更好看、更好比。

## 三类用途

| 用途 | 例子 |
| --- | --- |
| 查找加速准备 | 有序后可用更聪明的查找 |
| 展示 | 通讯录按字母排 |
| 比较 | 一眼看最高分 |

## 与线性查找的关系

无序时线性查找仍可用。有序时，还可以利用「左边都更小」等性质跳着查——细节留在效率课。

```text
有序名单
  ↓
展示更清晰
  ↓
也为更快查找提供前提
```

## 查找为何受益

有序之后，你可以利用「左边都更小、右边都更大」跳过一些比较。即便仍用线性扫描，提前遇到更大的键也可以早停。

展示场景更直接：通讯录按字母排，人眼也能更快定位。

@Callout(title: "为后续铺路", tone: "information", accent: "mint") {
排序常是查找、展示、统计前的准备步骤。
}

@Quiz(id: "cs-data-sort-use.quiz-1", kind: "singleChoice") {
老师想在名单上快速看出最高分。排序的直接帮助是？

@Option(id: "cs-data-sort-use-q1-end", correct: true) {
排好后极值出现在端点，便于一眼看到

@Feedback(title: "展示与比较", tone: "success", accent: "mint") {
不必再扫完全表找最大——端点已是答案。
}
}

@Option(id: "cs-data-sort-use-q1-delete") {
排序会偷偷删掉最高分
}

@Option(id: "cs-data-sort-use-q1-none") {
排序对找最高分毫无关系
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
位置关系服务比较与展示。
}

@Feedback(when: "incorrect", title: "想端点", tone: "warning", accent: "amber") {
递增序列的最右是什么？
}
}
