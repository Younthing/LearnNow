`if/else` 像分岔路口：这一次执行，你只会走进其中一条路。

这能避免「达标」和「未达标」同时出现——除非你故意写了两条互不相关的 `if`。

## 互斥的两条路

```text
          条件
         /    \
       是      否
       ↓        ↓
     分支 A   分支 B
```

走完 A，就不会在同一轮里再走配对的 else B。

## 多于两种情况

若还要区分「刚好 30」和「远超 30」，可以用 `elif` 把分岔接成一条链：从上到下找第一个为真的条件，走那一段，后面的跳过。

```python
if minutes >= 60:
    print("超标完成")
elif minutes >= 30:
    print("今日达标")
else:
    print("再学一会儿")
```

## 常见误解

以为写了三个 print 就会打印三次。在 if/elif/else 链里，命中一个就结束这条链。

@Callout(title: "一条链，一次命中", tone: "information", accent: "mint") {
配对的 if/elif/else 在同一轮里 **只走一段**；先为真的优先。
}

@Quiz(id: "py-if-exclusive.quiz-1", kind: "singleChoice") {
`minutes = 45`，走上面的 if/elif/else 链，会打印哪句？

@Option(id: "py-if-exclusive-q1-ok", correct: true) {
「今日达标」，因为第一个条件假、第二个真，后面的 else 不再走
}

@Option(id: "py-if-exclusive-q1-all") {
三句都会打印
}

@Option(id: "py-if-exclusive-q1-over") {
「超标完成」，因为 45 也很努力
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
45 ≥ 60 假，45 ≥ 30 真，命中第二段后结束。
}

@Feedback(when: "incorrect", title: "从上到下找第一个真", tone: "warning", accent: "amber") {
先看 ≥60，再看 ≥30。命中谁就停在谁，不要凭感觉跳到「更励志」的那句。
}
}

@Quiz(id: "py-if-exclusive.quiz-2", kind: "singleChoice") {
为什么 if/else 很适合「达标 / 未达标」这种成对说法？

@Option(id: "py-if-exclusive-q2-mutex", correct: true) {
因为两种结论互斥，同一轮只该出现其中一种
}

@Option(id: "py-if-exclusive-q2-fast") {
因为 else 比 if 执行得更快
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
互斥结论配互斥分支，正好对上。
}

@Feedback(when: "incorrect", title: "想的是含义不是速度", tone: "warning", accent: "amber") {
关键是：这两种话不应同时成立，所以用互斥分支。
}
}
