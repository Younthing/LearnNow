科目叫「语文」，分钟是 `40`。你想打印「语文学了 40 分钟」——这是在 **拼接** 文本。

## 用加号连接

```python
subject = "语文"
minutes = 40
line = subject + "学了" + str(minutes) + "分钟"
print(line)
```

数字要先变成字符串（`str(...)`），才能和文字用 `+` 连接。

```text
「语文」+「学了」+「40」+「分钟」
  ↓
语文学了40分钟
```

## 拼的是给人看的句子

拼接常用于提示语、日志行、写入文件前的一行文本。先弄清要出现哪些零件，再按顺序接上。

@Callout(title: "零件接成句子", tone: "information", accent: "mint") {
字符串可以用 `+` 拼接；数字要先转成文本再接。
}

@Quiz(id: "py-str-build.quiz-1", kind: "singleChoice") {
`"语文" + 40` 直接相加，按我们已经学过的类型规则，最可能？

@Option(id: "py-str-build-q1-need-str", correct: true) {
出问题，因为一边是文本一边是数字，需先 str(40)
}

@Option(id: "py-str-build-q1-ok") {
自动得到「语文40」，任何类型都能用 + 拼
}

@Option(id: "py-str-build-q1-70") {
得到 70，因为发生了算术加成
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
拼接要求两边都是文本（或改用别的格式化方式）。
}

@Feedback(when: "incorrect", title: "回想类型那一课", tone: "warning", accent: "amber") {
`+` 对两个数字是加法，对两个字符串是拼接；混用会撞车。
}
}

@Quiz(id: "py-str-build.quiz-2", kind: "singleChoice") {
拼接最适合解决哪类问题？

@Option(id: "py-str-build-q2-sentence", correct: true) {
把几段已有文本按顺序组成一句完整说明
}

@Option(id: "py-str-build-q2-sort") {
把数字从大到小排序
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
拼接的对象是文本零件。
}

@Feedback(when: "incorrect", title: "拼接不是排序", tone: "warning", accent: "amber") {
排序是另一类处理；拼接关心的是「接成一句」。
}
}
