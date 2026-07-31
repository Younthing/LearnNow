汇总之外，常见还有两类处理：**过滤**（留下符合条件的）和 **转换**（每个变成另一种值）。

## 过滤：只收达标天

```python
good_days = []
for m in minutes_list:
    if m >= 30:
        good_days.append(m)
```

每一轮先判断，再决定是否装进新列表。

## 转换：分钟变成是否达标

```python
flags = []
for m in minutes_list:
    flags.append(m >= 30)
```

得到布尔列表，供后面统计有多少 True。

```text
30 → True
40 → True
20 → False
```

## 三者可以组合

先过滤再汇总，或先转换再计数。仍是同一条轨道：遍历；变的是每轮装什么货。

@Callout(title: "每轮做一件清楚的事", tone: "information", accent: "mint") {
过滤决定收不收；转换决定变成什么；汇总决定如何并入总结果。
}

@Quiz(id: "py-iter-filter.quiz-1", kind: "singleChoice") {
`minutes_list = [30, 40, 20]`，按「只收 ≥30」过滤后，`good_days` 更可能是？

@Option(id: "py-iter-filter-q1-two", correct: true) {
[30, 40]，20 被丢掉
}

@Option(id: "py-iter-filter-q1-all") {
[30, 40, 20]，过滤从不删元素
}

@Option(id: "py-iter-filter-q1-bool") {
[True, True, False]，那是转换不是过滤到原值
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
过滤留下的仍是原来的分钟值，只是少了不合格的。
}

@Feedback(when: "incorrect", title: "分清过滤和转换", tone: "warning", accent: "amber") {
留下 30/40 是过滤；变成 True/False 是转换。
}
}

@Quiz(id: "py-iter-filter.quiz-2", kind: "singleChoice") {
把每天分钟变成 True/False「是否达标」，这属于？

@Option(id: "py-iter-filter-q2-map", correct: true) {
转换：每个输入对应一个新值
}

@Option(id: "py-iter-filter-q2-only-sum") {
只能叫汇总，因为结果变少了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
元素个数常仍相同，但每个都换成了另一种形态。
}

@Feedback(when: "incorrect", title: "看个数与形态", tone: "warning", accent: "amber") {
汇总常得到一个总数；转换常得到等长的新序列。
}
}
