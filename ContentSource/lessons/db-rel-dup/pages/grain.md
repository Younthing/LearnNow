连接之后，结果行数有时比你想的多：同一会员姓名出现很多次，像「重复」。

常见原因不是引擎坏了，而是**一对多对齐的数学**：一侧一行对上另一侧多行，结果自然复制「一」那一侧的字段。

## 重复从哪来

```text
会员阿明 1 行
订单 3 行（都属阿明）
内连接结果：3 行，每行都带「阿明」
```

「阿明」重复三次，是因为有三笔订单，不是会员表里有三个阿明。

## 先问粒度

你想要的是「每位会员一行」还是「每笔订单一行」？粒度不同，该不该觉得「重复」就不同。

@Callout(title: "一对多连接会复制「一」侧字段", tone: "information", accent: "amber") {
看起来像重复，其实是明细粒度。
}

@Quiz(id: "db-rel-dup.quiz-1", kind: "singleChoice") {
会员 1 行、其订单 4 行，内连接后大约几行？

@Option(id: "db-rel-dup-q1-four", correct: true) {
大约 4 行，每行订单都带上该会员字段

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
1×4 的配对。
}
}
@Option(id: "db-rel-dup-q1-one") {
一定只有 1 行
}
@Option(id: "db-rel-dup-q1-five") {
一定是 5 行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结果粒度跟着「多」的一侧走。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：把订单换成 1 行，连接结果是否变回 1 行？
}
}
