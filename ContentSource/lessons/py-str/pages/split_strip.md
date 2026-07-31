用户或文件给了一行：`语文,40`。你要科目和分钟分开。

用 **`split`** 按分隔符切开；用 **`strip`** 去掉首尾空格，避免 `"语文 "` 和 `"语文"` 对不上。

## 切开

```python
line = "语文,40"
parts = line.split(",")
subject = parts[0]
raw_minutes = parts[1]
```

`split(",")` 得到 `["语文", "40"]`。再按位置取零件。

```text
「语文,40」
  ↓ split ,
「语文」  「40」
```

## 先清理再比较

```python
subject = parts[0].strip()
```

输入里多打的空格很常见。比较、当字典键之前，先 `strip`，少踩「看起来一样其实不一样」的坑。

@Callout(title: "先切齐，再清理", tone: "information", accent: "mint") {
`split` 把一行拆成零件；`strip` 去掉零件首尾空白再使用。
}

@Quiz(id: "py-str-split.quiz-1", kind: "singleChoice") {
`"语文,40".split(",")` 更可能得到？

@Option(id: "py-str-split-q1-two", correct: true) {
两个字符串："语文" 和 "40"
}

@Option(id: "py-str-split-q1-num") {
一个整数 40
}

@Option(id: "py-str-split-q1-one") {
仍然是一整句，split 只是别名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
按逗号切开，得到字符串列表；数字仍是文本形式的 "40"。
}

@Feedback(when: "incorrect", title: "切完还是文本零件", tone: "warning", accent: "amber") {
要当数字用，切完还得 int。
}
}

@Quiz(id: "py-str-split.quiz-2", kind: "singleChoice") {
字典里键是 `"语文"`，你却用 `"语文 "`（多了空格）去取。更可能怎样？

@Option(id: "py-str-split-q2-miss", correct: true) {
找不到，因为键必须精确匹配；应先 strip
}

@Option(id: "py-str-split-q2-auto") {
Python 会自动忽略所有空格并取到值
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
空白也是字符。比较前清理，能避免这种「看起来一样」。
}

@Feedback(when: "incorrect", title: "空格也算内容", tone: "warning", accent: "amber") {
键匹配是精确的。多一个空格就是另一个键。
}
}
