拆分的代价是：看「谁买了什么」时，要跨表对齐。这是值得付的账——用连接查询换数据一致性。

## 何时该拆

```text
该拆：不同对象、不同生命周期、重复严重
可缓：极少变化的小字典且从不单独维护
```

日日咖的会员与订单生命周期不同：人在，订单天天新增——必拆。

## 预告

下一课起：外键怎样声明「订单里的会员编号必须真的存在」；再往后用 JOIN 把拆开的表拼回可读的结果。

@Callout(title: "拆是存的策略，拼是看的策略", tone: "information", accent: "amber") {
存时减少重复，看时再连接。
}

@Quiz(id: "db-rel-split.quiz-2", kind: "singleChoice") {
拆成多表后，查询「阿明买过什么」会怎样？

@Option(id: "db-rel-split-q2-join", correct: true) {
通常需要按会员标识把会员表与订单表对齐后才能一次看清

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
存拆看拼。
}
}
@Option(id: "db-rel-split-q2-impossible") {
永远无法查询，所以不该拆
}
@Option(id: "db-rel-split-q2-name-only") {
只查会员表姓名列就够了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
连接是拆分的配套能力。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：订单表里有没有饮品名？若只有编号，还要再对齐饮品表。
}
}

@Quiz(id: "db-rel-split.quiz-3", kind: "singleChoice") {
为什么需要把数据拆成多张表？

@Option(id: "db-rel-split-q3-why", correct: true) {
让每类对象单独维护，减少重复与更新异常，再用标识关联

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
一致优先。
}
}
@Option(id: "db-rel-split-q3-slow") {
故意让所有查询变慢
}
@Option(id: "db-rel-split-q3-law") {
法律要求表数量必须是偶数
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
动机是一致性与清晰边界。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：宽表改电话要几处？拆表后呢？
}
}
