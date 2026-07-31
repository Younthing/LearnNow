上一单元的 `SELECT` 默认取出所有行。店员真正要的是：「积分大于 `10` 的会员」。这靠 `WHERE` 条件筛选。

筛选发生在原表行上：先判断每行是否满足条件，再决定进不进结果。

## 条件长什么样

```text
SELECT 姓名, 积分
FROM 会员
WHERE 积分 > 10
```

只有积分严格大于 `10` 的行出现在结果里。阿明 `12` 在；小陈 `5` 不在。

## 比较与组合

常见比较：`=`、`<>`、`>`、`<`、`>=`、`<=`。还可用 `AND` / `OR` 组合多个条件。入门先保证每个条件本身说得清。

@Callout(title: "WHERE 决定谁留下", tone: "information", accent: "amber") {
列投影决定看哪几列；WHERE 决定看哪几行。
}

@Quiz(id: "db-query-where.quiz-1", kind: "singleChoice") {
WHERE 积分 > 10 会不会把积分等于 10 的会员包含进来？

@Option(id: "db-query-where-q1-no", correct: true) {
不会。> 是严格大于，等于 10 不满足

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
符号要读准。
}
}
@Option(id: "db-query-where-q1-yes") {
会，大于号通常包含等于
}
@Option(id: "db-query-where-q1-null") {
会，所有 NULL 积分都会进来
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
要包含 10 应写 >=。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把条件改成 >= 10，边界行是否出现？
}
}
