嵌套难在同时记忆。对策不是禁止嵌套，而是 **能浅则浅**：先处理「直接跳过」的情况，把深逻辑留在更少的缩进里。

## 用 continue 提前跳过

```python
for m in minutes_list:
    if m <= 0:
        continue
    if m >= 30:
        print("达标", m)
    else:
        print("未达标", m)
```

无效数据在门口拦住，后面只处理有效分钟，少了一层「包在 if m>0 里面」。

```text
m ≤ 0？ → 跳过本轮
否则     → 再判断达标
```

## 其他减层办法（先认识）

把内层整段判断提成一个函数（下一单元），调用处只剩一行。或把「守卫条件」写在前面，正常路径保持直。

## 原则

需要嵌套时嵌套；但每加一层，先问：能不能提前跳过或拆走？少一层，大脑就少一张便签。

@Callout(title: "门口先拦，里面更直", tone: "information", accent: "mint") {
能用提前跳过减掉的层，就不要继续往里包。
}

@Quiz(id: "py-nest-flatten.quiz-1", kind: "singleChoice") {
把 `if m <= 0: continue` 放在循环开头，主要好处是？

@Option(id: "py-nest-flatten-q1-shallow", correct: true) {
后面的达标判断少包一层，正常路径更直
}

@Option(id: "py-nest-flatten-q1-faster-cpu") {
CPU 会因此永久加速十倍
}

@Option(id: "py-nest-flatten-q1-delete-if") {
从此再也不需要任何 if
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
守卫放前面，是为了降低嵌套，不是消灭判断。
}

@Feedback(when: "incorrect", title: "看缩进少了什么", tone: "warning", accent: "amber") {
对比改前改后：达标判断是否还缩在「m>0」里面？
}
}

@Quiz(id: "py-nest-flatten.quiz-2", kind: "singleChoice") {
面对已经三层缩进的代码，更合理的第一反应是？

@Option(id: "py-nest-flatten-q2-ask", correct: true) {
问能否提前跳过或拆出一段，先减层再改逻辑
}

@Option(id: "py-nest-flatten-q2-deeper") {
再套一层 if，把所有情况包得更严实
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先降复杂度，再改业务，通常更安全。
}

@Feedback(when: "incorrect", title: "更深通常更糟", tone: "warning", accent: "amber") {
默认方向应是减层，而不是继续往里包。
}
}
