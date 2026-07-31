排队和划界都是对 app 的限制。第三件事更像是替 app 干活：它想用的那些器件，都不是它自己去碰的。

记账 app 想在屏幕上画出 38，想打开麦克风记一句语音备注，想把这个月的数据存下来，它做的都是同一个动作：向操作系统递一个请求。

## 请求，而不是自取

```text
记账 app  ──请求──→  操作系统  ──操作──→  屏幕 / 麦克风 / 存储
                        ↑
                    音乐 app 的请求也走这里
```

器件只有一套，想用的 app 有很多。让每个 app 直接抢，谁写得早、谁写得狠就赢；收到统一的地方来排，才排得出队。

## 你见过这个入口

某个 app 第一次想用麦克风时，屏幕上弹出的那句「是否允许」不是 app 自己画的。是系统在你和器件之间站了一道。

app 只能提出请求，答不答应由系统和你决定。这也是为什么同一个 app 在你手机上用得了摄像头，在你朋友手机上用不了：清单一样，答复不一样。

## 一句可以带走的判断

凡是要用到大家共用的东西——CPU 的时间、内存的地盘、屏幕、麦克风、存储——app 都只能申请，不能自取。

其中「把这个月的数据存下来」值得单独看一次：它请求的对象是一块关掉电也不会忘的地方。东西究竟怎么留下来的，是下一课的问题。

@Callout(title: "申请，不自取", tone: "information", accent: "purple") {
共用的东西只有一套，所以 app 说的是「请帮我」，不是「我来」。
}

@Quiz(id: "kc-os-gateway.quiz-1", kind: "singleChoice") {
一个记账 app 说它能在后台一直录音，随时听你报账。你在系统设置里把它的麦克风权限关了。按这一页的模型，会发生什么？

@Option(id: "kc-os-gateway-q1-request-denied", correct: true) {
它照样可以发出请求，但请求过不了系统这道口子，拿不到声音

@Feedback(title: "关的是口子", tone: "success", accent: "mint") {
权限开关不改 app 的清单，它改的是系统答不答应这个请求。
}
}

@Option(id: "kc-os-gateway-q1-rewrite-app") {
app 里那一步录音的步骤会被系统删掉，所以它不会再尝试
}

@Option(id: "kc-os-gateway-q1-bypass") {
它可以绕过系统直接从麦克风取声音，只是会慢一点
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
分清「能不能提出请求」和「请求会不会被满足」，权限这件事就讲得通了。
}

@Feedback(when: "incorrect", title: "想想开关改的是谁", tone: "warning", accent: "amber") {
你可能以为权限开关动的是 app 本身。自检办法：关掉权限后 app 还是原来那份程序，改变的只可能是它请求的结果。
}
}

@Quiz(id: "kc-os-gateway.quiz-2", kind: "singleChoice") {
两个 app 都想在同一秒把内容画到屏幕上。按这一课的三件事，最可能的处理方式是什么？

@Option(id: "kc-os-gateway-q2-os-arranges", correct: true) {
两个请求都交给操作系统，由它决定屏幕这一刻显示谁的内容
}

@Option(id: "kc-os-gateway-q2-first-wins") {
先发出请求的那个 app 直接接管屏幕，另一个只能等它主动放手
}

@Option(id: "kc-os-gateway-q2-split-screen") {
屏幕会自动一半给一个 app，两个都画得上
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
共用的器件冲突时，做决定的一直是同一个角色，这就是它存在的理由。
}

@Feedback(when: "incorrect", title: "回到「谁说话算话」", tone: "warning", accent: "amber") {
你可能又把决定权交回给了 app。自检办法：如果 app 能自己接管屏幕，你还怎么把它划走去看别的东西？
}
}
