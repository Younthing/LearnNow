数组下标为何能快速访问？因为元素常按固定大小排在连续地址上，下标可**换算**成地址。

## 换算直觉

若首元素在地址 `100`，每格占 1 个单位，则下标 `i` 约在 `100+i`。不必按名字搜索，直接算位置。

```text
下标 0 → 地址 100
下标 1 → 地址 101
下标 2 → 地址 102
```

## 为下一课铺垫

连续布局让数组擅长按下标跳转，但插入删除可能要搬很多格——那是「数组不够灵活」的根源。

## 为什么随机访问快

因为位置可算：知道首地址与每格大小，第 `i` 格的地址几乎立刻得到，不必从 0 号挨个问「你是不是我要的」。

这是数组相对链表的关键优势，也是中间插入要搬家的根源——连续布局被插入打断。

@Callout(title: "下标换地址", tone: "warning", accent: "amber") {
连续存放时，下标通过简单算术变成地址。
}

@Quiz(id: "cs-mem-address-array.quiz-1", kind: "singleChoice") {
首地址 `100`，每元素占 1 单位，下标 `2` 大约在哪？

@Option(id: "cs-mem-address-array-q1-102", correct: true) {
地址 `102`

@Feedback(title: "加法换算", tone: "success", accent: "mint") {
100+2=102。
}
}

@Option(id: "cs-mem-address-array-q1-100") {
只能是 `100`，与下标无关
}

@Option(id: "cs-mem-address-array-q1-200") {
必须是 `200`，没有别的可能
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
这就是下标访问快的几何原因。
}

@Feedback(when: "incorrect", title: "做一次加法", tone: "warning", accent: "amber") {
首地址加上下标（单位为 1 时）。
}
}
