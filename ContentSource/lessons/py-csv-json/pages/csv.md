很多导出文件叫 `.csv`。它本质仍是文本，但约定：**一行一条记录，字段用逗号分开**，像一张表。

## 长什么样

```text
科目,分钟
语文,40
数学,25
```

第一行常常是表头，后面每行一条。用 `split(",")` 也能拆，正式项目更常用专用模块，但形状要先认清。

## 适合什么

字段固定、像表格——科目与分钟、日期与分数。嵌套很深的树状数据，用 CSV 会别扭。

```text
表头：科目 | 分钟
行1 ：语文 | 40
行2 ：数学 | 25
```

@Callout(title: "CSV 是表格的文本版", tone: "information", accent: "mint") {
一行一条，字段用逗号分隔；适合整齐的行列数据。
}

@Quiz(id: "py-csv-json-csv.quiz-1", kind: "singleChoice") {
下面哪段更像 CSV 的数据形状？

@Option(id: "py-csv-json-csv-q1-table", correct: true) {
多行「科目,分钟」，像一张表
}

@Option(id: "py-csv-json-csv-q1-deep") {
一层套一层、字段名到处不同的深树，且难以对齐成列
}

@Option(id: "py-csv-json-csv-q1-bin") {
无法用记事本打开的纯二进制图片
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
CSV 的识别特征就是表格感的纯文本。
}

@Feedback(when: "incorrect", title: "看齐不齐列", tone: "warning", accent: "amber") {
列对齐的文本表 → CSV；深嵌套或非文本 → 不是它的主场。
}
}

@Quiz(id: "py-csv-json-csv.quiz-2", kind: "singleChoice") {
CSV 文件用记事本打开，你通常会看到？

@Option(id: "py-csv-json-csv-q2-text", correct: true) {
可读的文本行列，而不是神秘的不可见格式
}

@Option(id: "py-csv-json-csv-q2-exe") {
可执行程序代码，双击就会运行 Python
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
CSV 是结构化约定下的文本文件。
}

@Feedback(when: "incorrect", title: "它还是文本", tone: "warning", accent: "amber") {
扩展名不让它变成程序；约定的是内容形状。
}
}
