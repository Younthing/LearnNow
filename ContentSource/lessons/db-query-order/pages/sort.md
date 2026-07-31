筛选之后，店长还想「积分从高到低排列」。这是 `ORDER BY`：不增删行，只规定结果的展示顺序。

## 基本写法

```text
SELECT 姓名, 积分
FROM 会员
ORDER BY 积分 DESC
```

`DESC` 降序；`ASC` 升序（常可省略为默认升序）。小陈 `5` 会排在阿明 `12` 后面（降序时）。

## 排序对象是结果

ORDER BY 作用在查询结果上。原表在磁盘上的物理顺序未必改变；你拿到的结果集按指定列排好。

@Callout(title: "ORDER BY 管顺序", tone: "information", accent: "amber") {
它不筛选谁留下，只决定留下的人怎么排。
}

@Quiz(id: "db-query-order.quiz-1", kind: "singleChoice") {
只有 ORDER BY、没有 WHERE 的查询，会怎样？

@Option(id: "db-query-order-q1-all-sorted", correct: true) {
通常仍返回所有行，只是按指定列排好序

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
排序≠筛选。
}
}
@Option(id: "db-query-order-q1-one") {
只会返回排序后的第一行
}
@Option(id: "db-query-order-q1-delete") {
会删掉排在后面的行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
要减少行数仍需 WHERE。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：结果行数是否等于表中行数（在无其它限制时）？
}
}
