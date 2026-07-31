「根据分钟打印是否达标」这几行，你可能在程序里写了三次。读的人要核对三遍是不是同一套逻辑。

**函数**做一件事：把一套步骤装进一个名字里。需要时叫这个名字，就执行那套步骤。

## 先定义，再调用

```python
def print_status(minutes):
    if minutes >= 30:
        print("达标")
    else:
        print("未达标")

print_status(40)
print_status(15)
```

`def` 那一段是在 **定义**（装箱）；后面两行是在 **调用**（使用）。

```text
定义：把步骤装进 print_status
  ↓
调用：print_status(40) → 执行箱子里的步骤
```

## 名字应说清它做什么

`print_status` 比 `f1` 更容易让调用处自解释。函数名是给人读的压缩说明。

@Callout(title: "先装箱，再使用", tone: "information", accent: "mint") {
函数 = **有名字的一套步骤**；调用名字，就执行那套步骤。
}

@Quiz(id: "py-why-fn-pack.quiz-1", kind: "singleChoice") {
只写了 `def print_status(...): ...`，还没有任何调用。运行到文件末尾时，达标判断会执行吗？

@Option(id: "py-why-fn-pack-q1-no", correct: true) {
通常不会。定义本身只是装箱，不会自动执行箱子里的步骤
}

@Option(id: "py-why-fn-pack-q1-yes") {
会。有 def 就等于已经运行了一次
}

@Option(id: "py-why-fn-pack-q1-twice") {
会运行两遍，因为 if/else 有两支
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
定义和调用是两步。没有调用，箱子只是放在那里。
}

@Feedback(when: "incorrect", title: "找有没有调用行", tone: "warning", accent: "amber") {
自检：文件里有没有 `print_status(...)` 这种调用？没有就不会跑进函数体。
}
}

@Quiz(id: "py-why-fn-pack.quiz-2", kind: "singleChoice") {
把达标判断做成函数，最直接的好处接近哪句？

@Option(id: "py-why-fn-pack-q2-name", correct: true) {
给一套步骤起名，调用处读起来像在说要做什么
}

@Option(id: "py-why-fn-pack-q2-faster") {
函数会让 Python 解释器永久加速
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
命名与组织是第一收益；速度不是这一课的重点。
}

@Feedback(when: "incorrect", title: "先看可读与结构", tone: "warning", accent: "amber") {
本课关心的是步骤能否被命名和复用，不是性能神话。
}
}
