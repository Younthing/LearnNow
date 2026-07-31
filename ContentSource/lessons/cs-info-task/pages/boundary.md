程序是步骤清单，硬件负责执行。边界要钉死：硬件**不会理解意图**，它只按清单一步步做。

## 执行不等于理解

你想算小费，却按成了折扣。机器忠实执行你按下去的步骤，不会纠正「你真正想要什么」。

```text
你的意图   算小费
    ↓（若清单写错）
机器执行   按折扣算
    ↓
屏幕输出   一个「正确执行」的错结果
```

## 出错时改哪里

输入错了，改输入；清单错了，改程序；显示坏了，才查硬件。多数「电脑好笨」其实是清单与意图不一致。

| 现象 | 先查 | 不先查 |
| --- | --- | --- |
| 数字按错 | 输入 | 程序逻辑 |
| 规则写反 | 程序 | 屏幕 |
| 屏不亮 | 硬件 | 算法 |

@Callout(title: "忠实执行", tone: "warning", accent: "amber") {
硬件保证的是**按清单做**，不是替你保证清单符合意图。
}

@Quiz(id: "cs-info-task-boundary.quiz-1", kind: "singleChoice") {
导航按清单走到了错误目的地，路线步骤却逐步执行成功。最合理的解释是？

@Option(id: "cs-info-task-boundary-q1-list", correct: true) {
清单里的目的地或规则与真实意图不一致

@Feedback(title: "执行成功≠意图达成", tone: "success", accent: "mint") {
机器可以「正确地」完成一份错误清单。
}
}

@Option(id: "cs-info-task-boundary-q1-think") {
芯片突然开始自己思考，故意带错路
}

@Option(id: "cs-info-task-boundary-q1-ignore") {
硬件故意忽略了清单里写明的步骤
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先核对清单是否表达了意图，再怀疑硬件失灵。
}

@Feedback(when: "incorrect", title: "回到边界", tone: "warning", accent: "amber") {
硬件默认忠实执行；执行成功却结果不对，优先怀疑清单内容。
}
}
