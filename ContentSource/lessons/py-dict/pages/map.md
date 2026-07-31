你想知道「语文学了多少分钟」。若数据在列表里，你得记住语文在第几个位置。

**字典**用键直接指向值：键是名称，值是内容。

## 最小样子

```python
subject_minutes = {"语文": 40, "数学": 25}
print(subject_minutes["语文"])  # 40
```

花括号里是成对的 `键: 值`。取值时写键，不是写下标数字。

```text
键「语文」 → 值 40
键「数学」 → 值 25
```

## 键应当唯一

同一个键出现两次，后面的会盖住前面的。键是查找的身份证，重复就乱套。

## 可以改值、可加新键

```python
subject_minutes["数学"] = 30
subject_minutes["英语"] = 20
```

字典可变：改已有键的值，或加入新的键值对。

@Callout(title: "按名字取，不按座位号", tone: "information", accent: "mint") {
字典用 **键** 找到 **值**；键应唯一，才找得准。
}

@Quiz(id: "py-dict-map.quiz-1", kind: "singleChoice") {
`subject_minutes["语文"]` 取到的是？

@Option(id: "py-dict-map-q1-40", correct: true) {
与键「语文」对应的值 40
}

@Option(id: "py-dict-map-q1-key") {
键本身这两个字「语文」
}

@Option(id: "py-dict-map-q1-first") {
字典里的第一个值，不管键是什么
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
方括号里是键，取回的是映射到的值。
}

@Feedback(when: "incorrect", title: "看冒号右边", tone: "warning", accent: "amber") {
"语文": 40 表示键语文对应值 40。
}
}

@Quiz(id: "py-dict-map.quiz-2", kind: "singleChoice") {
为什么字典的键不宜重复？

@Option(id: "py-dict-map-q2-id", correct: true) {
键是查找身份，重复会让「找谁」变得含糊
}

@Option(id: "py-dict-map-q2-syntax") {
Python 语法上绝对写不出两个相同的键
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
键要像身份证。重复时后写的通常盖住先写的。
}

@Feedback(when: "incorrect", title: "能写但会覆盖", tone: "warning", accent: "amber") {
文字上可能写出重复键，但含义会乱，应避免。
}
}
