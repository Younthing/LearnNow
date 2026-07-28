t检验是比较均值差异的核心工具，适合小样本且总体方差未知的场景。

@Callout(title: "核心认知", tone: "warning", accent: "amber") {
数据只是轻微偏态时，t检验通常仍然具有不错的稳健性。
}

```python
from scipy import stats
t, p = stats.ttest_ind(a, b, equal_var=False)
```

@Quiz(id: "hypothesis-page-1.quiz", kind: "singleChoice") {
只有 25 个样本且总体方差未知，数据轻微左偏，可以尝试 t检验吗？

@Option(id: "strict-normality") {
绝对不行，必须严格正态
}

@Option(id: "t-test-robust", correct: true) {
可以，t检验通常具备稳健性
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
轻微偏态通常不会让 t 检验立即失效，但仍应检查异常值和样本条件。
}

@Feedback(when: "incorrect", title: "区分理想条件与稳健性", tone: "warning", accent: "amber") {
正态性是常用假设，但轻微偏离并不等于方法绝对不可用。
}
}
