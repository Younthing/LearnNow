上一课：任务要走输入、处理、输出。这一课问更早的一步——信息为什么必须先**表示**出来。

手机不能直接保存「你心里的到了」。它只能保存可区分的状态：某个键被按下、某段存储亮或灭。

## 先有形式，才有处理

「到了」要变成屏幕上的字、发出去的数据，每一步都是把意义落成可操作的形式。

```text
想法「到了」
  ↓ 表示
可保存的形式（字符 / 编码）
  ↓ 进入
输入 → 处理 → 输出
```

## 可区分才算表示成功

若两种不同意思落成完全相同的状态，机器无法分开处理它们。表示的最低要求是：**不同信息对应可区分的状态**。

@Callout(title: "先落成形式", tone: "information", accent: "purple") {
机器处理的是表示出来的状态，不是未落地的想法。
}

@Quiz(id: "cs-info-why-store.quiz-1", kind: "singleChoice") {
你只在心里默念「到了」，没有打字也没有录音。手机为什么发不出去？

@Option(id: "cs-info-why-store-q1-form", correct: true) {
还没有落成机器可保存、可发送的形式

@Feedback(title: "没有形式就没有输入", tone: "success", accent: "mint") {
输入环节需要的是已表示的数据，不是意图本身。
}
}

@Option(id: "cs-info-why-store-q1-wifi") {
只因为当时没有信号，与表示无关
}

@Option(id: "cs-info-why-store-q1-mind") {
手机已经保存了你的想法，只是懒得发
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先表示，才能进入发送这条处理链。
}

@Feedback(when: "incorrect", title: "回到表示", tone: "warning", accent: "amber") {
问：机器此刻手里有没有任何可区分的输入状态？
}
}
