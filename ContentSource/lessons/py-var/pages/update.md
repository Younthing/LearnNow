`minutes` 已经贴在 `40` 上。下午你又学了一会儿，想改成 `55`——变量怎么办？

再写一次赋值。**同一个名字**可以改贴到新值上；之后再用这个名字，取到的是新值。

## 标签搬家

```python
minutes = 40
print(minutes)
minutes = 55
print(minutes)
```

两次打印，先 `40` 后 `55`。不是两个 minutes 并存，而是标签从旧值改贴到新值。

```text
第一次   minutes → 40
第二次   minutes → 55
```

## 用的是「现在」贴着的

中间如果还有计算，它用的是执行到那一行时，名字正贴着的值。后赋值影响的是后面的步骤，不会自动改写已经 print 出去的旧结果。

## 常见误解

有人以为再赋值会「累加」或「留下历史」。默认不是。`minutes = 55` 就是改指向；若要累加，得明确写成用旧值算出新值再贴回去。

@Callout(title: "后写的赋值算数", tone: "information", accent: "mint") {
同一名字再赋值，标签改贴；之后取到的是 **最新** 指向。
}

@Quiz(id: "py-var-update.quiz-1", kind: "singleChoice") {
依次执行 `minutes = 40`，再 `minutes = 55`，再 `print(minutes)`。屏幕上是？

@Option(id: "py-var-update-q1-55", correct: true) {
55，因为标签最后贴在 55 上
}

@Option(id: "py-var-update-q1-40") {
40，因为第一次赋值优先级更高
}

@Option(id: "py-var-update-q1-95") {
95，因为两次赋值会自动加起来
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
再赋值改的是指向。print 时看的是当前指向。
}

@Feedback(when: "incorrect", title: "画两次箭头", tone: "warning", accent: "amber") {
在纸上写：minutes 先指向 40，再改指向 55。print 读的是改完之后的箭头。
}
}

@Quiz(id: "py-var-update.quiz-2", kind: "singleChoice") {
`minutes = 40` 后先 `print(minutes)`，再改成 `55`。已经打印出去的那一行会不会自动变成 55？

@Option(id: "py-var-update-q2-no", correct: true) {
不会。已输出的内容不会因为后来改变量而改写
}

@Option(id: "py-var-update-q2-yes") {
会。变量一变，以前的输出全部自动更新
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
print 当时取的是当时的值；后来改标签，只影响之后的步骤。
}

@Feedback(when: "incorrect", title: "输出已经离开程序", tone: "warning", accent: "amber") {
屏幕上那行字是当时送出去的快照，不是还连着变量的活窗口。
}
}
