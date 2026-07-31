另一类纪律：**先进入的先离开**，像排队。这叫队列。

打印任务：先提交的先印，避免插队。

## 先进先出

```text
入队 A
入队 B
出队 → A
出队 → B
```

## 解决什么问题

要公平处理等待者、按到达顺序服务时，队列匹配「谁先来谁先办」。

## 两端分工

队列常从尾入、从头出。两端角色固定，才保证到达顺序不被插队破坏。

若业务允许插队，那是优先队列等另一类结构，不再是简单 FIFO。

和栈对照时，只问一句：离开的人是**最后来的**还是**最早来的**？答案一出，结构就定了。

@Callout(title: "队列是 FIFO", tone: "information", accent: "mint") {
队列从一端进、另一端出：先进先出。
}

@Quiz(id: "cs-mem-stack-queue-queue.quiz-1", kind: "singleChoice") {
先入队 `"job1"`，再入队 `"job2"`，下一次出队是？

@Option(id: "cs-mem-stack-queue-queue-q1-j1", correct: true) {
`job1`：先进先出

@Feedback(title: "队头是先来的", tone: "success", accent: "mint") {
队列保护到达顺序。
}
}

@Option(id: "cs-mem-stack-queue-queue-q1-j2") {
`job2`：后进先出
}

@Option(id: "cs-mem-stack-queue-queue-q1-both") {
两个同时出队且顺序随机
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用打印队列直觉检验。
}

@Feedback(when: "incorrect", title: "想排队", tone: "warning", accent: "amber") {
先排到的人先办事，还是后到的先办？
}
}
