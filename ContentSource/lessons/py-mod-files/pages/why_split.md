今日学习程序越写越长：输入、判断、打印、以后还要存文件。全塞在一个 `.py` 里，翻找和复用都会变慢。

**拆文件**的目标不是变多，而是让每个文件主责一件事。

## 一种常见切法

```text
study_lib.py    提供 is_done 等工具函数
main.py         负责提问、调用、打印流程
```

工具函数可被别的程序再次 import；主流程保持短。

## 什么时候该拆

同一组函数开始在多个脚本里复制，或单文件已经让你滚动很久找不到定义——就该拆。为拆而拆、每个函数一个文件，也会碎。

## 拆的是职责，不是随便切开

按「会一起变的东西放一起」切：改达标规则，多半只动库文件；改提问措辞，多半只动主文件。

@Callout(title: "一文件一主责", tone: "information", accent: "mint") {
拆分是为了 **职责清晰** 和复用，不是为了文件数量好看。
}

@Quiz(id: "py-mod-files-why.quiz-1", kind: "singleChoice") {
把 `is_done` 放进 `study_lib.py`、流程放进 `main.py`，最主要的动机是？

@Option(id: "py-mod-files-why-q1-duty", correct: true) {
让判断规则与主流程职责分开，便于查找和复用
}

@Option(id: "py-mod-files-why-q1-must") {
Python 规定超过 10 行必须分文件
}

@Option(id: "py-mod-files-why-q1-hide") {
把错误藏到另一个文件里就不会报错
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
拆分服务的是组织与复用。
}

@Feedback(when: "incorrect", title: "回到为什么拆", tone: "warning", accent: "amber") {
没有行数硬法令。错误也不会因为换文件而消失。
}
}

@Quiz(id: "py-mod-files-why.quiz-2", kind: "singleChoice") {
达标阈值预计会在好几个小程序里用到。更合理的放置是？

@Option(id: "py-mod-files-why-q2-lib", correct: true) {
放进可被 import 的库文件，避免到处复制
}

@Option(id: "py-mod-files-why-q2-copy") {
每个程序里粘贴一份，互不相关更好
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
共享规则适合单处定义、多处导入。
}

@Feedback(when: "incorrect", title: "想想改规则要改几处", tone: "warning", accent: "amber") {
复制五份，改措辞就要找五次。
}
}
