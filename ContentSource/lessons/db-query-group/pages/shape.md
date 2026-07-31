SELECT 列表里，出现的非聚合列通常应出现在 GROUP BY 中——否则「这一行到底代表谁」会含糊。

## 合法形状（入门）

```text
SELECT 饮品名, COUNT(*)
FROM 订单明细
GROUP BY 饮品名
```

`饮品名` 是分组键；`COUNT(*)` 是组上统计。

## 与 WHERE 的顺序直觉

先用 WHERE 去掉不关心的明细，再分组——避免把退单之类算进去。更细的 HAVING（对组筛选）可后学；入门先掌握「组从哪来」。

@Callout(title: "结果行＝一个组的摘要", tone: "information", accent: "amber") {
不要把未分组的明细列随便挂在汇总行上。
}

@Quiz(id: "db-query-group.quiz-2", kind: "singleChoice") {
SELECT 饮品名, 会员名, COUNT(*) 却只 GROUP BY 饮品名。入门模型为什么说这有问题？

@Option(id: "db-query-group-q2-ambiguous", correct: true) {
同一饮品组里可能有多个会员名，引擎无法判定汇总行该显示哪一个

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
非聚合列需在分组键中。
}
}
@Option(id: "db-query-group-q2-faster") {
这样写会更快，所以推荐
}
@Option(id: "db-query-group-q2-pk") {
因为缺少主键就不能分组
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
汇总行必须含义单一。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：美式组里既有阿明又有小陈，会员名填谁？
}
}

@Quiz(id: "db-query-group.quiz-3", kind: "singleChoice") {
GROUP BY 的主要作用是？

@Option(id: "db-query-group-q3-bucket", correct: true) {
按指定列的值把行收成组，以便组上统计

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
切分。
}
}
@Option(id: "db-query-group-q3-sort") {
只排序不分组
}
@Option(id: "db-query-group-q3-delete") {
按组删除原表
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
分组为统计服务。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：没有统计函数时，纯 GROUP BY 常用来去重键值——仍是「一组一行」。
}
}
