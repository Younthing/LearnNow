流程图用框与箭头画出路径，特别适合看清**分支与回路**。

## 框表示动作或判断

动作框写「烧水」；判断框写「水开了？」；箭头指出下一步。

```text
开始
  ↓
烧水
  ↓
水开？──否──→ 回到烧水
  │
 是
  ↓
冲泡 → 结束
```

## 图适合发现错路

漏掉「否」的回边、箭头指错，在图上一眼能看出来。复杂分支时，先画图再写语句往往更稳。

## 开始与结束也要画

流程图漏画「开始/结束」时，读者不知道入口与收口。判断框的每个出口都要有去处，循环回边要指回真正的检查点。

图的价值是暴露缺口；缺口被箭头藏起来就失去意义。

@Callout(title: "图看路径", tone: "information", accent: "mint") {
流程图的强项是让分支与循环的路径可见。
}

@Quiz(id: "cs-thinking-describe-flow.quiz-1", kind: "singleChoice") {
判断「水开了？」只有「是」的箭头，没有「否」。按流程图检查，问题是？

@Option(id: "cs-thinking-describe-flow-q1-missing", correct: true) {
未开时的路径缺失，算法不完整

@Feedback(title: "分支要齐全", tone: "success", accent: "mint") {
每个判断出口都要有去处。
}
}

@Option(id: "cs-thinking-describe-flow-q1-art") {
图越少箭头越高级
}

@Option(id: "cs-thinking-describe-flow-q1-auto") {
「否」会自动指向结束，不必画出
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
画图就是为了暴露缺口。
}

@Feedback(when: "incorrect", title: "数出口", tone: "warning", accent: "amber") {
每个判断框数一下：是否所有答案都有箭头。
}
}
