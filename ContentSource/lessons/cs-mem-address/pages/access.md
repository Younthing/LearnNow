CPU 读写内存时，要给出地址：读哪一格、写哪一格。

## 定位再操作

「把地址 101 的值加到总和」先定位 101，再取内容。变量名是给人用的标签，底层仍是地址定位。

```text
给出地址
  ↓
读出或写入内容
```

## 错误地址的风险

指向不该碰的格子，会读到垃圾或破坏其他数据。这也是为何高级语言要管边界。

## 一次只碰相关格

好的程序尽量只读写自己的格子。指错地址，可能读到别人的数据，或把别人的状态写坏。

高级语言用边界检查与类型，就是在减少这类「走错门」的事故。

@Callout(title: "凭地址访问", tone: "information", accent: "mint") {
内存读写先定位地址，再碰内容。
}

@Quiz(id: "cs-mem-address-access.quiz-1", kind: "singleChoice") {
要更新某格中的步数，硬件侧关键信息是什么？

@Option(id: "cs-mem-address-access-q1-addr", correct: true) {
那一格的地址，以及要写入的新值

@Feedback(title: "定位+内容", tone: "success", accent: "mint") {
没有地址就不知道写到哪。
}
}

@Option(id: "cs-mem-address-access-q1-poem") {
只需一首诗，不必任何编号
}

@Option(id: "cs-mem-address-access-q1-all") {
必须同时改写全部内存才算更新一格
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
访问 = 地址 + 读写操作。
}

@Feedback(when: "incorrect", title: "最小信息", tone: "warning", accent: "amber") {
若只能说一句话给硬件，你会报门牌号还是报心情？
}
}
