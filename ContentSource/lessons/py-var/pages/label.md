`input` 刚接到「今天学了几分钟」的回答。后面还要打印确认、也许还要判断是否达标——这个数得先 **存住**。

用 **变量**：左边是名字，右边是值，中间的 `=` 表示把名字贴到这个值上。

## 先存，再用

```python
minutes = input("今天学了几分钟？")
print("已记录：", minutes)
```

第一行把输入贴到名字 `minutes` 上；第二行再用这个名字，取回刚才那份内容。

```text
值「40」
  ↑
标签 minutes
```

## 名字是给你自己用的路标

你写成 `m` 也能跑，但 `minutes` 让人一眼看出这是学习分钟。名字不会自动懂中文含义——它只是你选的标签。

## 没有标签就拿不到

如果从未给 `minutes` 赋值，就去 `print(minutes)`，解释器会说它不认识这个名字。先贴标签，再使用。

@Callout(title: "名字是标签", tone: "information", accent: "mint") {
变量名贴在值上；以后写这个名字，就是取 **当前** 贴着的那个值。
}

@Quiz(id: "py-var-label.quiz-1", kind: "singleChoice") {
`minutes = input("今天学了几分钟？")` 之后，`print(minutes)` 打印的是什么？

@Option(id: "py-var-label-q1-value", correct: true) {
刚才输入并贴到 minutes 上的那份内容
}

@Option(id: "py-var-label-q1-prompt") {
提示语「今天学了几分钟？」本身
}

@Option(id: "py-var-label-q1-name") {
单词 minutes 这七个字母
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
print 使用名字时，取的是标签当前指向的值。
}

@Feedback(when: "incorrect", title: "分清标签和值", tone: "warning", accent: "amber") {
自检：把输入从 40 改成 15，print 变不变？变的是值，不是名字本身。
}
}

@Quiz(id: "py-var-label.quiz-2", kind: "singleChoice") {
还没给 `score` 赋值，就写 `print(score)`。按这一页的模型，最可能怎样？

@Option(id: "py-var-label-q2-error", correct: true) {
解释器找不到这个名字对应的值，会报错
}

@Option(id: "py-var-label-q2-zero") {
自动当成 0 打印出来
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
名字要先贴到某个值上，才能被取用。
}

@Feedback(when: "incorrect", title: "别假设有默认值", tone: "warning", accent: "amber") {
Python 不会默默给你一个 0。先赋值，再使用。
}
}
