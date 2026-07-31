栈与队列都限制「能碰哪一端」，用纪律减少错误用法。选错纪律，行为就会违反问题规则。

## 对照

| 结构 | 纪律 | 典型问题 |
| --- | --- | --- |
| 栈 | 后进先出 | 撤销、匹配括号 |
| 队列 | 先进先出 | 排队服务 |

```text
要最近优先 → 栈
要到达顺序 → 队列
```

## 下一课钩子

下一课把「组织方式影响效率」收成可迁移判断：先点名操作，再比结构。

## 选错纪律的后果

用队列做撤销，会先撤销最早的修改，编辑体验会错乱。用栈做打印排队，后提交的任务可能先被印出。

先用一句话写出「谁先离开」，再映射到 LIFO 或 FIFO。

@Callout(title: "纪律匹配问题", tone: "warning", accent: "amber") {
先问问题要哪种进出顺序，再选栈或队列。
}

@Quiz(id: "cs-mem-stack-queue-use.quiz-1", kind: "singleChoice") {
实现文本编辑的多层撤销，更匹配哪种结构？

@Option(id: "cs-mem-stack-queue-use-q1-stack", correct: true) {
栈：最后一次修改应最先被撤销

@Feedback(title: "最近优先", tone: "success", accent: "mint") {
撤销的语义就是 LIFO。
}
}

@Option(id: "cs-mem-stack-queue-use-q1-queue") {
队列：必须先撤销最早的一次修改
}

@Option(id: "cs-mem-stack-queue-use-q1-none") {
撤销不需要任何进出顺序
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
把问题里的「最近」翻译成结构纪律。
}

@Feedback(when: "incorrect", title: "翻译语义", tone: "warning", accent: "amber") {
撤销时你想先去掉刚做的，还是先去掉很久以前的？
}
}
