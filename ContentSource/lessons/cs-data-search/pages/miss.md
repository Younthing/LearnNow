扫完仍没有相等项，结果是**未找到**。这不是程序崩溃，而是算法的合法输出。

## 明确处理未找到

调用者要能区分「位置 0」与「没有」。用特殊标记或单独的失败信号，不要把「没有」假装成 `0` 除非约定清楚。

```text
扫到末尾
  ↓
仍无相等
  ↓
返回 未找到
```

## 下一课：排序如何帮忙

若数据预先排好序，可以有更快的查找法。先理解「为何排序」，再谈效率比较。

## 别把失败假装成功

若用 `-1` 表示未找到，就要保证合法下标从不取 `-1`。若语言用可选类型，就让「没有」成为明确的空值。

约定写进函数边界，比在调用点靠默契猜测更安全。

@Callout(title: "未找到也是结果", tone: "warning", accent: "amber") {
查完没有，要明确返回未找到，而不是默默假装成功。
}

@Quiz(id: "cs-data-search-miss.quiz-1", kind: "singleChoice") {
名单里没有 `"Zoe"`，线性查找结束后应怎样？

@Option(id: "cs-data-search-miss-q1-miss", correct: true) {
报告未找到

@Feedback(title: "合法失败", tone: "success", accent: "mint") {
调用者需要知道目标不在集合中。
}
}

@Option(id: "cs-data-search-miss-q1-zero") {
一律返回下标 0，即使 0 号是别人
}

@Option(id: "cs-data-search-miss-q1-crash") {
必须让整个设备关机
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
未找到是正常结果，应可被上层处理。
}

@Feedback(when: "incorrect", title: "分清失败信号", tone: "warning", accent: "amber") {
返回 0 会与「第一项命中」冲突，除非另有约定。
}
}
