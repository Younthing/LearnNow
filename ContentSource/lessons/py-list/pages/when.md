一周五天的学习分钟，若写成 `m1, m2, m3...`，循环和合计都会很别扭。

**列表**把多项按顺序放进一个变量里，适合「同类、可数、有先后」的数据。

## 看起来像什么

```python
minutes_list = [30, 40, 20, 50, 35]
```

方括号、逗号分隔。整份列表是一个值，里面有多个位置。

```text
位置 0 → 30
位置 1 → 40
位置 2 → 20
...
```

## 适合 / 不适合

| 更适合列表 | 不太适合硬塞列表 |
| --- | --- |
| 多天分钟、多次打卡 | 单个无关配置项硬凑成表 |
| 要按顺序处理 | 只靠名字查找、无顺序（更像字典） |

一串学习记录，正是列表的主场。

@Callout(title: "多项同类有顺序", tone: "information", accent: "mint") {
列表把一串值按位置排好，方便整体保存与逐个处理。
}

@Quiz(id: "py-list-when.quiz-1", kind: "singleChoice") {
要保存周一到周五每天的学习分钟，更合适的是？

@Option(id: "py-list-when-q1-list", correct: true) {
一个列表，按天的顺序放入五个数
}

@Option(id: "py-list-when-q1-five-bool") {
五个互不相关的布尔值，分别表示心情
}

@Option(id: "py-list-when-q1-one-str") {
一个超长字符串，把所有数字粘在一起且永不分开
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
同类、多项、有顺序——列表对得上。
}

@Feedback(when: "incorrect", title: "看数据长什么样", tone: "warning", accent: "amber") {
你要的是五个可单独取用的分钟数，不是心情，也不是粘死的一坨字。
}
}

@Quiz(id: "py-list-when.quiz-2", kind: "singleChoice") {
列表相对「m1、m2、m3…」最大的组织优势是？

@Option(id: "py-list-when-q2-one-var", correct: true) {
多项收在一个变量里，便于循环与统一处理
}

@Option(id: "py-list-when-q2-faster-always") {
列表会让任何程序永远快十倍
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
一个名字握住整串数据，循环才写得顺。
}

@Feedback(when: "incorrect", title: "先看结构收益", tone: "warning", accent: "amber") {
本课强调的是组织方式，不是性能口号。
}
}
