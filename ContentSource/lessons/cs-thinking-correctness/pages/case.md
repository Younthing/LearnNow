算法写完，怎样知道它对？最朴素也最有效的方法：拿具体例子**逐步走一遍**。

## 追踪比默念强

输入：一杯冷水、一份茶叶。按伪代码逐步模拟，看输出是否是泡好的茶。某步对不上，问题就在附近。

```text
输入例子
  ↓ 逐步执行算法
对照预期输出
  ↓
一致 → 这一例通过
```

## 选有代表性的正常例

先测「普通情况」：水会开、材料齐全。连正常例都过不了，先别急着谈极端。

## 追踪要留下痕迹

每一步在纸上写：输入是什么、输出是什么。只在脑子里滑过去，失败时很难回放。

短算法也值得写三行追踪；它会告诉你断在哪一步。

@Callout(title: "例子当检验", tone: "information", accent: "purple") {
正确性先靠可追踪的例子说话，不靠感觉。
}

@Quiz(id: "cs-thinking-correctness-case.quiz-1", kind: "singleChoice") {
算法声称能泡茶。你只读了一遍文字就宣布正确。按这一页，缺了什么？

@Option(id: "cs-thinking-correctness-case-q1-trace", correct: true) {
缺少用具体输入逐步追踪并对照输出

@Feedback(title: "读过≠验证过", tone: "success", accent: "mint") {
验证要走例子，不是只朗读。
}
}

@Option(id: "cs-thinking-correctness-case-q1-long") {
文字越长就一定越正确
}

@Option(id: "cs-thinking-correctness-case-q1-skip") {
算法不需要任何检验
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
至少用一个正常例子走完一遍。
}

@Feedback(when: "incorrect", title: "动手追踪", tone: "warning", accent: "amber") {
选一组输入，逐步写下每步结果，再看最终输出。
}
}
