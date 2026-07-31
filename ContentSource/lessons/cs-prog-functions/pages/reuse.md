函数定义一次，可在多处**调用**。改一处定义，所有调用受益——前提是行为真的应共享。

## 复用减少复制粘贴

三处都要算总价时，不要复制三段相同代码。调用三次同一函数，错误只需修一次。

```text
定义 calculate_total
├─ 调用处 A
├─ 调用处 B
└─ 调用处 C
```

## 复用的边界

若两处「看起来像」但规则将分叉，硬复用会把它们绑死。那时宁可拆成两个函数，或加参数表达差异。

## 相似不等于相同

两段代码有 80% 一样、但业务规则将分叉时，硬抽成一个函数会让参数爆炸或出现奇怪分支。

复用服务「同一份真相」；若真相将分裂，宁可先并列两个清晰函数。

@Callout(title: "定义一次", tone: "information", accent: "mint") {
共享的行为放进函数；分叉的行为不要强行绑在一起。
}

@Quiz(id: "cs-prog-functions-reuse.quiz-1", kind: "singleChoice") {
三处粘贴了同一段总价计算，后来公式改了却只改了一处。更好的预防是？

@Option(id: "cs-prog-functions-reuse-q1-fn", correct: true) {
抽成一个函数，三处都调用它

@Feedback(title: "单点修改", tone: "success", accent: "mint") {
共享逻辑集中存放，修改面更小。
}
}

@Option(id: "cs-prog-functions-reuse-q1-more") {
再粘贴两份，让错误版本更多
}

@Option(id: "cs-prog-functions-reuse-q1-never") {
永远禁止修改任何公式
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
复用的价值在「一处真相」。
}

@Feedback(when: "incorrect", title: "数修改点", tone: "warning", accent: "amber") {
同样逻辑出现几次，就有几次漏改风险。
}
}
