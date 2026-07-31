主键还约束写入：新行必须带上尚未使用过的主键值（或由引擎生成）。

## 唯一且非空

两行主键相同，引擎应拒绝——否则「改这一行」会变得含糊。主键为空，同样无法标识。

```text
允许：M001 / M002 / M003
拒绝：第二行再写 M001
拒绝：主键空着
```

## 自然键与代理键（识别即可）

用业务里已有的唯一号当主键，叫自然键思路；用系统生成的编号，叫代理键思路。入门先掌握「必须能唯一标识行」；选哪种键，按稳定性和可变性判断。

@Callout(title: "没有唯一标识，就没有可靠的改与删", tone: "information", accent: "amber") {
改、删、关联都先要能指到同一行。
}

@Quiz(id: "db-design-pk.quiz-2", kind: "singleChoice") {
店员想新插入一个会员，却把主键写成已存在的 M001。按规则应怎样？

@Option(id: "db-design-pk-q2-reject", correct: true) {
拒绝插入，因为主键必须唯一

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
冲突的标识不能进表。
}
}
@Option(id: "db-design-pk-q2-overwrite") {
覆盖原来的 M001 会员资料
}
@Option(id: "db-design-pk-q2-dup") {
允许两个 M001，反正姓名不同
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
主键冲突应失败，而不是默默覆盖。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：若允许两个 M001，「把 M001 的积分改成 0」改谁？
}
}

@Quiz(id: "db-design-pk.quiz-3", kind: "singleChoice") {
为什么许多人更愿意用内部会员编号当主键，而不是用电话？

@Option(id: "db-design-pk-q3-stable", correct: true) {
内部编号更稳定；电话可能更换，不适合同时承担「永恒标识」

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
主键宜稳。
}
}
@Option(id: "db-design-pk-q3-secret") {
电话太长，主键只能三个字符
}
@Option(id: "db-design-pk-q3-illegal") {
法规禁止电话进数据库
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
可变属性可以留作列，不一定要当主键。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：换号后，历史订单仍应指向同一个人——靠什么不变的标识？
}
}
