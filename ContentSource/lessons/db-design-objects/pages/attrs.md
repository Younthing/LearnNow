对象定了，还要决定**哪些属性进表**。不是现实中知道的一切都要进库，只留决策与查询真正用到的。

## 属性要稳定、可复用

会员电话会用来查找，值得成为列。他今天穿什么颜色的衣服，通常不必进会员表——除非你的业务就是按衣服颜色服务。

```text
进表：姓名、电话、积分
暂不进：今天的心情、临时座位偏好（除非业务需要）
```

## 一个属性只说一件事

「姓名与电话」不要糊成一个字段。以后按电话查找时，糊在一起的字段会变成负担。

下一课会讲：这些字段还要选对**数据类型**。

@Callout(title: "只留用得上的事实", tone: "information", accent: "amber") {
属性服务于查找与业务规则，不是现实的完整镜像。
}

@Quiz(id: "db-design-objects.quiz-2", kind: "singleChoice") {
有人建议会员表加一列「备注」，把地址、过敏原、喜欢的杯子一股脑写进去。主要风险是什么？

@Option(id: "db-design-objects-q2-mixed", correct: true) {
多种事实糊在一格，以后很难按其中某一项稳定查询或校验

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
一列应尽量只承载一种可对齐的事实。
}
}
@Option(id: "db-design-objects-q2-space") {
备注两个字当列名不合法
}
@Option(id: "db-design-objects-q2-ok") {
没有风险，备注列是最佳实践
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
能进结构化列的，就不要永久塞进自由备注。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：你要找出所有对牛奶过敏的会员，在自由备注里好不好筛？
}
}

@Quiz(id: "db-design-objects.quiz-3", kind: "singleChoice") {
饮品的价格会变。价格应主要属于哪类对象的属性？

@Option(id: "db-design-objects-q3-drink", correct: true) {
饮品（菜单品项）的属性；订单里还可另存「成交时价格」若需要历史

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
菜单价属于品项；是否快照到订单是后续设计。
}
}
@Option(id: "db-design-objects-q3-member") {
会员的属性，因为人决定价格
}
@Option(id: "db-design-objects-q3-nowhere") {
哪里都不存，每次口头报
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先问「价格在描述谁」。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：换一杯饮品，价格是否通常跟着品项走？是，就优先挂在饮品上。
}
}
