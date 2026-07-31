会员表有十万行。按电话查找若每次从头扫到尾，收银会卡。**索引**像目录：按某列的值快速定位到行，而不必全表漫游。

## 目录直觉

```text
没有索引：一页页翻会员表找电话
有电话索引：先在目录找到位置 → 再跳到那一行
```

索引是额外的数据结构，由引擎维护，对你仍用同一个 `WHERE 电话 = …` 查询。

## 它加快的是定位

索引擅长「按条件找到少数行」。要取出绝大部分行，全表扫有时反而更干脆——优化器会选择。

@Callout(title: "索引＝加速定位的目录", tone: "information", accent: "amber") {
用空间和维护换查找时间。
}

@Quiz(id: "db-reli-index.quiz-1", kind: "singleChoice") {
按电话精确查找一位会员，索引如何帮助？

@Option(id: "db-reli-index-q1-locate", correct: true) {
通过电话目录快速定位到行，避免每次全表扫描

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
定位加速。
}
}
@Option(id: "db-reli-index-q1-compress") {
把电话从库中删除以缩小体积
}
@Option(id: "db-reli-index-q1-lock") {
禁止所有人查询电话
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
目录不是删数据。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：书的目录帮你找章，还是把章撕掉？找章。
}
}
