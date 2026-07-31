分组常常配合**聚合函数**：把多行收成一个数。常见：`COUNT` 计数、`SUM` 求和、`AVG` 平均、`MAX` / `MIN` 最值。

它们解决的问题是：人肉加总易错，引擎对一组行做汇总更快更稳。

## 每个函数在问什么

```text
COUNT(*)     这组有多少行
SUM(金额)    金额加总
AVG(积分)    积分平均
MAX(积分)    组内最大
```

日日咖：今日订单金额 `SUM`；会员人数 `COUNT`。

## 聚合压缩信息

知道总和，不等于还保留每一笔。聚合是有意丢细节，换概览。

@Callout(title: "聚合＝多行变一值", tone: "information", accent: "amber") {
问法从「每一笔」变成「总共 / 平均 / 最大」。
}

@Quiz(id: "db-query-agg.quiz-1", kind: "singleChoice") {
想知道「今天卖了多少杯」，最直接的聚合是？

@Option(id: "db-query-agg-q1-count", correct: true) {
对今日订单明细行做 COUNT

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
杯数是计数问题。
}
}
@Option(id: "db-query-agg-q1-avg") {
AVG(杯)，尽管没有「杯」这一可平均列也硬写
}
@Option(id: "db-query-agg-q1-max") {
MAX(日期)，与杯数无关
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先匹配问题类型与函数。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：你要的是个数、总和还是平均？个数就 COUNT。
}
}
