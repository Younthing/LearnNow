`print_status` 要判断不同的分钟数。若函数体内写死 `40`，就无法复用。

**参数**是入口：调用时把具体值送进去，函数体内用参数名去引用它。

## 入口长什么样

```python
def print_status(minutes):
    if minutes >= 30:
        print("达标")
    else:
        print("未达标")

print_status(40)  # 这一次 minutes 是 40
print_status(15)  # 这一次 minutes 是 15
```

括号里定义的是「需要一个叫 minutes 的输入」；调用括号里是「这一次送进的值」。

```text
调用处 40 ──送入──→ 参数 minutes
```

## 每次调用可以不同

参数让同一套步骤处理不同数据。没有参数，函数只能靠全局里碰巧存在的变量，复用会变脆。

@Callout(title: "参数是入口", tone: "information", accent: "mint") {
调用时送值，函数内用参数名接住——这是数据进入函数的正门。
}

@Quiz(id: "py-args-ret-args.quiz-1", kind: "singleChoice") {
`print_status(15)` 执行时，函数里的 `minutes` 此刻是？

@Option(id: "py-args-ret-args-q1-15", correct: true) {
15，因为这次调用送入的是 15
}

@Option(id: "py-args-ret-args-q1-40") {
40，因为例子里曾经用过 40
}

@Option(id: "py-args-ret-args-q1-name") {
字符串 "minutes"
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
参数绑定的是这一次调用送入的值。
}

@Feedback(when: "incorrect", title: "看这一次括号里是谁", tone: "warning", accent: "amber") {
每次调用单独送值。看当前那一次括号里写的是什么。
}
}

@Quiz(id: "py-args-ret-args.quiz-2", kind: "singleChoice") {
为什么要把分钟做成参数，而不是在函数里写死？

@Option(id: "py-args-ret-args-q2-vary", correct: true) {
这样同一套步骤才能处理不同的分钟数
}

@Option(id: "py-args-ret-args-q2-syntax") {
因为 Python 规定函数必须有参数才能定义
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
参数服务于「同步骤、不同数据」。
}

@Feedback(when: "incorrect", title: "可以没有参数", tone: "warning", accent: "amber") {
无参函数合法。这里要参数，是因为数据会变。
}
}
