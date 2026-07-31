同样一批数据，组织成数组、链表、栈或队列后，**同名操作的成本会变**。效率不是数据自己的属性，而是「结构 + 操作」的组合。

## 相对效率

「快」必须带上操作名：按下标读？中间插？只在一端进？

```text
同一批步数
├─ 数组组织 → 下标读便宜
└─ 链表组织 → 中间插更灵活
```

## 与第四单元呼应

算法步骤量重要；数据结构决定哪些步骤天然少、哪些步骤被迫多。

## 同一批数据，两种账单

步数既可以放数组，也可以放链表。数据相同，**按下标读**与**中间插入**的成本却对调。

所以效率比较必须写成「在操作 X 上，结构 A 比结构 B …」，不能只喊结构名。

@Callout(title: "相对具体操作", tone: "information", accent: "purple") {
没有离开操作谈「这个结构绝对更快」。
}

@Quiz(id: "cs-mem-org-efficiency-ops.quiz-1", kind: "singleChoice") {
有人说「链表比数组更快」。按这一页，缺了什么？

@Option(id: "cs-mem-org-efficiency-ops-q1-op", correct: true) {
缺少具体操作：更快的是插入、下标读，还是别的？

@Feedback(title: "补上操作名", tone: "success", accent: "mint") {
结构优势总是绑在某类操作上。
}
}

@Option(id: "cs-mem-org-efficiency-ops-q1-true") {
这句话在任何操作下都永远成立
}

@Option(id: "cs-mem-org-efficiency-ops-q1-bit") {
只需比较它们的比特颜色
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
先问操作，再比快慢。
}

@Feedback(when: "incorrect", title: "点名操作", tone: "warning", accent: "amber") {
把句子改成「在……操作上更快」再判断。
}
}
