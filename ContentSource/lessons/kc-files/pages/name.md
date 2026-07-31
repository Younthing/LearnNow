抄进柜子还不够。柜子里堆着成千上万段内容，如果这一份没有名字，明天你怎么把它找出来？

所以保存其实做了两件事：把内容抄一份进柜子，再给这份内容一个名字，并让系统记住它放在哪里。这两样凑齐，就是你平时说的文件。

## 一个文件是两样东西

```text
文件
├─ 名字：记账2026.txt      ← 给人和系统找它用的标签
└─ 内容：这个月的每一笔    ← 你真正要的东西
```

系统另外记着一件事：这个名字对应的内容放在柜子的哪个位置。文件夹就是这份记录的组织方式。

## 名字变了，内容不会变

把 `记账2026.txt` 改名成 `账目.txt`，双击打开，里面一个字都没少。改名动的是标签，内容在柜子里一动没动。

同一条道理反过来也成立：两个文件可以内容一模一样、名字完全不同。名字不参与决定内容是什么。

## 重新打开是怎么发生的

你第二天点开记账，顺序正好和保存相反：系统按名字找到那段内容，把它抄回台面上，CPU 才能接着算。

于是「打开一个大文件要等一会儿」也不奇怪了——那一会儿就是在从柜子往台面搬。

@Callout(title: "两个方向", tone: "information", accent: "purple") {
保存是从台面抄进柜子，打开是从柜子搬回台面。你等的那一会儿，都花在搬上。
}

@Quiz(id: "kc-files-name.quiz-1", kind: "singleChoice") {
记账 app 在屏幕角上闪了一句「已自动保存」。按这一页的模型，它刚刚替你做了什么？

@Option(id: "kc-files-name-q1-copy-and-name", correct: true) {
把台面上这个月的内容抄了一份进柜子，并按一个名字记下它放在哪

@Feedback(title: "两件事一起做", tone: "success", accent: "mint") {
只抄不起名，明天找不回来；只起名不抄，柜子里其实是空的。
}
}

@Option(id: "kc-files-name-q1-keep-in-memory") {
把内容牢牢留在台面上，这样你不小心关掉 app 也不会丢
}

@Option(id: "kc-files-name-q1-keep-app-open") {
让 app 保持在打开状态，只要它不退出内容就一直在
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
「自动保存」这个词里，自动只是说不用你点，保存做的还是那两件事。
}

@Feedback(when: "incorrect", title: "回到断电那一刻", tone: "warning", accent: "amber") {
你选的两项都把东西留在了台面这一边。自检办法：假设此刻断电，你选的做法还救得回内容吗？
}
}

@Quiz(id: "kc-files-name.quiz-2", kind: "singleChoice") {
你把 `账目.txt` 复制了一份，把副本改名叫 `账目备份.txt`。第二天你在原来那份里删掉一笔。备份里那一笔还在吗？

@Option(id: "kc-files-name-q2-two-contents", correct: true) {
还在。复制时柜子里多出了另一段内容，两个名字各自对着一段
}

@Option(id: "kc-files-name-q2-same-content") {
不在。两个名字指的是柜子里同一段内容，改一份就等于改两份
}

@Option(id: "kc-files-name-q2-follows-origin") {
不在。副本会跟着原来那份一起变，这是备份的意思
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
复制动的是内容那一头，改名动的是名字那一头。两个动作管的东西不一样。
}

@Feedback(when: "incorrect", title: "数一数柜子里有几段", tone: "warning", accent: "amber") {
你可能把副本当成了指向同一段内容的另一个名字。自检办法：复制一个大文件要等一会儿，这段等待说明柜子里真的又抄出了一段内容。
}
}
