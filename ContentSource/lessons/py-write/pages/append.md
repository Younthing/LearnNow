打开模式决定旧内容的命运。

## 两种常见模式

| 模式 | 效果 |
| --- | --- |
| `"w"` | 写入；文件已存在则 **清空再写** |
| `"a"` | **追加** 到末尾，保留原有内容 |

每日打卡通常要保留历史，用 `"a"` 追加一行；若要生成全新报告，才用 `"w"`。

```python
with open("study.txt", "a", encoding="utf-8") as f:
    f.write("数学,25\n")
```

```text
原有多行
  ↓ a 追加
末尾多一行新记录
```

## 选错模式的代价

本想追加却用了 `"w"`，历史记录会消失。写文件前先问：旧内容还要不要？

@Callout(title: "先问旧内容要不要", tone: "warning", accent: "amber") {
`"w"` 会覆盖；要保留历史就用 `"a"` 追加。
}

@Quiz(id: "py-write-append.quiz-1", kind: "singleChoice") {
`study.txt` 已有一周记录，你只想再记今天一行。应选？

@Option(id: "py-write-append-q1-a", correct: true) {
以 "a" 追加打开，写入新行
}

@Option(id: "py-write-append-q1-w") {
以 "w" 打开，因为写入都必须用 w
}

@Option(id: "py-write-append-q1-r") {
以 "r" 打开，因为读取模式也能写
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
保留历史 → 追加。
}

@Feedback(when: "incorrect", title: "看旧文件还要不要", tone: "warning", accent: "amber") {
w 会清空；r 是读。追加用 a。
}
}

@Quiz(id: "py-write-append.quiz-2", kind: "singleChoice") {
误用 `"w"` 打开已有日志并 write 一行，最可能的后果是？

@Option(id: "py-write-append-q2-lost", correct: true) {
旧内容被清空，文件里主要只剩这次写入
}

@Option(id: "py-write-append-q2-merge") {
新旧内容自动完美合并且永不丢失
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
w 的「写」从空文件开始。历史要自己负责保留。
}

@Feedback(when: "incorrect", title: "w 不是合并", tone: "warning", accent: "amber") {
合并感来自 a；w 是重写。
}
}
