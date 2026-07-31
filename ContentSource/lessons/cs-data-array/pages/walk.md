处理整组数据时，用循环让下标从 `0` 走到长度减一，逐格访问。

## 遍历模式

`i` 从 `0` 到 `2`，每次读 `steps[i]` 累加。数组 + 循环，是批量处理的基本功。

```text
i=0 → 读 6000
i=1 → 读 7500
i=2 → 读 5000
结束
```

## 下一课预告

文字也可以看成字符的序列——字符串。很多操作与数组遍历同类。

## 遍历时下标怎么走

通常让 `i` 从 `0` 增到长度减一。每一步只做一件事：读 `steps[i]`，累加或比较，然后 `i` 加一。

只要长度可变，循环边界跟着长度走，就不必为「多一天」手写新的一行。

@Callout(title: "循环遍历", tone: "warning", accent: "amber") {
批量处理 = 下标推进 + 逐格操作。
}

@Quiz(id: "cs-data-array-walk.quiz-1", kind: "singleChoice") {
要求三天步数总和。按这一页，核心做法是？

@Option(id: "cs-data-array-walk-q1-loop", correct: true) {
循环下标，逐格累加

@Feedback(title: "遍历累加", tone: "success", accent: "mint") {
不必为每天单独写一行加法。
}
}

@Option(id: "cs-data-array-walk-q1-only0") {
只读下标 0，其余忽略
}

@Option(id: "cs-data-array-walk-q1-noindex") {
禁止使用下标
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
遍历是数组上最常见的算法骨架。
}

@Feedback(when: "incorrect", title: "想整组", tone: "warning", accent: "amber") {
要碰每一个元素时，循环下标是标准路径。
}
}
