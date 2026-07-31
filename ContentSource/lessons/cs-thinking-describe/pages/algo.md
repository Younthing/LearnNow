步骤与控制结构齐了，就可以写成**算法**：一套解决某类问题的明确方法。

泡茶算法不是散文，而是别人按它做也能得到茶的描述。

## 算法要可执行

含糊词、缺条件、缺结束，都不算合格算法。它回答「怎么做」，不是「为什么泡茶有意义」。

```text
问题：泡一杯茶
算法：可逐步执行的解法描述
```

## 描述可以有两种面孔

同一种算法，可以用图画路径，也可以用类语言写步骤。下一页与再下一页分别练这两种。

@Callout(title: "算法是解法", tone: "information", accent: "purple") {
算法 = 针对问题的、可执行的明确步骤集合。
}

@Quiz(id: "cs-thinking-describe-algo.quiz-1", kind: "singleChoice") {
哪一段更接近算法，而不是感想？

@Option(id: "cs-thinking-describe-algo-q1-steps", correct: true) {
若水未开则继续加热；否则冲泡并端出

@Feedback(title: "可执行", tone: "success", accent: "mint") {
带条件与动作，别人能照做。
}
}

@Option(id: "cs-thinking-describe-algo-q1-feel") {
泡茶是一种生活美学，令人放松
}

@Option(id: "cs-thinking-describe-algo-q1-wish") {
希望茶自己变好
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
算法要能逐步执行，不是抒情。
}

@Feedback(when: "incorrect", title: "找动作与条件", tone: "warning", accent: "amber") {
读一句时问：执行者此刻该做什么？
}
}
