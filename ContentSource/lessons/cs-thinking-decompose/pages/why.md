上一单元：机器按清单执行。这一单元问：清单从哪来？先从把问题**拆成明确步骤**开始。

「把茶泡好」太模糊。机器（或另一个人）需要知道先做什么、再做什么。

## 模糊句没法逐步做

没有顺序、没有完成标准，执行者只能猜。猜测一多，结果就不稳定。

```text
模糊：把茶泡好
  ↓ 拆开
明确：烧水 → 放茶叶 → 冲泡 → 端出
```

## 明确步骤服务执行

拆解的目的不是写得好看，而是让每一步都能被完成并检查。计算思维的第一步，常常是把大问题变成一串小问题。

@Callout(title: "先拆再做", tone: "information", accent: "purple") {
不能逐步执行的目标，先拆，再谈对错。
}

@Quiz(id: "cs-thinking-decompose-why.quiz-1", kind: "singleChoice") {
任务写成「把房间弄整齐」。按这一页，它主要缺什么？

@Option(id: "cs-thinking-decompose-why-q1-steps", correct: true) {
缺少可逐步执行的明确动作与顺序

@Feedback(title: "目标≠步骤", tone: "success", accent: "mint") {
「整齐」是结果描述，还不是步骤清单。
}
}

@Option(id: "cs-thinking-decompose-why-q1-chip") {
缺少一块更贵的芯片
}

@Option(id: "cs-thinking-decompose-why-q1-done") {
已经足够明确，任何人都会做出同一套动作
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先补步骤，再谈执行质量。
}

@Feedback(when: "incorrect", title: "能否逐步做", tone: "warning", accent: "amber") {
问：下一步具体动作是什么？答不上来就还没拆好。
}
}
