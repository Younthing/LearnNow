一次可以插入多行，但每行仍要单独满足约束。

## 失败常常整行作废

小周这行主键与已有 `M001` 冲突，这行进不去；并不自动改成「更新旧行」。要改旧行，用后面的 `UPDATE`。

```text
插入冲突主键 → 拒绝这一行
需要修改已有行 → 用更新，不是插入
```

## 缺列时的默认与 NULL

若某列有默认值或允许 NULL，插入时可以不写它。否则必须提供值。设计阶段的决定，在这里变成写入时的体验。

@Callout(title: "插不进就检查约束", tone: "information", accent: "amber") {
冲突与缺值是信号，不是引擎坏了。
}

@Quiz(id: "db-sql-insert.quiz-2", kind: "singleChoice") {
想修改阿明的电话，却写了一条主键同为 M001 的 INSERT。最可能的结果是？

@Option(id: "db-sql-insert-q2-reject", correct: true) {
插入被拒绝；旧行还在，电话不会被这条 INSERT 改掉

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
INSERT 不负责更新已有主键行。
}
}
@Option(id: "db-sql-insert-q2-merge") {
自动合并成更新电话
}
@Option(id: "db-sql-insert-q2-dup") {
允许两个 M001 并存
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
改已有行请用 UPDATE。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：INSERT 的语义是「新增集合元素」还是「按主键覆盖」？入门模型里是新增。
}
}

@Quiz(id: "db-sql-insert.quiz-3", kind: "singleChoice") {
插入时漏了非空的电话列，又没有默认值。引擎通常怎样？

@Option(id: "db-sql-insert-q3-fail", correct: true) {
拒绝这行插入

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
非空约束在写入时生效。
}
}
@Option(id: "db-sql-insert-q3-blank") {
自动填「无」并成功
}
@Option(id: "db-sql-insert-q3-del-table") {
删掉整张会员表
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺必填值 → 失败。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：建表时电话标了非空，插入时能例外吗？通常不能。
}
}
