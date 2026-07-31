有些能力标准库没有，或社区包更合适——这就是 **第三方模块**。

它们不随 Python 默认装全，通常要先安装（常见工具是 `pip`），然后才能 `import`。

## 路径对比

| 来源 | 使用前 |
| --- | --- |
| 你自己的 `.py` | 放对位置即可 import |
| 标准库 | 直接 import |
| 第三方 | **先安装**，再 import |

```text
pip 安装包
  ↓
import 包名
  ↓
调用其函数
```

## 选型顺序

1. 自己几行能写清吗？  
2. 标准库有吗？  
3. 才考虑第三方，并留意维护与许可。

安装后的 import 写法，与导入自己的模块感觉类似，但名字来自包作者。

@Callout(title: "第三方多一步安装", tone: "information", accent: "mint") {
标准库开箱即用；第三方通常 **先安装** 再 import。
}

@Quiz(id: "py-stdlib-third.quiz-1", kind: "singleChoice") {
`import requests` 失败，提示没有这个模块。最可能缺的是？

@Option(id: "py-stdlib-third-q1-install", correct: true) {
还没有在当前环境安装这个第三方包
}

@Option(id: "py-stdlib-third-q1-colon") {
一定是某一行少了冒号的语法错误
}

@Option(id: "py-stdlib-third-q1-list") {
因为列表写错了，与安装无关
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
第三方未安装时，import 会找不到模块。
}

@Feedback(when: "incorrect", title: "看「没有这个模块」", tone: "warning", accent: "amber") {
这类提示优先怀疑环境里没装，而不是冒号。
}
}

@Quiz(id: "py-stdlib-third.quiz-2", kind: "singleChoice") {
需要某功能时，更稳妥的顺序是？

@Option(id: "py-stdlib-third-q2-order", correct: true) {
先考虑自己能写清 / 标准库，再考虑安装第三方
}

@Option(id: "py-stdlib-third-q2-all-pip") {
无论什么需求，先 pip 安装十个包再说
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
依赖越少，环境问题面越小。
}

@Feedback(when: "incorrect", title: "克制依赖", tone: "warning", accent: "amber") {
包不是越多越专业；对齐需求再装。
}
}
