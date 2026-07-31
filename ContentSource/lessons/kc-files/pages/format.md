柜子里的这段内容被抄回台面之后，还有一个问题没人回答：机器凭什么知道该把它显示成一行数字，而不是一张照片？

靠约定。写下这段内容的 app 按某套规矩排布它，读它的 app 按同一套规矩还原。约定对上了，你就看到本月合计 38；对不上，你看到的就是一堆乱码。

## 同一段内容，两种读法

```text
柜子里的一段内容
├─ 用记账的约定读  →  这个月的每一笔
└─ 用文本的约定读  →  一串看不懂的字符
```

内容一个字都没变，两次的差别只在于你请谁、按哪套约定去读。

## 后缀是提示，不是内容

名字末尾的 `.txt`、`.jpg` 是给人和系统看的提示，系统靠它猜该请哪个 app 来打开。很多格式还会在内容开头写一小段说明自己是什么的记号，但那也只是提示：真正读懂它，仍然要靠 app 认识这套约定。

提示写错了不会改动内容，只会让系统请错人来读。

## 这条线通向哪里

四课下来，一次记账已经走完全程：输入进来，CPU 照清单处理，系统分配和代办，最后抄进柜子留一个名字。

还剩最后一层没打开——那段内容本身是怎么被写下来的，文字、颜色、声音怎么变成机器存得下的东西。那是后面一门专门讲表示的课。

@Callout(title: "内容不自带读法", tone: "information", accent: "purple") {
同一段内容读出什么，取决于用哪套约定去读它。
}

@Quiz(id: "kc-files-format.quiz-1", kind: "singleChoice") {
你不小心把一张照片的后缀从 `.jpg` 改成了 `.txt`，双击后打开的是文本 app，满屏乱码。现在你想看这张照片，哪个做法最靠得住？

@Option(id: "kc-files-format-q1-rename-back", correct: true) {
把后缀改回 `.jpg`，或者直接用看图的 app 打开这个文件

@Feedback(title: "内容一直在", tone: "success", accent: "mint") {
乱码那一次只是被读错了，柜子里那段内容从头到尾没动过。
}
}

@Option(id: "kc-files-format-q1-lost") {
没办法了，它已经变成一个文本文件，照片回不来了
}

@Option(id: "kc-files-format-q1-copy-paste") {
把乱码全选复制，粘贴进看图的 app，让它重新拼回照片
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
改后缀只换了「该请谁来读」。请对了人，看到的还是原来那张照片。
}

@Feedback(when: "incorrect", title: "先问内容动过没有", tone: "warning", accent: "amber") {
你可能以为改名字连内容一起改了。自检办法：改后缀这个动作只碰到了名字，那段内容当时根本没被打开过。
}
}

@Quiz(id: "kc-files-format.quiz-2", kind: "singleChoice") {
同事发来一份文件，你的 app 提示「格式不支持」。按这一页的模型，最合理的判断是什么？

@Option(id: "kc-files-format-q2-unknown-convention", correct: true) {
你的 app 不认识写下这段内容时用的那套约定，所以还原不出来
}

@Option(id: "kc-files-format-q2-rename") {
把后缀改成你的 app 认识的那个就能正常打开了
}

@Option(id: "kc-files-format-q2-empty") {
这个文件里其实是空的，没有内容可读
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
这种时候要找的是一个认识这套约定的 app，或者请对方换一种双方都认的约定导出。
}

@Feedback(when: "incorrect", title: "后缀不是钥匙", tone: "warning", accent: "amber") {
你可能指望改名字能解决问题。自检办法：改后缀只换了「请谁来读」，读的人还是不认识那套约定。
}
}
