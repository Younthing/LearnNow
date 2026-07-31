程序结果不对时，先别盲目改。第一步：**稳定复现**，并观察相关变量的实际值。

## 复现是证据

同样输入每次都错，才好追踪。偶发错误更难，但仍要记下当时输入与步骤。

```text
固定输入
  ↓
再次运行
  ↓
记录 amount / count / total
```

## 观察当前状态

打印或检查 `price`、`count`、`total`。总价等于单价，常常一眼看出漏乘。

## 把现象写成一句话

「总价不对」太含糊。改成「price=10、count=3 时 total 变成 10」。可复现的描述本身就缩小了搜索范围。

现象写不清，后面的定位会在雾里打转。

@Callout(title: "先看见", tone: "information", accent: "purple") {
调试从可复现的现象与可见状态开始。
}

@Quiz(id: "cs-prog-debug-observe.quiz-1", kind: "singleChoice") {
只改了一行无关注释，错误「好像」消失又出现。更稳妥的下一步是？

@Option(id: "cs-prog-debug-observe-q1-repro", correct: true) {
固定同一组输入，反复运行并记录关键变量

@Feedback(title: "要证据", tone: "success", accent: "mint") {
没有稳定复现，定位只是猜测。
}
}

@Option(id: "cs-prog-debug-observe-q1-random") {
随机删除一半代码碰运气
}

@Option(id: "cs-prog-debug-observe-q1-ignore") {
宣布错误不存在，停止一切检查
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
复现 + 观察，是定位的前提。
}

@Feedback(when: "incorrect", title: "回到证据", tone: "warning", accent: "amber") {
先问：怎样再次看到同一个错误？
}
}
