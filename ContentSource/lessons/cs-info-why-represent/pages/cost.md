没有表示，就没有可进入处理链的对象。这不是文风问题，是能力边界。

## 处理针对表示

比较、复制、加密、发送——每一步操作的都是已表示的数据。未表示的想法不在这条链上。

```text
未表示的想法  ✕  无法输入
已表示的数据  →  可复制 / 可比较 / 可发送
```

## 表示有代价，也换来能力

表示要占用存储、要统一约定。换来的是：同一条消息能转发、能检索、能被程序处理。

下一课会把文字、图片、声音都落到同一种底层形式：二进制。

@Callout(title: "无表示则无计算", tone: "information", accent: "mint") {
计算作用在表示上；没有表示，程序无事可做。
}

@Quiz(id: "cs-info-why-cost.quiz-1", kind: "singleChoice") {
要把「到了」自动翻译成另一种语言，程序第一步必须具备什么？

@Option(id: "cs-info-why-cost-q1-repr", correct: true) {
先有这段文字的可处理表示（例如字符序列）

@Feedback(title: "先有操作对象", tone: "success", accent: "mint") {
翻译算法作用在表示上，不能作用在未落地的想法上。
}
}

@Option(id: "cs-info-why-cost-q1-feel") {
只要程序「体会」原意，不必出现任何文字形式
}

@Option(id: "cs-info-why-cost-q1-screen") {
只要屏幕亮着，不必保存任何数据
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
处理链的入口永远是已表示的数据。
}

@Feedback(when: "incorrect", title: "找入口", tone: "warning", accent: "amber") {
问：算法的输入参数此刻是什么？若答不上来，就还缺表示。
}
}
