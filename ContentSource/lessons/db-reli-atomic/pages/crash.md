事务承诺「一起成功或一起取消」，靠的是引擎把修改做成**可恢复的完整单元**：中途崩溃时，未提交的变更不会变成最终真相。

这一课把「怎样避免不完整的修改」说死：不是靠运气，而是靠提交边界与日志一类机制（你不必会实现，但要会依赖）。

## 崩溃之后

```text
事务进行中 → 断电
重启后
├─ 已提交的留下
└─ 未提交的回滚干净
```

你不应看到「库存扣了一半字段」这种撕开的行。

## 应用侧也要守边界

引擎保证事务内的原子性；若你在事务外自己先写文件再写库、两套系统无统一边界，仍可能裂。数据库能护住它承诺的那一段。

@Callout(title: "不完整修改止于未提交", tone: "information", accent: "amber") {
提交是公开真相的闸门。
}

@Quiz(id: "db-reli-atomic.quiz-1", kind: "singleChoice") {
事务做到一半服务器断电。重启后，未提交的那几步通常怎样？

@Option(id: "db-reli-atomic-q1-rollback", correct: true) {
被回滚，不成为最终数据

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
未提交不生效。
}
}
@Option(id: "db-reli-atomic-q1-keep") {
强制保留一半改动以纪念崩溃
}
@Option(id: "db-reli-atomic-q1-random") {
随机保留其中一步
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
原子性针对提交边界。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：已提交事务在断电后是否仍在？应在。
}
}
