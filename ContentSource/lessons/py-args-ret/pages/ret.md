有时你不只想打印，还想在调用处根据结果再做别的事：记入列表、再分支、再调用别的函数。

这时需要 **返回值**：用 `return` 把结果送回调用处。

## 计算与显示分开

```python
def is_done(minutes):
    return minutes >= 30

ok = is_done(40)
if ok:
    print("达标")
```

`is_done` 负责判断并 **送回** True/False；要不要打印，由调用处决定。

```text
送入 minutes
  ↓
函数算出 True/False
  ↓ return
调用处用 ok 接着做事
```

## print 不是 return

`print` 把字送上屏幕，调用处拿不到那个值再计算。`return` 把值交回程序。两者常一起用，但职责不同。

## 没有 return 时

函数跑完会默认带回 `None`。若你指望拿到 True/False 却忘了 return，后面的判断会不对。

@Callout(title: "给人看 vs 给程序用", tone: "information", accent: "mint") {
`print` 给人看；`return` 把结果 **交回** 调用处继续用。
}

@Quiz(id: "py-args-ret-ret.quiz-1", kind: "singleChoice") {
`ok = is_done(40)` 之后，`ok` 里更可能是？

@Option(id: "py-args-ret-ret-q1-true", correct: true) {
True，因为函数 return 了比较结果
}

@Option(id: "py-args-ret-ret-q1-print") {
屏幕上的那句「达标」文字
}

@Option(id: "py-args-ret-ret-q1-40") {
40，因为参数是 40
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
赋值接到的是 return 送回的值。
}

@Feedback(when: "incorrect", title: "看 return 那一行", tone: "warning", accent: "amber") {
is_done 返回的是 minutes >= 30 的布尔结果，不是参数本身，也不是 print 的字。
}
}

@Quiz(id: "py-args-ret-ret.quiz-2", kind: "singleChoice") {
函数里只写了 `print(minutes >= 30)`，没有 return。调用处写 `ok = is_done(40)` 想拿布尔值，会发生什么？

@Option(id: "py-args-ret-ret-q2-none", correct: true) {
屏幕可能看到 True/False，但 ok 通常拿不到有用的布尔返回值（常是 None）
}

@Option(id: "py-args-ret-ret-q2-same") {
ok 一定等于 True，因为打印出来了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
打印和返回是两条路。要赋值使用，得 return。
}

@Feedback(when: "incorrect", title: "分开屏幕和变量", tone: "warning", accent: "amber") {
看见打印不等于变量收到了返回值。
}
}
