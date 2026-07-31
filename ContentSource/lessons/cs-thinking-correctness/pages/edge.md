正常例通过后，再测**边界**：刚好缺材料、水已经开、杯子本来就干净、重复零次等。

## 边界专打假设

算法若默认「总有茶叶」，在茶叶为 0 时会暴露漏洞。边界例子专门挑战隐含假设。

```text
边界例子
├─ 水量为 0
├─ 茶叶为 0
└─ 杯子已干净（清洗重复 0 次）
```

## 通过≠证明永远正确

例子能发现错误，不能穷尽所有情况。但系统设计里，一组好例子已经能挡住大量常见缺陷。

| 例子类型 | 作用 |
| --- | --- |
| 正常例 | 查主路径 |
| 边界例 | 查假设与出口 |
| 失败例 | 定位坏步骤 |

@Callout(title: "边界揭漏洞", tone: "information", accent: "mint") {
隐含「总是有…」的假设，最容易在边界例上翻车。
}

@Quiz(id: "cs-thinking-correctness-edge.quiz-1", kind: "singleChoice") {
清洗循环写着「洗一次」，却从未检查是否已干净。哪个例子最容易揭穿？

@Option(id: "cs-thinking-correctness-edge-q1-dirty", correct: true) {
杯子仍然很脏：只洗一次不够

@Feedback(title: "结束条件缺失", tone: "success", accent: "mint") {
边界/失败例逼你写出真正的退出条件。
}
}

@Option(id: "cs-thinking-correctness-edge-q1-poem") {
写一首赞美干净的诗
}

@Option(id: "cs-thinking-correctness-edge-q1-ignore") {
任何例子都揭不穿，因为写了「洗」字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
选会打破作者乐观假设的例子。
}

@Feedback(when: "incorrect", title: "找假设", tone: "warning", accent: "amber") {
问：作者默认一次就够吗？用「仍脏」去打。
}
}
