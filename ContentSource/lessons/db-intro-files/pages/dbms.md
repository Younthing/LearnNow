上一页说：文件放得下，不等于管得住。那「管得住」具体要谁来做？

答案是一类专门的软件：**数据库管理系统**（常简称 DBMS）。你不再直接改一整份文件，而是向它下指令：查谁、改哪一行、加一条记录。

## 它夹在你和数据中间

没有 DBMS 时，你的程序（或表格软件）直接读写文件。有了它，程序说「把电话是 `13800001111` 的积分加 `1`」，DBMS 去定位那一行、改完、再保证写回安全。

```text
你 / 程序
  ↓  下指令（查、改、加、删）
DBMS
  ↓  真正读写磁盘上的数据
数据文件
```

你关心的是「改对那一行」；磁盘怎么排、会不会半路断电写坏，尽量交给它。

## 它替你扛三件事

第一是**查找与修改**：按条件定位记录，而不是整份打开肉眼翻。第二是**并发**：多人同时改时排队或加锁，减少互相覆盖。第三是**规则**：比如电话不能空着——不符合规则的写入会被拒绝。

这三项合起来，才叫「可靠地组织与查询」。日日咖的会员表一旦交给 DBMS，店员改积分就变成一条指令，而不是抢着保存同一个表格文件。

## 边界：它不是自动替你想清楚业务

DBMS 不会替你设计「会员该有哪些字段」。它保证的是：在你定好结构之后，读写按规则发生、冲突有人管。结构怎么设计，后面几课再讲。

@Callout(title: "把脏活交给中间层", tone: "information", accent: "amber") {
你提条件，DBMS 负责定位、改写、尽量不让多人踩踏。
}

@Quiz(id: "db-intro-files-dbms.quiz-1", kind: "singleChoice") {
店员在收银软件里点「积分 +1」。按这一页的模型，真正去改磁盘上那一行的通常是谁？

@Option(id: "db-intro-files-dbms-q1-dbms", correct: true) {
数据库管理系统接到指令后去改对应记录

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
收银软件下指令，DBMS 执行读写。
}
}
@Option(id: "db-intro-files-dbms-q1-clerk") {
店员直接打开后台文件改数字
}
@Option(id: "db-intro-files-dbms-q1-phone") {
手机自己根据电话号码改文件
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
中间多了一层：指令与落盘分离。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：收银界面上你点的是「动作」，还是「打开某个 .txt」？点的是动作，就说明中间有人代劳。
}
}

@Quiz(id: "db-intro-files-dbms.quiz-2", kind: "singleChoice") {
老板问：「装了 DBMS，是不是就不用设计会员要存哪些信息了？」你怎么答？

@Option(id: "db-intro-files-dbms-q2-still-design", correct: true) {
还要设计。DBMS 管读写与规则执行，字段该有哪些仍由人决定

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
工具不替你想业务结构。
}
}
@Option(id: "db-intro-files-dbms-q2-auto") {
不用。DBMS 会自动猜出该存姓名和积分
}
@Option(id: "db-intro-files-dbms-q2-file") {
不用。继续用原来的文本文件就行，DBMS 会自己读懂
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
DBMS 是执行层，不是业务设计层。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：如果从未告诉系统「有积分这一列」，它怎么知道要点 +1 时改哪一格？
}
}
