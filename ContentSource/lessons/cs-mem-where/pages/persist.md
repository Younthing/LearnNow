内存工作台通常**不保证**关机或进程结束后还在。要长期保存，需写入持久存储（文件等）——那是另一条故事线。

## 易失与持久

| 存放 | 典型用途 | 断电后 |
| --- | --- | --- |
| 内存 | 运行中状态 | 通常丢失 |
| 持久存储 | 长期保存 | 仍在 |

```text
运行中的 total
  ↓ 若需保留
写入文件/数据库
```

## 边界提醒

桌面比喻不能解释所有缓存层次；入门抓住：运行用内存，长期另存。

## 保存是另一次写入

「显示在屏幕上」不等于「已保存」。屏幕也是瞬时输出；要跨会话保留，需要把结果写入文件或其它持久介质。

养成习惯：关键结果算完，问一句「只在内存，还是已经落盘？」。

@Callout(title: "工作台会清", tone: "warning", accent: "amber") {
只放在内存里的结果，进程结束或关机后可能消失。
}

@Quiz(id: "cs-mem-where-persist.quiz-1", kind: "singleChoice") {
统计程序算出了今天的总步数，你希望明天还能打开查看。还需要什么？

@Option(id: "cs-mem-where-persist-q1-save", correct: true) {
把结果写入持久存储，而不是只留在内存

@Feedback(title: "长期要另存", tone: "success", accent: "mint") {
内存服务当下运行；跨会话需要持久化。
}
}

@Option(id: "cs-mem-where-persist-q1-hope") {
只要记在内存里并关机，明天一定还在
}

@Option(id: "cs-mem-where-persist-q1-name") {
给变量换个好听的名字即可永久保存
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
分清工作台与长期柜。
}

@Feedback(when: "incorrect", title: "想断电", tone: "warning", accent: "amber") {
工作台清空后，数据还在吗？不在就要另存。
}
}
