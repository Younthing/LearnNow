会员表有了「积分」列。它看起来是数字，但若被当成普通文字存，后果会在比较与计算时出现。

**数据类型**告诉引擎：这一列的值按什么规则存储与比较。选错了，不是「也能显示」，而是「算不对、比不准」。

## 同一列，同一套规则

积分用整数，电话用文本（保留前导零、不当作可加减的量），下单时间用日期时间。引擎据此拒绝明显离谱的写入，例如往整数列塞「很多」。

```text
积分  →  整数（可加可比较大小）
电话  →  文本（不是用来做乘法的）
价格  →  精确小数（钱）
```

## 为什么「看起来像数」也不一定用数值类型

电话号码全是数字字符，但你不会拿两部电话相加。用文本保存，才能稳定保留格式，也避免被当成数值去掉前导零。

@Callout(title: "类型＝比较与运算的规则", tone: "information", accent: "amber") {
选类型，就是在选这一列允许怎样算、怎样比。
}

@Quiz(id: "db-design-types.quiz-1", kind: "singleChoice") {
要把会员电话存进数据库。更稳妥的类型选择是？

@Option(id: "db-design-types-q1-text", correct: true) {
文本：电话不当作可加减的量，还要保留前导零等格式

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
可运算不等于业务上应该运算。
}
}
@Option(id: "db-design-types-q1-int") {
整数：全是数字，就该当整数
}
@Option(id: "db-design-types-q1-bool") {
是/否：有电话就是真，没电话就是假
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
电话的业务操作是匹配与显示，不是算术。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：你会不会把两个电话号码相加当业务？不会，就别用数值类型硬扛。
}
}
