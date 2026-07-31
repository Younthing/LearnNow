你写好了三行「今日学习」小程序，文件安静地躺在电脑里。它自己不会弹出欢迎语——Python 程序怎样跑起来？

把它交给 **Python 解释器**。解释器读这份源文件，按里面的步骤做事；文件只是清单，解释器才是执行者。

## 清单和念清单的人

那三行大概长这样：

```text
第 1 行   打印欢迎
第 2 行   记下学习分钟
第 3 行   打印收尾
```

磁盘上的 `.py` 文件保存的是这些文字。你用 `python` 去打开它，其实是在请解释器来念这份清单。

## 改文件不等于已经运行

你在编辑器里把「欢迎」改成「你好」，只是改了清单上的字。屏幕上还不会出现新字，除非你再 **运行一次**。

```text
编辑器里改字
  ↓
磁盘上的 .py 更新
  ↓
再次交给解释器
  ↓
才看到新结果
```

## 两件不同的事

| 动作 | 你在做什么 | 电脑在做什么 |
| --- | --- | --- |
| 编辑 | 改源文件文字 | 保存文件 |
| 运行 | 启动解释器 | 按文件执行 |

@Callout(title: "文件不会自己跑", tone: "information", accent: "mint") {
`.py` 是步骤清单；**解释器**读它，程序才真正开始。
}

@Quiz(id: "py-run-handoff.quiz-1", kind: "singleChoice") {
小明把今日学习程序保存成了 `study.py`，盯着文件图标等欢迎语出现，什么都没发生。最合理的解释是？

@Option(id: "py-run-handoff-q1-need-run", correct: true) {
他还没有把文件交给解释器去运行
}

@Option(id: "py-run-handoff-q1-auto") {
Python 文件保存后会自动执行，可能是文件坏了
}

@Option(id: "py-run-handoff-q1-need-rename") {
文件名必须改成 `run.py` 才会启动
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
源文件只保存步骤。没有解释器来读，屏幕上就不会有输出。
}

@Feedback(when: "incorrect", title: "分清保存和运行", tone: "warning", accent: "amber") {
自检：保存之后，有没有出现「启动 python / 运行」这一步？没有的话，清单还没被念过。
}
}

@Quiz(id: "py-run-handoff.quiz-2", kind: "singleChoice") {
你改了欢迎语，编辑器里立刻是新文字，但再次运行前终端里仍是旧欢迎语。这说明什么？

@Option(id: "py-run-handoff-q2-edit-not-run", correct: true) {
编辑器显示的是文件内容，终端显示的是上一次运行的结果
}

@Option(id: "py-run-handoff-q2-same") {
编辑器和终端永远显示同一份内容，所以一定是看错了
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
改文件立刻可见；运行结果要等解释器再读一遍才会变。
}

@Feedback(when: "incorrect", title: "对照两个窗口", tone: "warning", accent: "amber") {
一边是源文件，一边是某次运行的输出。再运行一次，两边才会重新对齐。
}
}
