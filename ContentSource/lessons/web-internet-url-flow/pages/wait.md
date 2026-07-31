顺序有了。打开失败时，用同一条链排查，比瞎猜有用。

## 失败可能卡在不同步

| 你看到的现象 | 更可能卡在 |
| --- | --- |
| 提示找不到服务器 | 第 2 步：没连上 |
| 一直转圈无内容 | 第 3～4 步：要了但没给齐 |
| 出来一堆看不懂的符号 | 第 5 步：拿到了但没画对 |

这些是入门判断，不是完整运维手册。目的只有一个：知道「打开网址」不是魔法，是一条可检查的链。

```text
输入网址
  ↓
链上每一步都可能失败
  ↓
先定位步骤，再谈细节
```

## 下一课钩子

「读懂你要去哪」和「找到服务器」之间，还有域名怎样变成可连接地址的问题——那是下一课。再往后，请求和响应的具体约定叫 HTTP。

## 练习用现象定位

下次打开失败，先对照表，而不是同时怀疑所有层。定位到步骤后，再进入 DNS 或 HTTP 的细节课。

## 收口

打开网址不是魔法，是一条可检查的链。转圈表示链上某步未完成。

@Callout(title: "转圈不是谜", tone: "information", accent: "mint") {
转圈表示链上某一步还没走完。先问卡在找路、等待还是绘制。
}

@Quiz(id: "web-internet-url-flow-page-wait.quiz-1", kind: "singleChoice") {
打开「小记」时立刻弹出「无法找到服务器」。按本课的表，优先怀疑哪一步？

@Option(id: "web-internet-url-flow-q2-connect", correct: true) {
还没连上服务器那一步

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
「找不到服务器」直接指向连接之前或连接失败。
}
}

@Option(id: "web-internet-url-flow-q2-paint") {
已经取到内容，只是画坏了
}

@Option(id: "web-internet-url-flow-q2-quiz") {
一定是页面上的练习题写错了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
找不到服务器，问题在链路前段，不在绘制。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
若已经在画页面，你通常会看到残缺内容，而不是「找不到服务器」。
}
}
