协作模型一旦清楚，排错就有方向：想改变行为，先决定改程序、改数据，还是查硬件。

## 改哪里

| 你想要的变化 | 优先改 | 例子 |
| --- | --- | --- |
| 换运算规则 | 程序 | 加法改乘法 |
| 换具体数值 | 数据 | 26 改 40 |
| 设备无响应 | 硬件/供电 | 屏不亮 |

```text
行为不对
  ↓
规则错？ → 改程序
数值错？ → 改数据
装置失灵？ → 查硬件
```

## 单元收口

计算机表示信息（落成比特 + 约定），再由程序驱动硬件一步步处理数据。整门课的主问题——计算机怎样表示信息并执行程序——在这一单元收成这条协作链。

@Callout(title: "对症修改", tone: "warning", accent: "amber") {
行为不对时，先判断该动程序、数据，还是硬件。
}

@Quiz(id: "cs-info-together-change.quiz-1", kind: "singleChoice") {
计算结果一直用错公式，输入数字却每次都核对无误。你该先改什么？

@Option(id: "cs-info-together-change-q1-prog", correct: true) {
改程序里的处理步骤

@Feedback(title: "规则在程序里", tone: "success", accent: "mint") {
数据无误而规则错，动清单。
}
}

@Option(id: "cs-info-together-change-q1-data") {
只改输入数字，公式会自己变对
}

@Option(id: "cs-info-together-change-q1-case") {
换手机壳以改变运算定义
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
三角色分工让排错有优先级。
}

@Feedback(when: "incorrect", title: "对表选择", tone: "warning", accent: "amber") {
输入已核对 → 数据侧嫌疑低；规则错 → 程序侧。
}
}
