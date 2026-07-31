选择算法看场景：数据是否已有序、查几次、内存是否紧张、实现复杂度能否接受。

## 决策清单

| 问题 | 影响 |
| --- | --- |
| 是否已排序 | 能否用依赖有序的方法 |
| 查询次数 | 能否摊薄预处理 |
| n 的大小 | 要不要在乎增长 |
| 实现成本 | 简单线性是否已够 |

```text
已排序？ → 影响可用算法
查几次？ → 影响预处理是否划算
n 多大？ → 影响要不要在乎增长
```

## 单元收口

数组与字符串存批量数据；查找定位；排序重组；效率用步骤增长衡量。下一单元进入内存与更灵活的组织结构。

@Callout(title: "场景决定选择", tone: "warning", accent: "amber") {
没有绝对最快；只有在前提与目标下更合适。
}

@Quiz(id: "cs-data-efficiency-choose.quiz-1", kind: "singleChoice") {
数据每次都重新生成且只查一次，列表很短。更合理的默认是？

@Option(id: "cs-data-efficiency-choose-q1-simple", correct: true) {
用简单的线性查找，避免昂贵预处理

@Feedback(title: "匹配场景", tone: "success", accent: "mint") {
摊不薄的预处理不值得。
}
}

@Option(id: "cs-data-efficiency-choose-q1-complex") {
无论场景多简单，都必须上最复杂的算法
}

@Option(id: "cs-data-efficiency-choose-q1-random") {
随机选一个算法名字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
效率决策是工程权衡。
}

@Feedback(when: "incorrect", title: "对照清单", tone: "warning", accent: "amber") {
查次数、是否已排序、n 大小，逐项问一遍。
}
}
