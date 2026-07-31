源文件要交给解释器。那它读的时候是怎样走的？

它 **从上到下、一行一行** 做。做完第 1 行再做第 2 行；某行读不下去，通常就停在那里，并把位置告诉你。

## 三行怎么被念完

还是那份今日学习清单：

```text
第 1 行  打印欢迎     → 屏幕出现字
第 2 行  记下分钟     → 内存里留个数
第 3 行  打印收尾     → 再出现一句
```

顺序固定：欢迎一定先于收尾。你不会先看到收尾再看到欢迎——除非你把两行在文件里对调了。

## 错在第 2 行时发生什么

假如第 2 行写成了解释器不认识的样子，常见情况是：

```text
第 1 行   成功执行
第 2 行   卡住并报错
第 3 行   还没轮到
```

所以你已经看见了欢迎语，却看不见收尾。报错信息里的行号，是在说「我读到这里走不动了」。

## 逐行带来的判断习惯

遇到报错，先看它指到哪一行，再看那一行在整份清单里的位置。上一行往往已经发生过；下一行往往还没机会发生。

@Callout(title: "停在哪里就查哪里", tone: "information", accent: "mint") {
解释器 **逐行** 往下走；报错行号是路线图，不是整文件判决书。
}

@Quiz(id: "py-run-lines.quiz-1", kind: "singleChoice") {
运行今日学习程序时，屏幕打出了欢迎语，然后报错，收尾语没有出现。按这一页的模型，最可能是？

@Option(id: "py-run-lines-q1-mid", correct: true) {
欢迎那一行已经执行完，后面某一行让解释器停住了
}

@Option(id: "py-run-lines-q1-all") {
三行同时失败，只是碰巧先显示了欢迎语
}

@Option(id: "py-run-lines-q1-skip") {
解释器跳过了中间，直接去执行最后一行但失败了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
能看见欢迎，说明第一行已经做过；收尾没出现，说明还没走到或走不到最后一行。
}

@Feedback(when: "incorrect", title: "用「看见了什么」反推", tone: "warning", accent: "amber") {
自检：如果三行同时炸，欢迎语通常也出不来。你已经看到欢迎，说明至少第一行跑过了。
}
}

@Quiz(id: "py-run-lines.quiz-2", kind: "singleChoice") {
报错信息指向第 3 行。按逐行模型，你首先应该怎么想？

@Option(id: "py-run-lines-q2-check3", correct: true) {
先检查第 3 行附近，并假设第 1、2 行多半已经执行过
}

@Option(id: "py-run-lines-q2-rewrite") {
整份文件都不可信，应该从第 1 行全部重写
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
行号把注意力缩到卡点。先看那里，再决定要不要往上看。
}

@Feedback(when: "incorrect", title: "别把线索扔掉", tone: "warning", accent: "amber") {
解释器已经告诉你它卡在哪。先读那一行，比从头重写更接近问题本身。
}
}
