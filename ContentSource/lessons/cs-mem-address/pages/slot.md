内存可以想成很多格子。每个格子有一个**地址**：用来指出「是哪一格」的编号。

## 编号不是值本身

地址 `100` 的格子里可能存着步数 `6000`。`100` 是位置，`6000` 是内容。

```text
地址 100 → 内容 6000
地址 101 → 内容 7500
地址 102 → 内容 5000
```

## 为何需要

没有地址，硬件不知道读写哪一格。变量名最终也要落到地址（由系统帮忙）。

## 名字最终也要落到地址

你在程序里写 `steps`，编译与运行系统会把它对应到某段地址。对人友好的是名字，对硬件直接的是编号。

调试时若看到地址，把它想成门牌；门牌后面的才是步数内容。

@Callout(title: "地址是编号", tone: "information", accent: "purple") {
地址指出格子位置；格子里再放数据值。
}

@Quiz(id: "cs-mem-address-slot.quiz-1", kind: "singleChoice") {
地址是 `100`，其中存着 `6000`。谁是位置，谁是内容？

@Option(id: "cs-mem-address-slot-q1-pos", correct: true) {
`100` 是位置，`6000` 是内容

@Feedback(title: "分清两层", tone: "success", accent: "mint") {
地址定位，值是被存放的对象。
}
}

@Option(id: "cs-mem-address-slot-q1-swap") {
`6000` 是位置，`100` 一定是内容
}

@Option(id: "cs-mem-address-slot-q1-same") {
地址与内容永远是同一个数且不可区分
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
换一个值存入 100，地址仍是 100。
}

@Feedback(when: "incorrect", title: "换值试验", tone: "warning", accent: "amber") {
把内容改成 1，地址编号变了吗？
}
}
