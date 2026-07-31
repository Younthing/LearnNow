计算思维给了步骤，但硬件只吃指令比特。人直接写比特既慢又易错。这就出现了表达落差。

## 两头都难

纯自然语言含糊；纯机器码难写。需要一种**对人更可读、对机器仍精确**的中间层。

```text
人的意图
  ↓ ？桥？
机器指令比特
```

## 编程语言填这层

编程语言用严格语法写出步骤、选择与重复，让人能读，又足够精确以便翻译成指令。

## 伪代码仍在桥的人这一侧

上一单元的伪代码帮助想清步骤；编程语言把步骤写到可自动翻译的精度。两者都在「人可读」一侧，但语言多了严格语法与检查。

从伪代码到程序，常常是把含糊词换成可执行词。

@Callout(title: "填落差", tone: "information", accent: "purple") {
语言存在，是为了在含糊口语与难写机器码之间搭桥。
}

@Quiz(id: "cs-prog-language-gap.quiz-1", kind: "singleChoice") {
为什么不建议普通人直接用 0/1 写完所有程序？

@Option(id: "cs-prog-language-gap-q1-hard", correct: true) {
机器码难写难查，表达成本过高

@Feedback(title: "成本与可靠性", tone: "success", accent: "mint") {
语言降低书写与阅读成本，同时保持可翻译的精确性。
}
}

@Option(id: "cs-prog-language-gap-q1-never") {
机器永远不能执行任何翻译后的程序
}

@Option(id: "cs-prog-language-gap-q1-same") {
0/1 与日常汉语完全一样好写
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
语言是工程上的折中：可读 + 精确。
}

@Feedback(when: "incorrect", title: "对比成本", tone: "warning", accent: "amber") {
想象改一处逻辑时，改语句与改整段比特哪个更可行。
}
}
