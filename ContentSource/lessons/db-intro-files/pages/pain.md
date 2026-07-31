你在「日日咖」用表格软件记会员：姓名、电话、积分。十个人还好管；一百个人、每天改积分，表格就开始乱。

普通文件（表格、文本、记事本）能**存**数据，却很难在数据变多、被多人改、还要按条件找的时候，仍然**可靠**。这一页先讲文件在什么地方会撑不住。

## 文件擅长什么

把会员名单存成一个文件很直观：打开就能看，复制就能备份。数据少、一个人改、偶尔查一眼时，它够用。

```text
会员.txt
├─ 阿明  13800001111  积分 12
├─ 小陈  13900002222  积分 5
└─ ……再往下加
```

问题不在「能不能写进去」，而在写进去之后还要不要**经常改、经常查、多人同时动**。

## 数据一多，三件事一起炸

人一多，你会反复做同一类操作：按电话找人、给积分加 `1`、删掉过期会员。文件不会替你做这些——你得整份打开、自己改、自己存。

更麻烦的是多人改同一份。阿明刚加了积分，小陈同时改电话，后保存的那份可能把前一份**盖掉**。文件通常只保证「整份写完」，不保证「按行安全合并」。

## 文件不是数据库

文件是一段按某种格式排好的内容。数据库要解决的是另一类事：大量记录怎样组织、怎样按条件取回、怎样在多人改动时不互相踩。

| 场景 | 文件通常 | 你真正需要 |
| --- | --- | --- |
| 偶尔看一眼 | 够用 | 打开即可 |
| 每天改几百次 | 易错 | 按条件改一行 |
| 两人同时改 | 易覆盖 | 改动能合并或排队 |

@Callout(title: "存得下 ≠ 管得住", tone: "information", accent: "amber") {
文件解决的是「放得下」；数据一多、一乱、一多人改，你需要的是「找得到、改得准、不互相踩」。
}

@Quiz(id: "db-intro-files.quiz-1", kind: "singleChoice") {
日日咖有 800 个会员。店员每天要按电话改积分，两人共用同一份表格文件。最可能先出问题的是哪一类？

@Option(id: "db-intro-files-q1-concurrency", correct: true) {
两人同时改同一份文件，后保存的一方把另一方的改动盖掉

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
文件常按「整份覆盖」保存，不是按行合并。
}
}
@Option(id: "db-intro-files-q1-space") {
硬盘空间不够，800 行文字存不进去
}
@Option(id: "db-intro-files-q1-phone") {
电话号码太长，文件格式读不懂数字
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
「多人同时改同一份」正是普通文件最容易翻车的地方。
}

@Feedback(when: "incorrect", title: "先分清存不下还是管不住", tone: "warning", accent: "amber") {
自检：假设两人几乎同时点保存，后一份会不会整份盖掉前一份？会，就说明问题不在「放不放得下」。
}
}

@Quiz(id: "db-intro-files.quiz-2", kind: "singleChoice") {
老板说：「我们把会员表复制三份，每人改自己那份。」这能从根本上解决「改动互相覆盖」吗？

@Option(id: "db-intro-files-q2-no", correct: true) {
不能。三份各自改完后，还是要把结果合并回一份真相，合并时仍可能冲突

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
复制只是把冲突推迟到合并那一步。
}
}
@Option(id: "db-intro-files-q2-yes") {
能。每人一份就永远不会互相覆盖
}
@Option(id: "db-intro-files-q2-auto") {
能。复制三次后文件会自动同步成同一份
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
多份副本把「同时写」变成「事后合并」，冲突还在。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：三个人改完，最终以哪一份为准？只要还要合成一份，就仍要处理冲突。
}
}
