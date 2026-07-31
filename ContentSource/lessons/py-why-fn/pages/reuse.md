函数的第二层价值在 **复用**：多处调用同一套步骤，修改时只改定义处。

## 复制粘贴的对照

| 做法 | 改「达标」措辞时 |
| --- | --- |
| 粘贴三段相同 if | 要找齐三处一起改 |
| 一个函数三处调用 | 只改函数里那一处 |

行为来源集中，漏改的风险下降。

## 调用可以很多次

```text
print_status(40)
print_status(15)
print_status(30)
```

三次调用，同一套规则。分钟不同，步骤相同——这正是参数要上场的地方（下一课），但复用的形状已经清楚。

## 什么时候该装进函数

同一套逻辑出现第二次，就要考虑装箱。为「以后可能用到」而空造许多一次性函数，反而添乱。

@Callout(title: "一处定义，多处调用", tone: "information", accent: "mint") {
复用的关键是：改规则时，你知道 **唯一** 该改的地方在哪。
}

@Quiz(id: "py-why-fn-reuse.quiz-1", kind: "singleChoice") {
三处都调用 `print_status`。你想把「达标」改成「今日达标」。最省事且不易漏的改法是？

@Option(id: "py-why-fn-reuse-q1-def", correct: true) {
只改函数定义里的那句 print
}

@Option(id: "py-why-fn-reuse-q1-calls") {
把三处调用都删掉重写三遍 if
}

@Option(id: "py-why-fn-reuse-q1-rename-file") {
把文件名改成 status.py
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
定义是行为来源；调用只是触发。
}

@Feedback(when: "incorrect", title: "找行为写在哪", tone: "warning", accent: "amber") {
打印那句话在函数体里。改那里，所有调用一起变。
}
}

@Quiz(id: "py-why-fn-reuse.quiz-2", kind: "singleChoice") {
一段逻辑只在整个程序出现一次，而且很短。是否必须做成函数？

@Option(id: "py-why-fn-reuse-q2-no", correct: true) {
不必。函数服务于命名与复用；没有第二次出现时，直接写也常更清楚
}

@Option(id: "py-why-fn-reuse-q2-must") {
必须。没有函数的程序无法运行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
工具为问题服务。没有复用压力时，强行装箱可能只是多一层跳转。
}

@Feedback(when: "incorrect", title: "回忆程序怎样运行", tone: "warning", accent: "amber") {
没有函数照样能跑。函数解决的是组织问题。
}
}
