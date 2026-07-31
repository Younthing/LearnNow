程序变长后，同一段逻辑会反复出现。**函数**把一组步骤打成有名字的包裹，主流程只写「做这件事」。

## 降低同时要盯的细节

计算总价的乘法与校验可以封进 `calculate_total`。读主流程时，先看调用，需要时再进包裹内部。

```text
主流程
  ↓ 调用
calculate_total
  ├─ 乘法
  └─ 校验
```

## 复杂度从「全展开」变成「分层」

不是魔法变少工作量，而是把细节藏进下一层，当前层更短、更可读。

## 名字要说出做什么

`calculate_total` 比 `doStuff` 更有助于分层阅读。名字含糊，封装就只是把混乱换了个房间。

打包之前先能用一句话说明这个函数的职责边界。

@Callout(title: "打包降噪", tone: "information", accent: "purple") {
函数让你一次只关注一层：先看名字，再看内部。
}

@Quiz(id: "cs-prog-functions-pack.quiz-1", kind: "singleChoice") {
主流程里写 `calculate_total(...)` 而不是展开全部乘法细节。主要收益是？

@Option(id: "cs-prog-functions-pack-q1-focus", correct: true) {
当前层更短，细节被放到函数内部

@Feedback(title: "分层阅读", tone: "success", accent: "mint") {
复杂度被组织起来，而不是消失。
}
}

@Option(id: "cs-prog-functions-pack-q1-delete") {
计算机从此禁止一切乘法
}

@Option(id: "cs-prog-functions-pack-q1-hw") {
函数会替换掉 CPU
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
打包是为了控制注意力与重复。
}

@Feedback(when: "incorrect", title: "想分层", tone: "warning", accent: "amber") {
问：此刻阅读主流程时，哪些细节可以稍后打开？
}
}
