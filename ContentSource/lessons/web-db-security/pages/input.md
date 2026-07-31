Web 应用面对的是不可信输入。基础安全的第一条：**永不信任**来自浏览器的数据，服务器必须校验与约束。

两处经典风险入门：

```text
注入
└─ 把用户输入直接拼进查询，可能被改成别的命令

跨站脚本（XSS）
└─ 把未转义的用户留言原样塞进页面，可能变成可执行脚本
```

「小记」展示留言时要转义；拼查询时要用参数化，而不是字符串硬接。

## 两条入门风险

```text
注入：输入被拼进查询，改变命令含义
XSS：未转义留言变成页面里的脚本
```

「小记」展示留言要转义；拼查询要用参数化，而不是字符串硬接。

## 总原则

把所有来自浏览器的数据先当成不可信，再校验、约束、转义或参数化后使用。

## 最小防护清单

校验长度与必填；查询用参数化；输出到 HTML 前转义。三件事做完，已经能挡住一大类入门级事故。

## 用自己的话收一下

回到本页的目标：围绕「Web 应用需要注意哪些基础安全问题？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "输入不可信", tone: "warning", accent: "amber") {
所有用户输入先当不可信：校验、约束、转义或参数化后再用。
}

@Quiz(id: "web-db-security-page-input.quiz-1", kind: "singleChoice") {
把留言正文直接拼进 SQL 字符串再执行。主要风险是？

@Option(id: "web-db-security-q1-inject", correct: true) {
注入：输入可能改变查询含义

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
硬拼接是注入温床。
}
}

@Option(id: "web-db-security-q1-pretty") {
页面会更好看
}

@Option(id: "web-db-security-q1-faster") {
只会让查询更快且无副作用
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
拼接查询有注入风险。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
安全问题不是美观或速度红利。
}
}
