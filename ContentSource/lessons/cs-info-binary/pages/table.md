比特串要变回字、图或声，必须用**同一套映射表**。表错了，原料还在，解释却歪。

## 错表会怎样

用文字表去解图片比特，得到的不是「一张坏掉的图」，而是一串无意义的字符或乱码式结果。问题常在约定，不在比特「坏了」。

```text
比特串 S
├─ 用图片表  →  一小块颜色
└─ 用文字表  →  乱码/错字
```

## 编解码成对

发送方按表 A 编码，接收方必须按表 A 解码。上一课的「共享约定」，在二进制世界里就是这张表。

@Callout(title: "表决定读法", tone: "warning", accent: "amber") {
同一串比特，换表就换含义；先确认用的是哪张表。
}

@Quiz(id: "cs-info-binary-table.quiz-1", kind: "singleChoice") {
一段本是图片的比特，被当成文字打开，屏幕出现乱码。最优先怀疑什么？

@Option(id: "cs-info-binary-table-q1-table", correct: true) {
用错了解释表：按文字规则去读图片数据

@Feedback(title: "原料未必坏", tone: "success", accent: "mint") {
先换回正确类型的打开方式，再判断文件是否损坏。
}
}

@Option(id: "cs-info-binary-table-q1-gone") {
比特一定全部丢失了，否则不可能乱
}

@Option(id: "cs-info-binary-table-q1-mind") {
图片比特自己决定要扮成文字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
乱码常常是错表，不是内容蒸发。
}

@Feedback(when: "incorrect", title: "先换表再下结论", tone: "warning", accent: "amber") {
用正确的图片方式打开同文件，看画面是否恢复。
}
}
