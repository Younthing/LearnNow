写好的程序不会魔法生效。还要经过翻译或解释，变成硬件能取指执行的指令。

## 人写高层，机跑低层

你看到的是语言语句；运行时，对应的是上一单元说的取指—执行循环。语言隐藏了比特细节，并不取消它们。

```text
源程序（语言）
  ↓ 翻译/解释
机器指令
  ↓ 取指执行
处理数据
```

## 边界

语言不能让含糊意图变精确；它只忠实翻译你按语法写下的内容。写错逻辑，翻译后仍错。

@Callout(title: "仍要落到指令", tone: "warning", accent: "amber") {
语言是桥；桥对面仍是硬件执行的指令与数据。
}

@Quiz(id: "cs-prog-language-translate.quiz-1", kind: "singleChoice") {
程序逻辑写反了，但语法完全合法。翻译并运行后通常会怎样？

@Option(id: "cs-prog-language-translate-q1-wrong", correct: true) {
仍按错误逻辑执行，得到错误结果

@Feedback(title: "合法≠正确", tone: "success", accent: "mint") {
翻译保证可执行，不保证符合意图。
}
}

@Option(id: "cs-prog-language-translate-q1-fix") {
翻译器会自动改成你心里想的逻辑
}

@Option(id: "cs-prog-language-translate-q1-refuse") {
语法合法的程序永远拒绝运行
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
正确性仍要靠你写对，并用例子检验。
}

@Feedback(when: "incorrect", title: "分清两层", tone: "warning", accent: "amber") {
语法合法只说明「能译」；对错仍看算法。
}
}
