列决定「我们关心对象的哪一面」。行决定「正在说哪一个对象」。

## 列是字段，字段有名字

`电话` 列的名字告诉你：这一竖条里的值都按「电话」来理解。名字错了，人会读错；类型不合适（下一单元再讲），引擎也可能存错。

```text
列名：电话
├─ 阿明那一行 → 13800001111
└─ 小陈那一行 → 13900002222
```

## 三个词的对照

| 词 | 你看到的 | 在说什么 |
| --- | --- | --- |
| 表 | 整张会员清单 | 一类对象的集合 |
| 行 | 阿明那一横 | 某一个对象 |
| 列 | 积分那一竖 | 对象的一种属性 |

把三个词分清，后面「主键、查询、多表」才有落点。下一单元开始：怎样为日日咖设计这些格子。

@Callout(title: "表是集合，行是个体，列是属性", tone: "information", accent: "amber") {
先分清这三个方向，再谈怎么设计。
}

@Quiz(id: "db-intro-table.quiz-2", kind: "singleChoice") {
老板想知道「所有会员的电话」。按表的结构，他应该看什么？

@Option(id: "db-intro-table-q2-column", correct: true) {
看「电话」这一列，从上到下每一行的值

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
一列＝所有对象在同一属性上的取值。
}
}
@Option(id: "db-intro-table-q2-one-row") {
只看第一行，因为第一行代表全部
}
@Option(id: "db-intro-table-q2-table-name") {
只看表名「会员表」，表名里已经包含电话
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
「所有会员的某属性」＝读一列。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：要找「某一个会员的全套信息」，你是横着读一行，还是竖着读一列？
}
}

@Quiz(id: "db-intro-table.quiz-3", kind: "singleChoice") {
有人把「积分」解释成「表的名字」。错在哪？

@Option(id: "db-intro-table-q3-column", correct: true) {
积分是一列（属性），表名应是整张清单的名字，比如会员表

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
列名 ≠ 表名。
}
}
@Option(id: "db-intro-table-q3-ok") {
没错，积分就是表名
}
@Option(id: "db-intro-table-q3-row") {
积分其实是一行的名字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
表命名一类对象；列命名一种属性。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：表里还有姓名、电话等列——若「积分」是表名，其他列往哪放？
}
}
