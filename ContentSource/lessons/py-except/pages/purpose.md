文件不存在、输入无法转成整数——这些你知道可能发生。若不管，程序会在爆点直接停。

**异常处理**让你在失败时执行另一段路：提示用户、跳过本条、写日志，而不是整段崩溃。

## 最小形态

```python
raw = input("分钟：")
try:
    minutes = int(raw)
except ValueError:
    print("请输入数字")
    minutes = 0
```

`try` 里放可能失败的步骤；`except ValueError` 只接住「值不对」这一类。

```text
尝试 int(raw)
  ↓ 成功 → 得到分钟
  ↓ 失败 ValueError → 提示并给默认
```

## 它解决什么

不是消灭所有 bug，而是：**对想得到的失败有预案**，让程序在坏输入下仍可被理解地继续或退出。

@Callout(title: "失败也可以有剧本", tone: "information", accent: "mint") {
`try/except` 为可预期失败准备 **另一条路**，避免只有崩溃这一种结局。
}

@Quiz(id: "py-except-purpose.quiz-1", kind: "singleChoice") {
用户输入「四十分」导致 int 失败。有 except ValueError 提示重试，主要价值是？

@Option(id: "py-except-purpose-q1-path", correct: true) {
把这次失败接住，给出可理解的出路，而不是直接甩出堆栈结束
}

@Option(id: "py-except-purpose-q1-syntax") {
让语法错误从此消失
}

@Option(id: "py-except-purpose-q1-hide-logic") {
保证逻辑错误也永远不会发生
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
针对运行时的可预期失败给预案。
}

@Feedback(when: "incorrect", title: "范围要收窄", tone: "warning", accent: "amber") {
它不修语法，也不自动保证业务逻辑正确。
}
}

@Quiz(id: "py-except-purpose.quiz-2", kind: "singleChoice") {
`try` 代码块里应该放什么？

@Option(id: "py-except-purpose-q2-risky", correct: true) {
可能失败、且你准备了应对策略的那几步
}

@Option(id: "py-except-purpose-q2-all") {
整个项目所有代码，越多越好
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
范围尽量小，只包住真正可能失败且你想处理的部分。
}

@Feedback(when: "incorrect", title: "别包进整个宇宙", tone: "warning", accent: "amber") {
包太大时，真实 bug 也会被糊弄过去。
}
}
