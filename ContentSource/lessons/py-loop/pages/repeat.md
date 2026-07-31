你有五天的学习分钟：`30, 40, 20, 50, 35`。若写五次几乎一样的 `print`，改措辞就要改五遍。

**循环**把「同一套步骤」写一次，让程序按数据自动重复。

## 复制粘贴的代价

```text
print 周一
print 周二
print 周三
...
```

能跑，但步骤和次数缠在一起。天数一变，你就得增删整行。

## 循环分开两件事

```text
要重复的步骤：打印这一天的分钟
重复多少次：有多少天就多少次
```

步骤写在循环体里；次数由数据的长度决定。改步骤只改一处。

## 什么时候该循环

同一套动作要对许多同类数据做一遍——列表里的每一天、每一次打卡——就适合循环。只做一次的事，不必硬套循环。

@Callout(title: "步骤写一次", tone: "information", accent: "mint") {
循环让 **同一套步骤** 自动重复；变化的是每一轮拿到的数据。
}

@Quiz(id: "py-loop-repeat.quiz-1", kind: "singleChoice") {
要从 5 天改成 7 天都打印分钟。用五次手写 print 时，你通常得怎样？

@Option(id: "py-loop-repeat-q1-add", correct: true) {
再手写两行几乎相同的 print，并保证格式一致
}

@Option(id: "py-loop-repeat-q1-auto") {
什么都不用改，Python 会自己补两天
}

@Option(id: "py-loop-repeat-q1-delete") {
删掉所有 print，程序会改用循环
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
手写重复把次数写死了。天数一变，就要改多处。
}

@Feedback(when: "incorrect", title: "想改动落在哪", tone: "warning", accent: "amber") {
手写的每一行对应一天。多两天，就得再出现两行同类代码。
}
}

@Quiz(id: "py-loop-repeat.quiz-2", kind: "singleChoice") {
循环最适合解决下面哪类问题？

@Option(id: "py-loop-repeat-q2-many", correct: true) {
对许多同类数据重复做同一套动作
}

@Option(id: "py-loop-repeat-q2-once") {
只做一次、且以后也不会重复的动作
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
重复 + 同类数据，正是循环的主场。
}

@Feedback(when: "incorrect", title: "看有没有「许多次」", tone: "warning", accent: "amber") {
只做一次时，直接写那一步通常更清楚。
}
}
