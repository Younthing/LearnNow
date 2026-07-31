多列排序：先按积分降序，积分相同再按姓名升序——把次要键写在后面。

```text
ORDER BY 积分 DESC, 姓名 ASC
```

## 类型再次现身

文本列与数值列的排序规则不同。积分若误存文本，顺序可能「看起来怪」。这与设计单元的类型课呼应。

## 与筛选叠用

先 WHERE 再 ORDER BY，是常见组合：先缩小集合，再排序展示。

@Callout(title: "先定谁留下，再定怎么排", tone: "information", accent: "amber") {
WHERE 与 ORDER BY 各管一摊。
}

@Quiz(id: "db-query-order.quiz-2", kind: "singleChoice") {
两位会员积分都是 12，ORDER BY 积分 DESC, 姓名 ASC。决定他们相对顺序的是？

@Option(id: "db-query-order-q2-name", correct: true) {
姓名的升序，因为积分已相同，轮到第二排序键

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
多键排序按从左到右生效。
}
}
@Option(id: "db-query-order-q2-random") {
完全随机，第二键无效
}
@Option(id: "db-query-order-q2-phone") {
电话号码，尽管没写在 ORDER BY 里
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
写在后面的键在并列时接手。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：去掉第二键后，并列行的顺序是否变得不稳定？
}
}

@Quiz(id: "db-query-order.quiz-3", kind: "singleChoice") {
ORDER BY 的主要作用是？

@Option(id: "db-query-order-q3-sort", correct: true) {
规定结果集中行的先后顺序

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
顺序。
}
}
@Option(id: "db-query-order-q3-filter") {
删除不满足条件的行
}
@Option(id: "db-query-order-q3-insert") {
插入新行到正确位置
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
排序不插入。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：ORDER BY 之后表里的行数变了吗？通常不变。
}
}
