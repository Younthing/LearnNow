许多场景下，数组长度需要**提前规划**或整块扩容。估小了放不下；估大了浪费空间。

## 规划压力

你不知道用户会记录多少天步数时，固定长度数组要么截断，要么预留很多空位。

```text
估小 → 装不下
估大 → 空着浪费
扩容 → 可能整块复制到新空间
```

## 不是说数组无用

它只是在「长度多变 + 中间常改」时不够灵活。下页看它仍然擅长什么。

## 动态数组也是一种折中

许多语言提供可变长度数组：容量不够时另辟更大连续区并复制过去。它缓解「估小了」，但扩容瞬间仍可能很贵。

理解「连续块」之后，就知道扩容为什么不是魔法免费。

@Callout(title: "长度要规划", tone: "information", accent: "mint") {
固定连续块对未知增长不友好。
}

@Quiz(id: "cs-mem-array-limit-size.quiz-1", kind: "singleChoice") {
事先只分配 3 格，却要存第 4 天步数。直接后果通常是？

@Option(id: "cs-mem-array-limit-size-q1-full", correct: true) {
放不下，需要扩容或换结构

@Feedback(title: "容量上限", tone: "success", accent: "mint") {
连续块的容量是硬约束，除非另分配。
}
}

@Option(id: "cs-mem-array-limit-size-q1-auto") {
第 4 个值会自动覆盖物理定律
}

@Option(id: "cs-mem-array-limit-size-q1-ok") {
长度 3 的数组永远能存无限天
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
容量与灵活性是数组的现实边界。
}

@Feedback(when: "incorrect", title: "数格子", tone: "warning", accent: "amber") {
只有三格时，第四个值的门牌号在哪？
}
}
