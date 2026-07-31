内存里的 `minutes = 40` 几乎只跟程序自己有关。打开 `study.txt` 却要跟 **外部世界** 合作：文件在不在、路径对不对、有没有权限。

合作失败时，读写就会中断。

## 常见失败来源

```text
路径写错 / 文件不存在
  ↓
没有读或写的权限
  ↓
文件正被其他程序占用
  ↓
磁盘满了或路径指向目录
```

任一环节出问题，`open` 或后续读写都可能失败。

## 别默认「一定有这个文件」

示例代码在你的电脑上能跑，不代表用户的目录里也有同名文件。写文件逻辑时，把失败当成预期可能。

@Callout(title: "成功不是默认选项", tone: "warning", accent: "amber") {
文件操作跨出了程序，进入外部世界；**失败是正常可能**。
}

@Quiz(id: "py-file-fail-why.quiz-1", kind: "singleChoice") {
为什么说读文件比 `minutes = 40` 更容易失败？

@Option(id: "py-file-fail-why-q1-ext", correct: true) {
因为它依赖路径、权限等外部条件，不只由程序自己决定
}

@Option(id: "py-file-fail-why-q1-python") {
因为 Python 禁止读取任何文件
}

@Option(id: "py-file-fail-why-q1-int") {
因为整数赋值总会失败
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
外部依赖越多，失败模式越多。
}

@Feedback(when: "incorrect", title: "对比内外", tone: "warning", accent: "amber") {
赋值主要在程序内；open 要找到真实文件。
}
}

@Quiz(id: "py-file-fail-why.quiz-2", kind: "singleChoice") {
示例程序在作者电脑能读到 study.txt，能推出所有用户一运行就成功吗？

@Option(id: "py-file-fail-why-q2-no", correct: true) {
不能。用户的工作目录里未必有这个文件
}

@Option(id: "py-file-fail-why-q2-yes") {
能。能跑一次就永远到处能跑
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
环境不同，外部条件就不同。
}

@Feedback(when: "incorrect", title: "换一台电脑想一遍", tone: "warning", accent: "amber") {
文件是否存在，是环境问题，不是语法问题。
}
}
