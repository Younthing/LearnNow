日日咖要上数据库了。第一步不是写指令，而是问：现实里有哪些**对象**，各自要记住哪些事实？

把「会员」「饮品」「订单」先说清楚，再变成表。表是对象的落点，不是先画格子再硬塞现实。

## 先找对象，再列属性

对象是你要反复记录、查找的那一类事物。会员是一类；每一杯菜单上的饮品是一类；每一笔结账是一类。

```text
现实
├─ 会员：来喝过、有积分的人
├─ 饮品：菜单上可点的品项
└─ 订单：某次结账
  ↓ 各变一张表
会员表 / 饮品表 / 订单表
```

属性是描述对象的字段：会员有姓名、电话；饮品有名称、价格。

## 不要把不同对象糊进一行

把「阿明点了拿铁」写成会员表的一列「今日饮品」，明天他又点美式，旧信息往哪放？订单是另一类对象，应有自己的行。

@Callout(title: "一类对象一张表", tone: "information", accent: "amber") {
先命名现实中的类，再为类列出稳定属性。
}

@Quiz(id: "db-design-objects.quiz-1", kind: "singleChoice") {
要把「小陈昨天买了两杯美式」记进库。按本课思路，至少会碰到哪两类对象？

@Option(id: "db-design-objects-q1-member-order", correct: true) {
会员（小陈）和订单（那次购买）；饮品也可能单独成表

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
人和一次购买是不同类对象。
}
}
@Option(id: "db-design-objects-q1-only-drink") {
只需要饮品表，因为美式已经说明一切
}
@Option(id: "db-design-objects-q1-only-phone") {
只需要电话号码，其它都可以推出来
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
购买事件与人、与品项都要分开想。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：明天小陈又买一次，是覆盖昨天，还是多一条订单？若是多一条，订单就是独立对象。
}
}
