外键让多表设计从「口头约定」变成「引擎执行」。

## 父表与子表

被指向的一侧常称父表（会员）；指向的一侧称子表（订单）。先有父行，再有子行——这是常见插入顺序。

```text
先：会员 M001
后：订单引用 M001
```

## 删除时的选择（识别）

删父行时：拒绝（仍有子行）、级联删子行、或把子行外键置空——产品策略不同。入门先假设「有引用就先别删父行」。

@Callout(title: "先父后子", tone: "information", accent: "amber") {
引用完整性要求指向目标先存在。
}

@Quiz(id: "db-rel-fk.quiz-2", kind: "singleChoice") {
外键约束主要保证什么？

@Option(id: "db-rel-fk-q2-ref", correct: true) {
子表引用的值在父表中真实存在（引用完整性）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
合法指向。
}
}
@Option(id: "db-rel-fk-q2-sort") {
结果一定按外键排序
}
@Option(id: "db-rel-fk-q2-speed") {
查询一定更快
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
完整性优先于速度神话。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：没有外键时，应用层忘了校验会怎样？可能留下悬空订单。
}
}

@Quiz(id: "db-rel-fk.quiz-3", kind: "singleChoice") {
为何说外键「建立表之间的关系」？

@Option(id: "db-rel-fk-q3-link", correct: true) {
它声明并强制子表列必须对齐父表已有标识，使两表行能可靠关联

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
关系被写进约束。
}
}
@Option(id: "db-rel-fk-q3-merge") {
它会把两张表物理合并成一张
}
@Option(id: "db-rel-fk-q3-friend") {
它自动把会员加为好友
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
逻辑关联，不是物理糊成一张。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：两表仍在，只是订单列必须能在会员主键中找到。
}
}
