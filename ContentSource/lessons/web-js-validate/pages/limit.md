前端检查**不能替代**服务器检查。用户可能关掉脚本，或绕过浏览器直接发请求。共享数据的入口仍须在服务器再验一次。

```text
浏览器检查  →  体验好、可绕过
服务器检查  →  必须有、不可省
```

## 分工

| 位置 | 作用 |
| --- | --- |
| 浏览器 | 快速反馈 |
| 服务器 | 最终把关 |

「小记」上线时，两端都要有「非空且不超过 200 字」这类规则。

## 为什么服务器还要验

用户可以禁用脚本，也可以用其它工具直接发 HTTP 请求。浏览器里的检查提升体验，但拦不住绕过。

```text
浏览器检查  快，可绕过
服务器检查  慢一点，必须有
```

## 两端同一条规则

「非空且不超过 200 字」应在两端都存在，提示文案尽量一致，避免前端说能发、后端又打回。

## 安全课会再加重

这里先留下判断：前端检查有价值，但不是唯一防线。后面谈注入与授权时，会看到绕过如何发生。

回到本页的目标：围绕「怎样检查用户提交的数据？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "前端检查可绕过", tone: "warning", accent: "amber") {
浏览器端检查提升体验，但不能当作唯一防线；服务器必须再验。
}

@Quiz(id: "web-js-validate-page-limit.quiz-1", kind: "singleChoice") {
只在浏览器做了字数限制，服务器完全不验。风险是什么？

@Option(id: "web-js-validate-q2-bypass", correct: true) {
有人绕过浏览器直接提交超长内容

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
前端可关可绕。
}
}

@Option(id: "web-js-validate-q2-safe") {
完全没有风险，因为按钮写了 disabled
}

@Option(id: "web-js-validate-q2-css") {
CSS 会在服务器自动补验
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
缺服务器校验就留下绕过空洞。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
disabled 和 CSS 都挡不住直接构造的请求。
}
}
