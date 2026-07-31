同一份「小记」，在手机上应易读易点，在宽屏上可展示侧栏。**响应式**就是让同一套页面在不同屏幕宽度下仍好用。

不是为每个设备各做完全无关的网站，而是同一 HTML，用 CSS 在不同宽度下调整布局与字号。

## 为何不能只按自己的电脑调

```text
你的宽屏
└─ 两栏很舒服

别人的手机
└─ 两栏会挤成细条
```

若只按宽屏设计，手机用户会横滑、误触、看不清。

## 目标

优先保证：可读、可点、少横滑。装饰性侧栏在窄屏可以移到下方或收起。

## 落到「小记」上

宽屏两栏很舒服：左边留言，右边标签。手机上若仍强行两栏，每栏都细成一条，按钮难点、字难读。

## 目标写清楚

```text
可读：字号与行长合适
可点：按钮够大、间距够
少横滑：宽度适应视口
```

装饰性侧栏在窄屏可以移到下方或先藏起，总好过牺牲主流程。

改完后把窗口拖窄，用拇指点按钮。若要横着滑才能看完一行，或按钮难点，说明还没适配好这一宽度。

@Callout(title: "一套页面，多种宽度", tone: "information", accent: "mint") {
响应式用同一内容骨架，按屏幕宽度调整呈现，而不是只服务一种显示器。
}

@Quiz(id: "web-css-responsive-page-need.quiz-1", kind: "singleChoice") {
「小记」在手机上两栏挤到看不清。按本课目标，更合理的方向是？

@Option(id: "web-css-responsive-q1-adapt", correct: true) {
在窄宽度下改布局（例如改为单栏）

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
窄屏先保证可读可点。
}
}

@Option(id: "web-css-responsive-q1-ignore") {
要求所有用户必须用台式显示器
}

@Option(id: "web-css-responsive-q1-dns") {
换一个域名就会自动适配
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
适配宽度，而不是拒绝窄屏用户。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
响应式的核心是按宽度调整呈现。
}
}
