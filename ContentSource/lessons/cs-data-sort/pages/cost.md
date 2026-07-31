排序不是免费的：比较与移动元素要花时间。数据已有序或只查一次，可能不必先排。

## 权衡怎么做

| 场景 | 更倾向 |
| --- | --- |
| 反复查找同一批数据 | 先排序可能更值 |
| 只查一次且列表很短 | 直接线性查找 |
| 需要固定展示顺序 | 需要排序 |

```text
排序成本
  ↓
换来多次查找/展示便利
  ↓
是否划算看使用次数
```

## 下一步

下一课用更清楚的尺子比较算法效率：数关键步骤，并看规模变大时谁涨得慢。

@Callout(title: "有成本", tone: "warning", accent: "amber") {
排序用前期时间换后期便利；不是永远先排再说。
}

@Quiz(id: "cs-data-sort-cost.quiz-1", kind: "singleChoice") {
列表只有 3 个元素，且只会查找一次。按这一页，更合理的是？

@Option(id: "cs-data-sort-cost-q1-linear", correct: true) {
直接线性查找，未必先付排序成本

@Feedback(title: "看使用次数", tone: "success", accent: "mint") {
短期一次性场景，简单扫描往往够用。
}
}

@Option(id: "cs-data-sort-cost-q1-always") {
无论什么情况都必须先排序
}

@Option(id: "cs-data-sort-cost-q1-forbid") {
禁止任何查找
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
效率选择依赖数据规模与使用模式。
}

@Feedback(when: "incorrect", title: "算账", tone: "warning", accent: "amber") {
先排序的成本能否被后续多次使用摊薄？
}
}
