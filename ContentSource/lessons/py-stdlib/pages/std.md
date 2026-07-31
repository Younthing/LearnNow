算平方根、读 JSON、处理日期——很多能力不必从零造。

**标准库**随 Python 一起提供。确认名字后，直接 `import` 即可。

## 例子

```python
import math
import json

print(math.sqrt(9))
data = json.loads('{"语文": 40}')
```

`math`、`json`、`datetime`、`pathlib` 等都是常见成员。文档描述「标准库」的部分，就是这份自带工具箱。

```text
Python 安装
  └─ 标准库（math / json / ...）
       └─ import 后使用
```

## 先问有没有现成的

动手写复杂文件解析前，先查标准库是否已有模块。少依赖、少安装，问题面更小。

@Callout(title: "先翻自带工具箱", tone: "information", accent: "mint") {
标准库 **不用另行安装**；能解决的优先用它。
}

@Quiz(id: "py-stdlib-std.quiz-1", kind: "singleChoice") {
`import math` 成功，通常说明？

@Option(id: "py-stdlib-std-q1-bundled", correct: true) {
math 属于标准库，随 Python 提供
}

@Option(id: "py-stdlib-std-q1-must-pip") {
你一定已经手动 pip 安装过 math，否则不可能 import
}

@Option(id: "py-stdlib-std-q1-own") {
math 必须是你项目里的 math.py，否则无效
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
标准库模块开箱即用。
}

@Feedback(when: "incorrect", title: "标准库是自带的", tone: "warning", accent: "amber") {
math 不是靠你临时 pip 才出现的典型例子。
}
}

@Quiz(id: "py-stdlib-std.quiz-2", kind: "singleChoice") {
想读 JSON 文本成字典，更合理的第一步是？

@Option(id: "py-stdlib-std-q2-json", correct: true) {
先看标准库 json 是否够用
}

@Option(id: "py-stdlib-std-q2-rewrite") {
立刻从零实现一套完整 JSON 解析器
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
标准库已有轮子时，优先用轮子。
}

@Feedback(when: "incorrect", title: "先查再造", tone: "warning", accent: "amber") {
教学演示除外；实用路径是先 import json。
}
}
