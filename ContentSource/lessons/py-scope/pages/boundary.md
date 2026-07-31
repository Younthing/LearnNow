既然里面的名字出不去，数据该怎么过门？

已经学过的两扇门：**参数进、返回出**。靠同名「好像连着」最容易埋雷。

## 清楚的过门

```python
def add_day(total, n):
    return total + n

grand = 0
grand = add_day(grand, 40)
grand = add_day(grand, 15)
```

每次把当前合计与新分钟送进去，再接回新的合计。数据流可见。

```text
grand ──→ 参数 total
n ─────→ 参数 n
return ─→ 新的 grand
```

## 同名不等于同一个

函数外有 `minutes`，参数也叫 `minutes`，仍是两次绑定：调用时把外面的值拷送进参数这张局部标签。在里面改参数，不会自动改外面的变量（对不可变数字尤其明显）。

## 少用「伸手去外面改」

有强制改外层名字的写法，但本课建议：能参数/返回解决的，就不要让函数伸手改外屋。边界清楚，嵌套心智更轻。

@Callout(title: "进门出门写明白", tone: "information", accent: "mint") {
数据用参数进、用返回出；别靠同名碰运气。
}

@Quiz(id: "py-scope-boundary.quiz-1", kind: "singleChoice") {
为什么 `grand = add_day(grand, 40)` 这种写法边界更清楚？

@Option(id: "py-scope-boundary-q1-flow", correct: true) {
送进去什么、返回什么都写在调用处，数据流可见
}

@Option(id: "py-scope-boundary-q1-magic") {
因为同名变量会自动同步，不必 return
}

@Option(id: "py-scope-boundary-q1-fast") {
因为这样写循环会更快
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
看得见的进出处，比隐形共享更好维护。
}

@Feedback(when: "incorrect", title: "看赋值左边", tone: "warning", accent: "amber") {
grand 被重新赋成返回值——这正是「接住送出来的结果」。
}
}

@Quiz(id: "py-scope-boundary.quiz-2", kind: "singleChoice") {
函数内外都有名叫 `minutes` 的名字。据此可以断言它们是同一个变量吗？

@Option(id: "py-scope-boundary-q2-no", correct: true) {
不能。同名可以只是碰巧，范围不同就不是同一张标签
}

@Option(id: "py-scope-boundary-q2-yes") {
能。名字相同就一定是同一个
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
范围不同，名字只是字符串碰巧一样。
}

@Feedback(when: "incorrect", title: "想起小屋比喻", tone: "warning", accent: "amber") {
两间屋都可以有一张叫 minutes 的便签，仍是两张便签。
}
}
