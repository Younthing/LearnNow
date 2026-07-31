`is_done` 说「≥30 达标」。你怎么知道它没写反？

**测试**：准备输入，调用函数，看返回值是不是你预期的那一个。

## 最小用例表

| 输入 minutes | 预期 |
| --- | --- |
| 40 | True |
| 15 | False |
| 30 | True |

```python
assert is_done(40) is True
assert is_done(15) is False
assert is_done(30) is True
```

`assert` 在条件为假时会报错——把「我以为」变成可自动检查的句子。

```text
输入 → 函数 → 输出
              ↓
           和预期比
```

## 它抓的是逻辑错误

语法过了、也能跑，但把 `>=` 写成 `>` 时，30 会错。用例能把它抓出来。

@Callout(title: "把预期写下来", tone: "information", accent: "mint") {
测试 = **输入 + 预期输出**；让计算机替你反复核对。
}

@Quiz(id: "py-test-cases.quiz-1", kind: "singleChoice") {
为什么测试特别擅长抓逻辑错误？

@Option(id: "py-test-cases-q1-quiet", correct: true) {
因为逻辑错误常不报错，只能靠对照预期才能发现
}

@Option(id: "py-test-cases-q1-syntax") {
因为测试会自动修复所有语法错误
}

@Option(id: "py-test-cases-q1-replace") {
有了测试就再也不需要阅读代码
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
沉默的错误，要用预期去撞。
}

@Feedback(when: "incorrect", title: "测试不是万能修补", tone: "warning", accent: "amber") {
它暴露偏离预期；不代替思考，也不自动修语法。
}
}

@Quiz(id: "py-test-cases.quiz-2", kind: "singleChoice") {
`assert is_done(15) is False` 在做什么？

@Option(id: "py-test-cases-q2-check", correct: true) {
检查函数对输入 15 的返回是否确实为 False
}

@Option(id: "py-test-cases-q2-assign") {
把 is_done 永久改成永远返回 False
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
断言是核对，不是改写函数定义。
}

@Feedback(when: "incorrect", title: "assert 是检查", tone: "warning", accent: "amber") {
它在问「是不是」，不是在重新定义函数。
}
}
