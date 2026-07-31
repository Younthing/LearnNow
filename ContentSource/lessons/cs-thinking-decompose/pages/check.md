怎样快速检验拆法是否可用？给每一步标**输入**和**输出**。

## 输入输出对齐

烧水：输入是冷水与加热装置，输出是热水。若上一步输出对不上下一步输入，拆法就有裂缝。

```text
烧水   输出：热水
  ↓
冲泡   输入：热水 + 茶叶
  ↓
端出   输入：泡好的茶
```

## 裂缝就是待补步骤

缺「取茶叶」时，冲泡的输入对不齐。补上缺失步骤，链条才闭合。下一课会在步骤之间加入选择与重复。

## 也可以从输出倒推

想要「桌上有一杯茶」，倒推需要「泡好的茶」，再倒推需要热水与茶叶。倒推常能暴露漏掉的准备步骤。

正向拆与倒推验，一起用更稳。

@Callout(title: "用 I/O 验缝", tone: "warning", accent: "amber") {
上一步输出对不上下一步输入，就说明漏步或拆错。
}

@Quiz(id: "cs-thinking-decompose-check.quiz-1", kind: "singleChoice") {
清单是：放茶叶 → 冲泡。没有烧水。用输入输出检验，会发现什么？

@Option(id: "cs-thinking-decompose-check-q1-gap", correct: true) {
冲泡需要热水，但上一步没有提供热水

@Feedback(title: "输入对不齐", tone: "success", accent: "mint") {
裂缝指出了漏掉的烧水步骤。
}
}

@Option(id: "cs-thinking-decompose-check-q1-ok") {
没有问题，茶叶会自己产生热水
}

@Option(id: "cs-thinking-decompose-check-q1-order") {
只需把两步对调，热水就会出现
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
对齐输入输出，比凭感觉找漏步更稳。
}

@Feedback(when: "incorrect", title: "写出 I/O", tone: "warning", accent: "amber") {
给「冲泡」列出必需输入，看上一步是否提供了它们。
}
}
