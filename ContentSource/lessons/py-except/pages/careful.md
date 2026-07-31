`except` 可以写得很宽，宽到把所有异常吞掉并假装没事——这通常更糟。

## 针对类型

```python
try:
    minutes = int(raw)
except ValueError:
    print("请输入数字")
```

这里只处理 ValueError。若是别的严重问题，仍应暴露出来，而不是被同一句「请输入数字」盖住。

## 裸吞的代价

```text
except:          # 太宽
    pass         # 假装没发生
```

真实 bug 被藏起来，你失去了 traceback 这张地图。教学与实务都建议：能写明类型就写明；接住后至少留下提示或日志。

## 和「文件失败」的衔接

上一单元说失败有类别。`except FileNotFoundError` 处理找不到文件；`except ValueError` 处理转换——类型对上类别，预案才准确。

@Callout(title: "接住，但别捂死", tone: "warning", accent: "amber") {
针对具体异常给出路；不要用空的万能 except 把问题藏起来。
}

@Quiz(id: "py-except-careful.quiz-1", kind: "singleChoice") {
为什么更推荐 `except ValueError` 而不是笼统 `except:` 后 `pass`？

@Option(id: "py-except-careful-q1-specific", correct: true) {
只处理你想处理的失败，其他问题仍能暴露
}

@Option(id: "py-except-careful-q1-slow") {
因为 ValueError 跑得比较慢，更安全
}

@Option(id: "py-except-careful-q1-forbid") {
Python 禁止写 except:
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
针对性保留了其他错误的可见性。
}

@Feedback(when: "incorrect", title: "想的是可见性", tone: "warning", accent: "amber") {
宽 except + pass 会藏 bug；语言也未必禁止，但不应滥用。
}
}

@Quiz(id: "py-except-careful.quiz-2", kind: "singleChoice") {
找不到 study.txt 时，更贴切的捕获是？

@Option(id: "py-except-careful-q2-fnf", correct: true) {
针对 FileNotFoundError（或等价的文件缺失异常）给提示
}

@Option(id: "py-except-careful-q2-value") {
一律 except ValueError，因为所有失败都是值错误
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
异常类型应对准失败类别。
}

@Feedback(when: "incorrect", title: "对上号", tone: "warning", accent: "amber") {
找不到文件不是 int 转换那种 ValueError。
}
}
