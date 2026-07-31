会员刚办卡，邮箱还没填。这一格该写什么？写空字符串 `""`？写 `0`？还是标记为「未知」？

**空值（NULL）**表示：这里没有值——不知道、不适用、或尚未提供。它不是数字零，也不是空文本。

## 三种「空」别混

```text
NULL   → 没有值（未知/未填）
0      → 有值，就是零
""     → 有值，是长度为 0 的文本
```

日日咖：积分是 `0` 表示确实是零；邮箱是 NULL 表示还没收集。若把邮箱写成 `""`，你分不清「故意不填」还是「系统默认空串」。

## 为什么引擎要特殊对待

对 NULL 做比较，结果常常不是普通的真/假，而是「未知」。`积分 > 10` 在积分为 NULL 时，通常不会把它当成满足条件的行。

@Callout(title: "NULL＝没有值", tone: "information", accent: "amber") {
它不是 0，也不是空字符串。
}

@Quiz(id: "db-design-null.quiz-1", kind: "singleChoice") {
新会员积分显示为 0，邮箱显示为「未填写（NULL）」。二者含义一样吗？

@Option(id: "db-design-null-q1-diff", correct: true) {
不一样：0 是确定的数值；NULL 表示邮箱这个位置尚无值

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
零是值，NULL 不是值。
}
}
@Option(id: "db-design-null-q1-same") {
一样，都表示没有
}
@Option(id: "db-design-null-q1-email-zero") {
邮箱的 NULL 其实等于数字 0
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
业务含义不同，不能混用。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把积分改成 NULL，还敢不敢说「他积分为零」？不敢，就说明 NULL≠0。
}
}
