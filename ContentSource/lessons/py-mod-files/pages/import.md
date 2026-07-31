文件拆开了，主程序怎样用到库里的函数？

用 **`import`**：把另一个 `.py` 当作模块引入，再通过模块名调用其中的函数。

## 最小例子

`study_lib.py`：

```python
def is_done(minutes):
    return minutes >= 30
```

`main.py`：

```python
import study_lib

if study_lib.is_done(40):
    print("达标")
```

```text
main.py
  └─ import study_lib
       └─ 使用 study_lib.is_done(...)
```

## 名字从哪来

`import study_lib` 之后，默认用 `study_lib.函数名` 访问。这样能看清函数来自哪个模块，避免同名撞车。

## 运行哪一个

通常运行的是主文件 `main.py`。库文件自己一般不当入口反复手工开——它是被引入的工具箱。

@Callout(title: "引入后再点名使用", tone: "information", accent: "mint") {
`import 模块` 把另一文件的工具接进来；用 `模块.函数` 调用。
}

@Quiz(id: "py-mod-files-import.quiz-1", kind: "singleChoice") {
`import study_lib` 之后，调用 `is_done` 更稳妥的写法是？

@Option(id: "py-mod-files-import-q1-qual", correct: true) {
`study_lib.is_done(40)`，带上模块名
}

@Option(id: "py-mod-files-import-q1-bare") {
直接写 `is_done(40)`，import 会自动省略前缀
}

@Option(id: "py-mod-files-import-q1-file") {
写 `study_lib.py.is_done(40)`，必须带扩展名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
普通 import 后，用模块名限定函数来源。
}

@Feedback(when: "incorrect", title: "看 import 带来的名字", tone: "warning", accent: "amber") {
`import study_lib` 引入的是模块名，不是自动把函数倒进当前命名空间。
}
}

@Quiz(id: "py-mod-files-import.quiz-2", kind: "singleChoice") {
你改了 `study_lib.py` 里的达标阈值，`main.py` 没改。再次运行 main 后？

@Option(id: "py-mod-files-import-q2-new", correct: true) {
会用到新规则，因为运行时会导入当前的库文件
}

@Option(id: "py-mod-files-import-q2-old") {
永远沿用旧规则，除非把库文件改名
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
导入的是现有文件内容。改库、再运行主程序，新规则生效。
}

@Feedback(when: "incorrect", title: "再跑一次主程序", tone: "warning", accent: "amber") {
规则的来源在库文件。库更新后，导入方无需复制那一行阈值。
}
}
