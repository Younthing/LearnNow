有时循环还没等到条件变假，你就想马上停；有时某一轮数据无效，只想跳过这轮剩下的步骤。

**`break`** 立刻结束整个循环。**`continue`** 结束本轮剩余语句，进入下一轮。

## 遇到结束标记就 break

```python
while True:
    n = int(input("分钟（-1 结束）："))
    if n == -1:
        break
    print("记录", n)
```

`while True` 本身一直为真；真正的出口写在 `break` 上。

## continue：跳过本轮

若输入 `0` 表示「这天忽略」，可以：

```text
读入 n
  ↓
是 0？ → continue（不打印，直接下一轮）
是 -1？ → break
否则 → 打印记录
```

## 别混用两个出口的含义

想停掉整个录入过程 → `break`。想忽略这一条、继续问下一条 → `continue`。

@Callout(title: "停全部还是跳过一条", tone: "information", accent: "mint") {
`break` 结束循环；`continue` 只跳过 **本轮** 剩下的话。
}

@Quiz(id: "py-loop-ctrl-break.quiz-1", kind: "singleChoice") {
循环中执行到 `break` 后，循环体后面的语句还会在本轮执行吗？

@Option(id: "py-loop-ctrl-break-q1-no", correct: true) {
不会。break 立即结束整个循环
}

@Option(id: "py-loop-ctrl-break-q1-yes") {
会。break 只是做个标记，本轮仍跑完
}

@Option(id: "py-loop-ctrl-break-q1-cont") {
不会结束循环，只跳到下一轮，效果等于 continue
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
break 的作用就是马上离开循环。
}

@Feedback(when: "incorrect", title: "和 continue 对比记忆", tone: "warning", accent: "amber") {
continue 去下一轮；break 连下一轮也不要了。
}
}

@Quiz(id: "py-loop-ctrl-break.quiz-2", kind: "singleChoice") {
输入了无效的 0，你想忽略它并继续询问下一天。更该用？

@Option(id: "py-loop-ctrl-break-q2-cont", correct: true) {
continue，跳过本轮剩余步骤，进入下一轮输入
}

@Option(id: "py-loop-ctrl-break-q2-break") {
break，因为无效输入说明整个程序该结束
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
忽略一条、继续问，是 continue 的场景。
}

@Feedback(when: "incorrect", title: "问你还想不想继续录", tone: "warning", accent: "amber") {
还要录下一天，就不要 break 掉整个循环。
}
}
