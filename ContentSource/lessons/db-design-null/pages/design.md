设计表时要主动决定：哪些列允许 NULL，哪些必须有值。

## 允许空的代价

邮箱允许 NULL，登记更快，但以后「给所有会员发邮件」时要处理缺失。电话若业务上必须能联系到人，就应禁止 NULL，逼登记时填上。

```text
必须有：主键、（按业务）电话
可暂时没有：邮箱、生日
```

## 聚合时的常见意外

对一列求和时，NULL 通常不当作 `0` 加进去，而是被跳过。人数统计与「非空个数」也可能不是一回事。细节因引擎略有差异，但入门要有这根弦：NULL 会让统计变「少」。

@Callout(title: "空得有意，不要随手", tone: "information", accent: "amber") {
允许 NULL 是业务决定，不是省事的默认。
}

@Quiz(id: "db-design-null.quiz-2", kind: "singleChoice") {
老板要统计「留了邮箱的会员人数」。积分全是数字，邮箱有的是 NULL。该看什么？

@Option(id: "db-design-null-q2-email", correct: true) {
统计邮箱非空的行数，而不是简单假定每个会员都有邮箱

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
NULL 表示未留邮箱。
}
}
@Option(id: "db-design-null-q2-all") {
直接数会员表总行数，人人都有邮箱
}
@Option(id: "db-design-null-q2-points") {
数积分大于 0 的人，等于留了邮箱
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺测属性要用「非空」来数。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：总人数与留邮箱人数能否不同？能，就说明不能偷懒用总行数。
}
}

@Quiz(id: "db-design-null.quiz-3", kind: "singleChoice") {
把「未知的积分」存成 0，以后可能造成什么误解？

@Option(id: "db-design-null-q3-fake-zero", correct: true) {
系统会以为他真的是零分，参与比较和活动时与「未知」完全不同

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
用 0 冒充未知会污染业务判断。
}
}
@Option(id: "db-design-null-q3-faster") {
只会让查询变快，没有误解
}
@Option(id: "db-design-null-q3-same") {
0 与 NULL 在所有运算里完全等价
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
假零比真缺失更危险。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：活动规则是「积分为 0 的送券」——未知的人该不该送？若不该，就不能存成 0。
}
}
