`study.txt` 常常一行一条：`语文,40`。整份 `read()` 后再手切也可以，但 **按行遍历** 更贴记录结构。

## 逐行循环

```python
with open("study.txt", "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        parts = line.split(",")
        print(parts[0], parts[1])
```

`for line in f` 每次给出一行（通常带换行符），所以先 `strip`。

```text
第 1 行 → 处理
第 2 行 → 处理
空行    → 跳过
```

## 一行一个故事

把「一行」约定成一条记录，读写双方就对齐了。下一课写入时，也会按行追加。

@Callout(title: "一行一条记录", tone: "information", accent: "mint") {
按行遍历文件，对每行 strip 后再 split，是文本日志的常用读法。
}

@Quiz(id: "py-read-lines.quiz-1", kind: "singleChoice") {
为什么逐行读取后常常先 `strip`？

@Option(id: "py-read-lines-q1-newline", correct: true) {
去掉换行和首尾空白，避免零件里藏着看不见的字符
}

@Option(id: "py-read-lines-q1-delete") {
strip 会删除整行内容，所以必须调用
}

@Option(id: "py-read-lines-q1-int") {
strip 能把文本变成整数
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
行尾换行是文件行的常态，清理后再拆字段更稳。
}

@Feedback(when: "incorrect", title: "strip 只去首尾空白", tone: "warning", accent: "amber") {
它不负责删整行，也不负责 int 转换。
}
}

@Quiz(id: "py-read-lines.quiz-2", kind: "singleChoice") {
文件有三行有效记录。按行 for 循环处理时，循环体大概跑几次？

@Option(id: "py-read-lines-q2-three", correct: true) {
约三次，一行一轮（空行若跳过则不计）
}

@Option(id: "py-read-lines-q2-one") {
固定一次，因为打开文件只算一次读取
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
按行迭代时，行数驱动轮数。
}

@Feedback(when: "incorrect", title: "对照 for line in f", tone: "warning", accent: "amber") {
打开是一次，但 for 会对每一行进入循环体。
}
}
