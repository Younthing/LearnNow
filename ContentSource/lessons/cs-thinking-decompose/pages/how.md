拆到什么粒度？标准是：每一步都能**单独完成**，并且完成时能看出有没有做完。

## 可单独完成

「准备泡茶材料」仍可能太大。再拆成：取杯子、取茶叶、确认水量。每一步有清晰的完成态。

```text
泡一杯茶
├─ 烧水至沸腾
├─ 放入茶叶
├─ 注入热水
└─ 端到桌上
```

## 保持同一目标

拆出来的步骤必须仍服务于同一个目标。跑题的步骤再清楚，也不属于这次分解。

| 步骤 | 属于泡茶吗 | 原因 |
| --- | --- | --- |
| 烧水 | 是 | 直接需要 |
| 给朋友发短信 | 否 | 离开主目标 |
| 放茶叶 | 是 | 直接需要 |

@Callout(title: "拆到可完成", tone: "information", accent: "mint") {
一步做完要能判断「做完了」；否则继续拆。
}

@Quiz(id: "cs-thinking-decompose-how.quiz-1", kind: "singleChoice") {
步骤写成「处理好一切」。按这一页的粒度标准，问题是什么？

@Option(id: "cs-thinking-decompose-how-q1-big", correct: true) {
粒度太大，完成标准不清，无法单独验收

@Feedback(title: "无法验收就不算明确", tone: "success", accent: "mint") {
把「一切」换成可观察的具体动作。
}
}

@Option(id: "cs-thinking-decompose-how-q1-fine") {
已经够细，因为用了「处理」这个词
}

@Option(id: "cs-thinking-decompose-how-q1-hw") {
必须写成电路图才算步骤
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
明确步骤要能单独做完并检查。
}

@Feedback(when: "incorrect", title: "验收测试", tone: "warning", accent: "amber") {
问：做完这一步时，我能指出哪个可见变化吗？
}
}
