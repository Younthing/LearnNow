有了数组与字符串，下一步常问：目标在不在里面？在哪？这就是**查找**。

名单里找 `"Lin"`：输入是列表与目标，输出是位置或「没有」。

## 查找的输入输出

```text
输入  列表 + 目标
  ↓
查找过程
  ↓
输出  下标 或 未找到
```

## 与遍历的关系

查找常建立在遍历上，但多了「比中就停」的目标，不只是路过每个元素。

## 查找要先写清输出

开始写算法前，先约定：找到时返回下标还是返回元素本身？找不到时返回什么标记？

输出约定一模糊，调用者就会把「未找到」误当成「第 0 项」，错误会传到很远。

@Callout(title: "定位目标", tone: "information", accent: "purple") {
查找 = 在集合中判断目标是否存在并给出位置。
}

@Quiz(id: "cs-data-search-goal.quiz-1", kind: "singleChoice") {
查找问题的输出通常是什么？

@Option(id: "cs-data-search-goal-q1-pos", correct: true) {
目标的位置，或明确的未找到

@Feedback(title: "两种合法结果", tone: "success", accent: "mint") {
「没有」也是需要处理的结果。
}
}

@Option(id: "cs-data-search-goal-q1-sort") {
必须同时把列表排序完成才算查找
}

@Option(id: "cs-data-search-goal-q1-hw") {
只能输出一块新芯片型号
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先钉死 I/O，再选算法。
}

@Feedback(when: "incorrect", title: "看问题定义", tone: "warning", accent: "amber") {
查找问的是「在哪/有没有」，不是「如何排序」。
}
}
