上一页把任务拆成输入、处理、输出。现在问：是谁规定「这一次做加法」？

规定步骤的是一份**可替换的清单**。人把顺序写清楚，机器按清单执行。这份清单就是程序。

## 同一台机器，多份清单

同一部手机可以记账、放歌、导航。变的不是机身，而是它正在照着哪份清单走。

```text
同一部手机
├─ 照着记账步骤  →  记账机
├─ 照着放歌步骤  →  播放机
└─ 照着导航步骤  →  导航仪
```

## 程序写的是顺序，不是心情

清单要写得机器能逐步执行：先读哪个数、做哪种运算、结果放到哪。写「尽量算对」机器没法执行。

| 写法 | 机器能不能做 | 原因 |
| --- | --- | --- |
| 把两个输入相加 | 能 | 步骤明确 |
| 算出一个好看的数 | 不能 | 没有可执行规则 |
| 显示处理结果 | 能 | 输出步骤清楚 |

@Callout(title: "换清单就换任务", tone: "information", accent: "mint") {
硬件提供执行能力；**程序**决定这一次具体做什么。
}

@Quiz(id: "cs-info-task-program.quiz-1", kind: "singleChoice") {
一部手机既能当计算器又能放音乐。按这一页的说法，关键差别是什么？

@Option(id: "cs-info-task-program-q1-list", correct: true) {
它正在执行的步骤清单不同

@Feedback(title: "清单决定角色", tone: "success", accent: "mint") {
机身还在，换了程序，任务就换了。
}
}

@Option(id: "cs-info-task-program-q1-chip") {
放音乐时必须换一块完全不同的芯片
}

@Option(id: "cs-info-task-program-q1-feel") {
手机自己体会你现在想算数还是想听歌
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
通用设备的价值，正在于同一套硬件能加载不同程序。
}

@Feedback(when: "incorrect", title: "先分硬件和清单", tone: "warning", accent: "amber") {
问自己：没换零件却换了功能时，变的是哪一份说明？
}
}
