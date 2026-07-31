形式有了，还不够。同一串符号，双方若用不同规则解释，含义会分叉。

## 含义不自带

`01` 本身不是「开」或「关」。是你们事先约定：`01` 表示开，还是表示关。

```text
同一串 01
├─ 约定 A  →  解释为「开」
└─ 约定 B  →  解释为「关」
```

## 共享约定才能沟通

发「到了」能成功，是因为发送方和接收方对「这些字符代表什么」有共享规则。丢了约定，只剩一串无法可靠解读的状态。

| 有什么 | 能否可靠沟通 | 原因 |
| --- | --- | --- |
| 形式 + 共享约定 | 能 | 双方同一解释 |
| 只有形式 | 不能 | 解释可能冲突 |
| 只有想法 | 不能 | 机器侧无输入 |

@Callout(title: "约定给含义", tone: "warning", accent: "amber") {
数据**不自带**含义；含义来自双方承认的解释规则。
}

@Quiz(id: "cs-info-why-convention.quiz-1", kind: "singleChoice") {
两边都保存了同一串符号，却一个读成「开」、一个读成「关」。问题出在哪？

@Option(id: "cs-info-why-convention-q1-rule", correct: true) {
双方使用的解释约定不一致

@Feedback(title: "形式相同，约定不同", tone: "success", accent: "mint") {
先对齐规则，再谈谁的设备坏了。
}
}

@Option(id: "cs-info-why-convention-q1-magic") {
符号自己长出了两种互相打架的含义
}

@Option(id: "cs-info-why-convention-q1-copy") {
复制时必须改变符号，否则无法沟通
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
沟通失败常常是约定冲突，不是符号「坏了」。
}

@Feedback(when: "incorrect", title: "查约定表", tone: "warning", accent: "amber") {
两边把同一符号对照各自的解释表，看映射是否一致。
}
}
