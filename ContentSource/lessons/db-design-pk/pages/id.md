会员表里可能有两个都叫「阿明」的人。靠姓名找，会撞车。靠电话找，号码也可能更换。

**主键**是表中用来**唯一标识一行**的列（或列组合）：任意两行的主键值都不能相同，且通常不为空。

## 标识，不是「最好看的字段」

主键的任务是让引擎和你能稳定地说：「我说的是这一行，不是另一行。」日日咖可以给每个会员一个内部编号 `M001`、`M002`，不随姓名修改而漂移。

```text
会员表
主键M001  阿明  138…
主键M002  阿明  139…   ← 同名，但主键不同
```

## 为什么不能随便拿会变的东西当唯一标识

电话能唯一吗？多数时候能，但用户换号后，若电话既是联系方式又是主键，历史订单的指向会痛苦。更常见的做法是：主键用稳定的内部编号，电话仍作普通列（可另加唯一约束）。

@Callout(title: "主键＝稳定的行身份证", tone: "information", accent: "amber") {
它保证「指到唯一一行」，不保证「对人最好记」。
}

@Quiz(id: "db-design-pk.quiz-1", kind: "singleChoice") {
两名会员都叫阿明。怎样最稳妥地区分他们在表中的行？

@Option(id: "db-design-pk-q1-pk", correct: true) {
用各自行的主键（唯一标识），不要只靠姓名

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
姓名可重复，主键不可重复。
}
}
@Option(id: "db-design-pk-q1-name") {
看谁先注册，先注册的姓名自动更真
}
@Option(id: "db-design-pk-q1-merge") {
强制改掉其中一个的姓名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
标识靠主键，展示靠姓名。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：删掉姓名列，你是否仍能指出某一行？有主键就能。
}
}
