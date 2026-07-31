知道该循环了。Python 里最常见的写法是 **`for ... in ...`**：从一串数据里依次取出每一个，对它执行循环体。

## 逐日打印

```python
minutes_list = [30, 40, 20, 50, 35]
for m in minutes_list:
    print("这一天学了", m, "分钟")
```

`m` 每一轮代表当前那天的分钟。列表有 5 个数，循环体就跑 5 次。

```text
取出 30 → 打印
取出 40 → 打印
取出 20 → 打印
...
```

## 循环体里用的是「当前这个」

循环体内写 `m`，指的是这一轮拿到的值，不是整份列表。若要累计总和，需要另设变量，在每一轮里更新。

## 和 while 的分工（识别即可）

`for` 适合「有一串东西要逐个处理」。`while` 适合「不确定次数、靠条件决定是否继续」。本课先把 for 用熟。

@Callout(title: "一轮一个", tone: "information", accent: "mint") {
`for` 每次取出 **一个** 元素，对它跑一遍循环体。
}

@Quiz(id: "py-loop-for.quiz-1", kind: "singleChoice") {
上面的列表有 5 个分钟数。循环体里的 `print` 会执行几次？

@Option(id: "py-loop-for-q1-five", correct: true) {
5 次，每个元素一轮
}

@Option(id: "py-loop-for-q1-one") {
1 次，因为只有一行 print
}

@Option(id: "py-loop-for-q1-zero") {
0 次，for 只负责取出不执行打印
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
元素个数决定轮数；每一轮都会跑一遍循环体。
}

@Feedback(when: "incorrect", title: "数元素个数", tone: "warning", accent: "amber") {
列表里有几个要处理的值，循环体通常就跑几遍。
}
}

@Quiz(id: "py-loop-for.quiz-2", kind: "singleChoice") {
某一轮里 `m` 的值是 20。此时 `m` 代表什么？

@Option(id: "py-loop-for-q2-current", correct: true) {
当前这一轮取到的那个分钟数
}

@Option(id: "py-loop-for-q2-all") {
整份 minutes_list 的总和
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
循环变量绑定的是当前元素，不是整表。
}

@Feedback(when: "incorrect", title: "看这一轮取出了谁", tone: "warning", accent: "amber") {
for 每一轮只把一个元素交到 m 手里。
}
}
