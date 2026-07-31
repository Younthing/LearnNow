分类是为了决定下一步查什么。

## 快速归类

```text
还没跑 / 指出哪行写法？ → 语法
跑到某步炸，带异常名？ → 运行
一直跑完，数不对？     → 逻辑
```

## 运行错误的例子

`int("四十分")` 会在转换那一步失败：字符串长得不像整数。这不是语法缺冒号，也不是「静静算错」，而是运行时做不到。

## 对策方向（预告）

| 类型 | 下一步常做什么 |
| --- | --- |
| 语法 | 按提示补全结构 |
| 运行 | 读异常与行号（下课） |
| 逻辑 | 对照例子、写测试 |

@Callout(title: "先贴标签再修理", tone: "information", accent: "mint") {
同一句「程序坏了」可能是三种病；标签决定你打开哪一类工具。
}

@Quiz(id: "py-err-kinds-spot.quiz-1", kind: "singleChoice") {
运行到 `int(raw)` 时炸掉，提示无法转换。更像？

@Option(id: "py-err-kinds-spot-q1-runtime", correct: true) {
运行错误：这一步在当前数据下做不到
}

@Option(id: "py-err-kinds-spot-q1-syntax") {
语法错误：因为 int 拼写看起来像关键字问题
}

@Option(id: "py-err-kinds-spot-q1-logic-only") {
逻辑错误：既然炸掉就一定是公式写错
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
已经执行到该行并因数据失败，是运行时错误。
}

@Feedback(when: "incorrect", title: "看炸点", tone: "warning", accent: "amber") {
语法通常更早拦；逻辑常不炸。炸掉并点名转换失败 → 运行。
}
}

@Quiz(id: "py-err-kinds-spot.quiz-2", kind: "singleChoice") {
为什么要把逻辑错误单独列出来？

@Option(id: "py-err-kinds-spot-q2-silent", correct: true) {
因为它往往不报错，只能靠对照预期才能发现
}

@Option(id: "py-err-kinds-spot-q2-rare") {
因为它在 Python 里不可能出现
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
沉默是它的危险之处，也是测试存在的理由。
}

@Feedback(when: "incorrect", title: "它很常见", tone: "warning", accent: "amber") {
能跑但算错，日常开发里并不稀罕。
}
}
