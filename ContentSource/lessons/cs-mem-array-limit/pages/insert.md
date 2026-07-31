数组连续存放，按下标很快。但在**中间插入**一格时，后面的元素往往要整体后移，腾出空位。

## 搬家成本

`[6000, 7500, 5000]` 要在开头插入 `4000`，原来的三格都可能挪动。

```text
插入前  6000 7500 5000
  ↓ 开头插入
腾位    （空）6000 7500 5000
  ↓
结果    4000 6000 7500 5000
```

## 删除类似

中间删掉一个，后面的常要前移补洞。频繁在中间改动时，数组显得笨重。

## 末尾追加往往便宜些

若只在末尾加新一天步数，常常不必搬动旧元素（仍可能触发扩容复制）。真正贵的是**中间或开头**插入。

分析成本时，先问插入发生在哪一端，再判断数组是否仍可接受。

@Callout(title: "插入要搬", tone: "information", accent: "purple") {
连续布局的代价：中间改动可能触发大量搬移。
}

@Quiz(id: "cs-mem-array-limit-insert.quiz-1", kind: "singleChoice") {
在长数组的开头频繁插入。主要痛苦是什么？

@Option(id: "cs-mem-array-limit-insert-q1-shift", correct: true) {
几乎每次都要把大量后续元素后移

@Feedback(title: "搬移主导成本", tone: "success", accent: "mint") {
下标访问快，不代表中间更新也便宜。
}
}

@Option(id: "cs-mem-array-limit-insert-q1-free") {
开头插入永远零成本
}

@Option(id: "cs-mem-array-limit-insert-q1-addr") {
地址概念会因此消失
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
灵活与连续，常常不可兼得。
}

@Feedback(when: "incorrect", title: "想象腾位", tone: "warning", accent: "amber") {
第一格被占用时，旧第一格去哪？
}
}
