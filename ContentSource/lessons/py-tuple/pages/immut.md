列表能 append、能改下标。若你希望「这一组值装好就别动」，可以用 **元组**。

## 写法

```python
day = ("周一", 40)
print(day[0])  # 周一
print(day[1])  # 40
```

圆括号、逗号分隔；也能用下标取。和列表很像——直到你想改它。

## 不能改元素

```text
day[1] = 50   → 通常报错
```

元组强调 **不可变**：创建后内容固定。这能防止后面代码顺手改坏一组本该固定的搭配。

## 仍是有序的

第一个、第二个位置有意义：`(名称, 分钟)` 不要随便对调含义。有序 + 不可变，是它的画像。

@Callout(title: "装好就锁定", tone: "information", accent: "mint") {
元组按顺序保存一组值，但 **不能** 像列表那样改元素或 append。
}

@Quiz(id: "py-tuple-immut.quiz-1", kind: "singleChoice") {
对 `day = ("周一", 40)` 执行 `day[1] = 50`，按元组规则最可能？

@Option(id: "py-tuple-immut-q1-error", correct: true) {
报错，因为元组不允许改元素
}

@Option(id: "py-tuple-immut-q1-ok") {
成功变成 ("周一", 50)，元组和列表一样可变
}

@Option(id: "py-tuple-immut-q1-append") {
自动在末尾再追加一个 50
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
不可变就是这里的关键差别。
}

@Feedback(when: "incorrect", title: "想起「锁定」", tone: "warning", accent: "amber") {
能按下标读取，不等于能按下标写入。
}
}

@Quiz(id: "py-tuple-immut.quiz-2", kind: "singleChoice") {
`day[0]` 能取出「周一」，说明元组至少具备什么性质？

@Option(id: "py-tuple-immut-q2-order", correct: true) {
有顺序，可以用位置取到对应项
}

@Option(id: "py-tuple-immut-q2-mut") {
可变，所以才能取下标
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
能按下标读，说明有序；可变是另一回事。
}

@Feedback(when: "incorrect", title: "读和写分开", tone: "warning", accent: "amber") {
读取下标不要求可变；改写才要求可变。
}
}
