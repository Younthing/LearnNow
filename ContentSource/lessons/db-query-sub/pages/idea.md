有时条件本身要靠另一次查询才能得到。例如：「积分高于全店平均分的会员」。平均分要先算出来，再拿去比较——这就是**子查询**的用武之地：查询里面再嵌一套查询。

## 先看形状

```text
外层：选出会员
条件：积分 > (内层算出的平均积分)
```

内层先（或逻辑上先）得到一个值或一张小结果表；外层拿它当条件或来源。

## 它不是新语言

子查询仍是 SELECT；只是出现在另一句 SQL 的括号里，扮演「临时算出来的值/集合」。

@Callout(title: "子查询＝嵌在里面的提问", tone: "information", accent: "amber") {
先求出中间答案，再问最终问题。
}

@Quiz(id: "db-query-sub.quiz-1", kind: "singleChoice") {
「积分高于平均」为什么适合想到子查询？

@Option(id: "db-query-sub-q1-mid", correct: true) {
平均分是中间结果，需要先算出来再用于筛选

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
中间问题嵌在最终问题里。
}
}
@Option(id: "db-query-sub-q1-insert") {
因为必须插入新表才能比较
}
@Option(id: "db-query-sub-q1-drop") {
因为必须先删掉低于平均的人
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
中间值驱动外层条件。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：平均分是否已作为一列存在于每一行？通常否，所以要现算。
}
}
