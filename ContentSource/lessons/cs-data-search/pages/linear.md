最直接的方法：**线性查找**——从左到右逐个比较，相等就返回下标。

## 逐步扫

名单 `["Ann","Lin","Mo"]`，目标 `"Lin"`：先比 Ann（否），再比 Lin（是）→ 下标 `1`。

```text
Ann ≠ Lin
  ↓
Lin = Lin → 返回 1
```

## 最坏要看完全部

目标在末尾或不存在时，比较次数接近列表长度。它简单、不要求事先排序。

## 何时够用

列表短、或不保证有序、或只查一次时，线性查找往往是最省事的正确选择。

它不要求预处理。代价是最坏情况下几乎每个元素都要比一次——规模变大后再考虑别的策略。

@Callout(title: "逐个比", tone: "information", accent: "mint") {
线性查找：按顺序比较，命中即停。
}

@Quiz(id: "cs-data-search-linear.quiz-1", kind: "singleChoice") {
列表 `["Ann","Lin","Mo"]`，线性查找 `"Mo"`。第一次比较的是谁？

@Option(id: "cs-data-search-linear-q1-ann", correct: true) {
`Ann`：从左端开始

@Feedback(title: "从头扫", tone: "success", accent: "mint") {
线性查找不跳着从中间开始（那是另一类算法的思路）。
}
}

@Option(id: "cs-data-search-linear-q1-mo") {
直接先比 `Mo`，因为名字像答案
}

@Option(id: "cs-data-search-linear-q1-lin") {
必须先比 `Lin`
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
顺序扫描从下标 0 起步。
}

@Feedback(when: "incorrect", title: "想扫描起点", tone: "warning", accent: "amber") {
「逐个」通常意味着从哪一端按序前进？
}
}
