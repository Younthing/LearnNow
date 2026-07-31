有了 DBMS，数据要按什么形状放？日日咖最常见的答案是：**关系数据库**——用一张张表来放，表与表之间用明确的关联连起来。

「关系」在这里不是人际社交，而是：**行与行、表与表按约定对齐**，而不是把所有东西糊在一大段文字里。

## 先看成格子，再看成关系

会员可以放成一张表：每一行是一个会员，每一列是一种信息（姓名、电话、积分）。订单另放一张表：每一行是一笔订单。

```text
会员表                订单表
├─ 一行 = 一个会员    ├─ 一行 = 一笔订单
└─ 列 = 姓名/电话…    └─ 列 = 哪位会员/金额…
```

两张表分开存，再用「会员编号」之类的共同标记对齐——谁下了哪笔单，就对得上。

## 为什么叫「关系」

关系模型的核心承诺是：数据以**表**的形式组织，查询时可以按条件把符合的行挑出来，也可以按共同标记把多表拼到一起看。

它不是唯一一种数据库，但是入门最常见、也最适合讲清「组织与查询」的一种。

@Callout(title: "关系＝对齐的约定", tone: "information", accent: "amber") {
表把同类事物排齐；表之间用共同标记对齐，而不是把一切糊进一段文字。
}

@Quiz(id: "db-intro-relational.quiz-1", kind: "singleChoice") {
日日咖把「会员资料」和「每笔订单」放在同一大段日记式文本里。按关系模型的思路，主要问题是什么？

@Option(id: "db-intro-relational-q1-hard-align", correct: true) {
同类信息没有排成可对齐的行与列，按条件查找和关联会很吃力

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
关系模型靠表结构提供可对齐的格子。
}
}
@Option(id: "db-intro-relational-q1-space") {
文本更占空间，所以一定存不下
}
@Option(id: "db-intro-relational-q1-illegal") {
日记式文本在法律上不允许存会员电话
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
难的不是「写进去」，而是「对齐后按条件取回」。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：你要列出「积分大于 10 的会员」，在日记长文里好找，还是在一列表格里好找？
}
}
