关系模型还有一个实用后果：同一类事实尽量用**同一种格子形状**描述，查询才稳定。

## 同一张表，形状一致

会员表里每一行都有姓名、电话、积分这些列。不会出现「这一行多一列备注、下一行却少了电话」这种随意变形——结构先定，数据后填。

```text
允许：每一行都有相同的列
不允许：这一行突然多出一列「临时字段」却没有表结构支持
```

（真实产品里有灵活字段的做法，但入门先掌握「表结构稳定」这一刀。）

## 和下一种组织方式的边界

有的系统把一条记录存成一份文档，字段可多可少。关系数据库的默认习惯是：**先定表结构，再写入符合结构的行**。日日咖的会员、订单正适合这种「形状稳定、经常按条件查」的场景。

下一课会把表、行、列三个词钉死。

@Callout(title: "先定形状，再填格子", tone: "information", accent: "amber") {
关系表要求同行同构：列的含义对每一行都成立。
}

@Quiz(id: "db-intro-relational.quiz-2", kind: "singleChoice") {
同事想在会员表里给某一个人临时加一列「喜欢的座位」，其他人没有这一列。按本课的入门模型，更稳妥的做法是？

@Option(id: "db-intro-relational-q2-column", correct: true) {
先决定这是不是所有会员都可能有的属性；若是，就作为正式列设计进表结构

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
表结构对每一行一视同仁。
}
}
@Option(id: "db-intro-relational-q2-one-row") {
只在那一行旁边手写备注，不要进表结构
}
@Option(id: "db-intro-relational-q2-hide") {
写进姓名字段里，用括号拼在名字后面
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
临时糊弄会破坏「每一行同构」，后续查询会受苦。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：以后要筛选「喜欢靠窗的会员」，拼在姓名里的备注还好不好查？
}
}

@Quiz(id: "db-intro-relational.quiz-3", kind: "singleChoice") {
「关系数据库」里的「关系」，在本课指的是？

@Option(id: "db-intro-relational-q3-align", correct: true) {
用表组织数据，并按约定在行、列、表之间对齐关联

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
不是社交意义上的人际关系。
}
}
@Option(id: "db-intro-relational-q3-friends") {
会员之间谁跟谁是朋友
}
@Option(id: "db-intro-relational-q3-vendor") {
必须向某一家数据库厂商买产品
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
关系＝结构化对齐，不是交友关系。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：课里画的会员表和订单表，连起来的是共同标记，不是「认识」。
}
}
