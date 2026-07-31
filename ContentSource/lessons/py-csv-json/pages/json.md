接口和配置文件常出现 `.json`。它也是文本，形状接近 Python 的字典与列表：**花括号装键值，方括号装数组**。

## 长什么样

```text
{
  "语文": 40,
  "数学": 25,
  "备注": ["晨读", "练习"]
}
```

可以一层套一层：值还可以是对象或数组。这是 CSV 不擅长的地方。

## 和字典的直觉

读 JSON 时，可以把它想成「可嵌套的字典/列表的文本写法」。Python 有标准库把它和字典互相转换（识别即可，API 细节后练）。

## 怎样选

| 数据形状 | 更常选 |
| --- | --- |
| 整齐二维表 | CSV |
| 嵌套字段、列表套对象 | JSON |

@Callout(title: "JSON 擅长嵌套", tone: "information", accent: "mint") {
键值与列表可以层层组合；适合结构不那么「一张扁表」的数据。
}

@Quiz(id: "py-csv-json-json.quiz-1", kind: "singleChoice") {
数据里既有各科分钟，又有备注列表。更贴哪类格式的强项？

@Option(id: "py-csv-json-json-q1-json", correct: true) {
JSON，因为能嵌套数组和对象
}

@Option(id: "py-csv-json-json-q1-csv-only") {
只能 CSV，因为一切数据都必须是两列
}

@Option(id: "py-csv-json-json-q1-set") {
集合文件，因为集合也能嵌套字典
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
嵌套结构是 JSON 的舒适区。
}

@Feedback(when: "incorrect", title: "想层级", tone: "warning", accent: "amber") {
扁表用 CSV；有列表套在对象里，看 JSON。
}
}

@Quiz(id: "py-csv-json-json.quiz-2", kind: "singleChoice") {
JSON 与 CSV 的共同点是？

@Option(id: "py-csv-json-json-q2-text", correct: true) {
都是带结构约定的文本，可用文本方式存储与传输
}

@Option(id: "py-csv-json-json-q2-same-shape") {
形状完全相同，只是扩展名不同
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
都是文本；差别在约定的结构形状。
}

@Feedback(when: "incorrect", title: "形状不同", tone: "warning", accent: "amber") {
表格 vs 嵌套，正是选型依据。
}
}
