无序列表里，最大值可能在任何位置。**排序**把元素按规则排成递增或递减，位置关系变得可预期。

`[70, 95, 80]` 排成 `[70, 80, 95]` 后，最小在左，最大在右。

## 顺序是一种结构

排序不新增数据，它重组已有数据，让「谁更大」反映在位置上。

```text
无序  70, 95, 80
  ↓ 排序
有序  70, 80, 95
```

## 规则要先定

按数值、按字母、按时间……规则不同，结果不同。排序前先钉死比较键。

## 排序不创造新分数

`70、95、80` 排完还是这三个数，只是位置变了。排序改变的是**组织**，不是数值本身。

所以「排序后最大值在端点」成立的前提是：比较规则与你关心的大小一致。

@Callout(title: "排成顺序", tone: "information", accent: "purple") {
排序让大小关系变成位置关系。
}

@Quiz(id: "cs-data-sort-why.quiz-1", kind: "singleChoice") {
把分数排成递增后，最大值在哪？

@Option(id: "cs-data-sort-why-q1-right", correct: true) {
在最右侧（最后一个位置）

@Feedback(title: "位置可预期", tone: "success", accent: "mint") {
这正是排序带来的结构。
}
}

@Option(id: "cs-data-sort-why-q1-random") {
仍可能在任意位置，与排序无关
}

@Option(id: "cs-data-sort-why-q1-gone") {
最大值会从列表中删除
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
递增序列的端点就是极值。
}

@Feedback(when: "incorrect", title: "看端点", tone: "warning", accent: "amber") {
递增意味着越往右越大。
}
}
