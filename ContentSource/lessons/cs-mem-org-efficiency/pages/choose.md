选型步骤：列出主操作 → 对照哪种结构让主操作便宜 → 接受次要操作变贵 → 用例子验证。

## 三问决策

```text
主操作是什么？
  ↓
哪种组织让它便宜？
  ↓
次要操作能否忍受？
```

把「快」绑在具体操作上，结构选择才站得住。

## 收束全课

计算机把信息表示成可处理的形式，程序驱动硬件在内存中按结构组织并处理数据。结构选择，正是「表示与执行」在工程上的交汇点。

## 用例子钉死选择

选定结构后，拿一两个真实操作序列走一遍：主操作是否明显更顺？次要操作的痛能否接受？

这与算法正确性检验同一精神：用具体例子，而不是口号。

@Callout(title: "按主操作选", tone: "warning", accent: "amber") {
先写清最频繁、最关键的操作，再选组织方式。
}

@Quiz(id: "cs-mem-org-efficiency-choose.quiz-1", kind: "singleChoice") {
系统几乎只在队尾追加、在队头取出任务。更匹配的组织是？

@Option(id: "cs-mem-org-efficiency-choose-q1-queue", correct: true) {
队列：先进先出匹配该主操作

@Feedback(title: "主操作对齐", tone: "success", accent: "mint") {
两端纪律正好服务排队。
}
}

@Option(id: "cs-mem-org-efficiency-choose-q1-stack") {
栈：后进先出，哪怕语义是排队
}

@Option(id: "cs-mem-org-efficiency-choose-q1-random") {
任意结构都一样，无需看操作
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
整门课的落点：表示、结构与执行一起决定能否高效完成任务。
}

@Feedback(when: "incorrect", title: "翻译主操作", tone: "warning", accent: "amber") {
尾进头出，对应哪种进出纪律？
}
}
