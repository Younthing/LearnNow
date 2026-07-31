今日学习程序「坏了」时，先问：它是写不成、跑到一半炸，还是能跑但数不对？

三类常见错误画像不同。

## 三张脸

| 类型 | 你看到的 | 本质 |
| --- | --- | --- |
| 语法错误 | 还没好好跑起来就指出写法不对 | 句子不合 Python 语法 |
| 运行错误 | 跑到某行停下并报异常 | 那一步在当前数据下做不到 |
| 逻辑错误 | 不报错，但结果不对 | 步骤写错了意思 |

```text
语法   → 进门前被拦住
运行   → 进门后某步摔倒
逻辑   → 走完全程，但走错地方
```

## 逻辑错误最会骗人

因为它不响。合计少加一天，程序仍安静打印一个数——看起来「成功」。所以还需要对照预期（后面测试课）。

@Callout(title: "不报错也可能错", tone: "warning", accent: "amber") {
逻辑错误常常 **沉默**；能跑完不等于算对。
}

@Quiz(id: "py-err-kinds-three.quiz-1", kind: "singleChoice") {
少写了冒号，解释器直接指出语法问题、程序没开始干活。这更像？

@Option(id: "py-err-kinds-three-q1-syntax", correct: true) {
语法错误
}

@Option(id: "py-err-kinds-three-q1-logic") {
逻辑错误，因为结果不对
}

@Option(id: "py-err-kinds-three-q1-ok") {
根本不是错误
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
写都写不合规，属于语法层。
}

@Feedback(when: "incorrect", title: "看它有没有开跑", tone: "warning", accent: "amber") {
还没执行业务步骤就被拦住，先归到语法。
}
}

@Quiz(id: "py-err-kinds-three.quiz-2", kind: "singleChoice") {
程序安静打印合计 70，但你手算明明是 90。这更像？

@Option(id: "py-err-kinds-three-q2-logic", correct: true) {
逻辑错误：能跑，但步骤或公式不对
}

@Option(id: "py-err-kinds-three-q2-syntax") {
语法错误：因为数字不对就必须是语法问题
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
沉默的错误结果，是逻辑错误的典型。
}

@Feedback(when: "incorrect", title: "语法通常会早早拦住你", tone: "warning", accent: "amber") {
已经跑完并打印，说明多半过了语法关。
}
}
