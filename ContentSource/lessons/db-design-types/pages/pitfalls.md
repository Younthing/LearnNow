类型还会影响**排序与筛选**是否符合直觉。

## 文本数字 vs 数值

若把积分存成文本，`"12"` 和 `"5"` 的大小比较可能按字符规则走，结果不一定是数学上的十二大于五。存成整数，比较才按数值来。

```text
文本比较（示意）："12" 与 "5" 可能不按数学大小
整数比较：12 > 5 明确
```

## 钱为什么要小心

价格涉及小数。用会「漂」的近似小数去做钱，可能差一分。入门记住：钱需要**精确**表示；具体用哪种精确类型因引擎而异，但「随便用近似小数」通常不合适。

@Callout(title: "类型错了，对账会疼", tone: "information", accent: "amber") {
显示正确不保证比较与计算正确。
}

@Quiz(id: "db-design-types.quiz-2", kind: "singleChoice") {
积分存成文本后，筛选「积分大于 9」出现怪结果。最可疑的原因是？

@Option(id: "db-design-types-q2-compare", correct: true) {
文本比较按字符规则，不一定等于数值大小比较

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
类型决定比较语义。
}
}
@Option(id: "db-design-types-q2-gone") {
大于 9 的积分会自动从库里删除
}
@Option(id: "db-design-types-q2-phone") {
电话列干扰了积分列
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先怀疑比较语义，而不是魔法删除。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把积分改回整数类型再比一次，怪结果是否消失？
}
}

@Quiz(id: "db-design-types.quiz-3", kind: "singleChoice") {
菜单价格 12.50 元。用「会近似误差的二进制小数」直接当钱，主要风险是？

@Option(id: "db-design-types-q3-money", correct: true) {
累加或比较时可能差一分，对账对不上

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
钱需要精确。
}
}
@Option(id: "db-design-types-q3-display") {
屏幕上一定显示成乱码
}
@Option(id: "db-design-types-q3-fast") {
查询会变快，所以应该用
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
钱的问题是精确，不是显示字体。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：两笔 0.10 加十次，是否仍精确等于 1.00？近似小数不一定。
}
}
