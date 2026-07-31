把会员、饮品、订单全塞一张宽表，短期好像省事：一行里既有姓名又有品项。订单一多、电话一改，重复与空洞会一起爆发。

**拆成多张表**，是为了让每一类对象只说自己的话，再用标识对齐。

## 一张宽表的痛

```text
宽表一行：
阿明 138… 拿铁 22 元 2026-08-01
阿明 138… 美式 18 元 2026-08-02
```

电话重复；阿明还没下单时，整行很多列空着却占着「订单形状」。

## 拆开之后

会员表管人；饮品表管菜单；订单表管「谁在何时买了什么」。各表行数按自己的节奏增长。

@Callout(title: "一类事实一张表", tone: "information", accent: "amber") {
拆分是为了对齐与更新，不是为了变复杂。
}

@Quiz(id: "db-rel-split.quiz-1", kind: "singleChoice") {
宽表里同一会员电话出现在 50 笔订单行。换号时主要风险是？

@Option(id: "db-rel-split-q1-miss", correct: true) {
要改 50 处，漏改就会出现多个「当前电话」

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
重复存储的更新异常。
}
}
@Option(id: "db-rel-split-q1-fast") {
改一处会自动改 50 处，所以没风险
}
@Option(id: "db-rel-split-q1-type") {
电话会从文本变成整数
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
拆出会员表后改一处即可。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：电话若只在会员表，订单只存会员编号，改几处？一处。
}
}
