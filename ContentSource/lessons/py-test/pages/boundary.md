只测 `40→True` 不够。边界常常是写错比较符的地方。

## 边界是什么

对「≥30」来说，`30` 正好在门槛上：预期 True。`29` 则应 False。这两条比再测一个 `100` 更能钉死规则。

```text
29 → False
30 → True   ← 门槛
31 → True
```

## 反例与奇怪输入

若函数还应拒绝负数，就加一条「-1 应怎样」的用例。测试列表要 **代表性**：典型成功、典型失败、门槛、特殊值。

## 可重复

把用例写进文件，改代码后再跑一遍。人肉每次手点输入，容易漏；自动化让回归更稳。

@Callout(title: "门槛最容易写错", tone: "information", accent: "mint") {
测边界（刚好达标 / 差一分）往往比再堆一个普通例子更值。
}

@Quiz(id: "py-test-boundary.quiz-1", kind: "singleChoice") {
规则是 ≥30 达标。哪组用例更能钉死比较符有没有写错？

@Option(id: "py-test-boundary-q1-edge", correct: true) {
包含 29→False 与 30→True
}

@Option(id: "py-test-boundary-q1-only-big") {
只测 100→True
}

@Option(id: "py-test-boundary-q1-none") {
完全不需要测试 30，因为边界不重要
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
`>` 与 `>=` 的差别，正好死在 30 这扇门上。
}

@Feedback(when: "incorrect", title: "想比较符", tone: "warning", accent: "amber") {
只测一个很大的数，两种写法都可能碰巧通过。
}
}

@Quiz(id: "py-test-boundary.quiz-2", kind: "singleChoice") {
为什么要把测试写成可重复跑的形式？

@Option(id: "py-test-boundary-q2-reg", correct: true) {
改代码后能快速确认旧行为没有被弄坏
}

@Option(id: "py-test-boundary-q2-once") {
每个测试只允许人生跑一次
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
回归检查是自动化的核心收益之一。
}

@Feedback(when: "incorrect", title: "重复是优点", tone: "warning", accent: "amber") {
测试就是为了能反复跑。
}
}
