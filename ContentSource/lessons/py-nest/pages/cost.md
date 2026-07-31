你已经会循环，也会分支。把它们叠在一起时，程序容易突然变难读——不是 Python 坏了，是 **你要同时跟踪的事情变多了**。

## 一个仍算简单的嵌套

```python
for m in minutes_list:
    if m > 0:
        if m >= 30:
            print("达标", m)
        else:
            print("未达标", m)
```

外层记住「当前是哪一天的分钟」，内层再记住「是否 >0」「是否 ≥30」。

```text
外层：今天的 m
  └─ 内层：m 是否 > 0
       └─ 再内层：是否达标
```

## 为什么容易乱

读代码时，你要在脑子里摆多张便签：当前元素、当前分支、是否还在循环中。嵌套越深，便签越多，漏看一层就理解错。

## 能跑不等于好改

嵌套很深的代码常常能给出正确结果，但改一个条件时，你不确定影响的是哪一层。复杂来自 **结构**，不只来自业务。

@Callout(title: "难在同时记住", tone: "information", accent: "mint") {
嵌套的代价是：每一层都多一份要同时跟踪的状态。
}

@Quiz(id: "py-nest-cost.quiz-1", kind: "singleChoice") {
读上面的三层结构时，你至少要同时搞清哪些事？

@Option(id: "py-nest-cost-q1-both", correct: true) {
当前循环到哪个 m，以及此刻走到了哪条 if 分支
}

@Option(id: "py-nest-cost-q1-only-m") {
只需要知道 m 的数值，分支可以忽略
}

@Option(id: "py-nest-cost-q1-none") {
什么都不用记，嵌套会自动解释自己
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
循环变量和分支位置都要在脑子里对齐，这正是负荷来源。
}

@Feedback(when: "incorrect", title: "试着出声跟踪一轮", tone: "warning", accent: "amber") {
选一个 m=20，说出你进了哪层、会打印什么。你会发现要报两到三件事。
}
}

@Quiz(id: "py-nest-cost.quiz-2", kind: "singleChoice") {
为什么说「能跑」仍可能「难改」？

@Option(id: "py-nest-cost-q2-structure", correct: true) {
因为嵌套深时，改一处条件不容易看清影响哪一层
}

@Option(id: "py-nest-cost-q2-python") {
因为 Python 不允许修改嵌套代码
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
结构复杂会放大修改风险，即使当前结果是对的。
}

@Feedback(when: "incorrect", title: "想的是人读代码", tone: "warning", accent: "amber") {
语言允许你改；难的是人确定改对了哪一层。
}
}
