知道是 ValueError 还不够，你要回到 **自己的哪一行**。

## 找文件名与行号

traceback 里会有类似：

```text
File "main.py", line 12, in <module>
    minutes = int(raw)
```

这指出：在 `main.py` 第 12 行，执行 `int(raw)` 时出的事。打开文件，跳到该行，检查 `raw` 当时是什么。

## 必要时向上看一层

若爆炸发生在你调用的函数内部，向上一帧会看到你在主程序里怎么调用它的——参数从哪来的。

```text
主程序调用
  ↓
库函数内炸掉
  ↑ 往上看谁传入了坏数据
```

## 行号是地图，不是判决

有时真正的根因在更早赋值的地方；行号是「爆点」，排查可从爆点往数据来源追。

@Callout(title: "爆点 → 数据来源", tone: "information", accent: "mint") {
行号标出爆炸位置；再问「这个坏值是从哪来的」。
}

@Quiz(id: "py-traceback-line.quiz-1", kind: "singleChoice") {
提示 `File "main.py", line 12` 且该行是 `int(raw)`。你应先做什么？

@Option(id: "py-traceback-line-q1-inspect", correct: true) {
打开 main.py 第 12 行附近，检查 raw 当时的内容
}

@Option(id: "py-traceback-line-q1-delete") {
删除整个 main.py，因为行号出现就代表文件坏了
}

@Option(id: "py-traceback-line-q1-ignore-line") {
行号可以忽略，只看异常类型就够改代码
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
类型定性，行号定位，二者一起用。
}

@Feedback(when: "incorrect", title: "地图要展开", tone: "warning", accent: "amber") {
行号就是让你回到具体语句的。
}
}

@Quiz(id: "py-traceback-line.quiz-2", kind: "singleChoice") {
爆炸在库函数内部，但坏数据是你传入的。向上看调用链是为了？

@Option(id: "py-traceback-line-q2-source", correct: true) {
找到是谁、用什么参数调用进来的
}

@Option(id: "py-traceback-line-q2-ignore-lib") {
证明库永远有错，自己的代码无需检查
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
调用链帮助追数据来源。
}

@Feedback(when: "incorrect", title: "爆点不一定是根因", tone: "warning", accent: "amber") {
库在合法假设下工作；非法参数常来自调用方。
}
}
