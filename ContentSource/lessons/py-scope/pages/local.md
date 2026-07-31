你在函数里算好了 `total`，出了函数想 `print(total)`，却被告知没有这个名字。

这不是程序坏了，而是 **作用范围**：名字默认只在被创建的那一层里看得见。

## 小屋里的标签

```python
def add_day(n):
    total = n
    return total

print(add_day(40))
# print(total)  # 这里通常会报错
```

`total` 贴在函数这间小屋里。小屋外没有这张标签，除非你用 `return` 把值送出来。

```text
函数内：total → 40
函数外：没有名为 total 的标签
```

## 参数也是小屋内的

参数名同样只在函数内绑定。调用处的变量名和参数名可以碰巧相同，也不等于同一个标签。

@Callout(title: "默认出不去", tone: "information", accent: "mint") {
函数里赋值的名字，外面 **不能直接** 当自己的变量用。
}

@Quiz(id: "py-scope-local.quiz-1", kind: "singleChoice") {
函数 `add_day` 内有 `total = n`，函数外直接 `print(total)`。按默认规则最可能？

@Option(id: "py-scope-local-q1-error", correct: true) {
外面找不到这个名字，容易报错
}

@Option(id: "py-scope-local-q1-auto") {
外面自动共享函数里的 total
}

@Option(id: "py-scope-local-q1-zero") {
外面的 total 一定是 0
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
局部名字默认关在函数里。要外面用，得 return。
}

@Feedback(when: "incorrect", title: "别假设自动共享", tone: "warning", accent: "amber") {
自检：把函数改名、再找外面的 total——它并没有被创建过。
}
}

@Quiz(id: "py-scope-local.quiz-2", kind: "singleChoice") {
怎样把函数里算出的合计交给外面使用？

@Option(id: "py-scope-local-q2-return", correct: true) {
用 return 送出值，在调用处赋值接收
}

@Option(id: "py-scope-local-q2-same-name") {
只要外面也写一个同名 total，就会自动连上
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
值可以通过返回穿越边界；名字本身默认不能。
}

@Feedback(when: "incorrect", title: "同名不是通道", tone: "warning", accent: "amber") {
两个 total 可能只是碰巧叫一样，不是同一张标签。
}
}
