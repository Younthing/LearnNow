列表不只是「装起来」。你还要取出某一天、改某一天、在末尾追加新的一天。

## 下标从 0 开始

```python
minutes_list = [30, 40, 20]
print(minutes_list[0])  # 30
print(minutes_list[1])  # 40
```

第一个元素是 `[0]`，不是 `[1]`。数位置时从零起。

## 可变：改与追加

```python
minutes_list[2] = 25      # 改第三天
minutes_list.append(45)   # 末尾加一天
```

列表是 **可变** 的：同一份列表对象上的内容可以改。这和「数字变量被重新赋值」感觉类似，但常常是在原地改内容。

```text
[30, 40, 20]
     ↓ 改下标 2
[30, 40, 25]
     ↓ append 45
[30, 40, 25, 45]
```

## 越界会报错

要下标 `5` 但只有 3 个元素，会出错。先问长度，或只遍历现有元素。

@Callout(title: "位置从 0 起，内容可改", tone: "information", accent: "mint") {
用下标取元素；列表允许修改已有位置，也可以 append 新项。
}

@Quiz(id: "py-list-ops.quiz-1", kind: "singleChoice") {
`[30, 40, 20]` 中，`minutes_list[1]` 是？

@Option(id: "py-list-ops-q1-40", correct: true) {
40，因为下标从 0 起，1 是第二个
}

@Option(id: "py-list-ops-q1-30") {
30，因为 1 代表第一天
}

@Option(id: "py-list-ops-q1-20") {
20，因为 1 代表最后一天
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
0→30，1→40，2→20。
}

@Feedback(when: "incorrect", title: "从零数一遍", tone: "warning", accent: "amber") {
用手指点：第零个、第一个、第二个。
}
}

@Quiz(id: "py-list-ops.quiz-2", kind: "singleChoice") {
执行 `minutes_list.append(45)` 的主要效果是？

@Option(id: "py-list-ops-q2-add", correct: true) {
在列表末尾多一个 45
}

@Option(id: "py-list-ops-q2-replace0") {
把下标 0 强制改成 45
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
append 是追加到末尾，不是替换开头。
}

@Feedback(when: "incorrect", title: "追加 vs 赋值下标", tone: "warning", accent: "amber") {
改某一格用 `列表[i] = ...`；末尾加新项用 append。
}
}
