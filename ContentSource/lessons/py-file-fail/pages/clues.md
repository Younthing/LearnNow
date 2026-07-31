失败时先别乱改代码。根据提示，判断比较像哪一类问题。

## 对照表

| 现象线索 | 优先怀疑 |
| --- | --- |
| 找不到文件 / No such file | 路径或文件名 |
| Permission denied | 权限 |
| 正被占用 / locked | 其他程序打开着 |
| 是一个目录 | 路径指到了文件夹 |

## 排查顺序建议

```text
1. 文件名和路径是否写对
2. 当前工作目录是不是你以为的那个
3. 是否有权限、是否被占用
```

下一单元会教你用异常把失败接住；这一页先建立：**失败有类别，类别指导检查顺序**。

@Callout(title: "先分类，再动手", tone: "information", accent: "mint") {
同样是「打不开」，路径错和权限错，修理方式完全不同。
}

@Quiz(id: "py-file-fail-clues.quiz-1", kind: "singleChoice") {
报错大意是「没有那个文件」。你应先检查？

@Option(id: "py-file-fail-clues-q1-path", correct: true) {
路径和文件名是否写对，以及当前目录对不对
}

@Option(id: "py-file-fail-clues-q1-rewrite") {
立刻重写全部业务逻辑
}

@Option(id: "py-file-fail-clues-q1-ignore") {
忽略报错，因为文件操作失败可以自动成功
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
找不到文件，先查定位问题。
}

@Feedback(when: "incorrect", title: "对上号再改", tone: "warning", accent: "amber") {
线索指向路径时，先核对路径，而不是重写无关逻辑。
}
}

@Quiz(id: "py-file-fail-clues.quiz-2", kind: "singleChoice") {
提示 permission denied，更接近哪类问题？

@Option(id: "py-file-fail-clues-q2-perm", correct: true) {
权限不足，当前身份不能读或写该路径
}

@Option(id: "py-file-fail-clues-q2-split") {
字符串 split 用错了逗号
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
Permission 一词直接指向权限类别。
}

@Feedback(when: "incorrect", title: "读关键词", tone: "warning", accent: "amber") {
permission 与字段切割无关。
}
}
