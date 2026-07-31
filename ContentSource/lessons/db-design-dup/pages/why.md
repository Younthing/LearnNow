会员下了三笔订单。若每笔订单行都复制一遍姓名、电话、地址，改电话就要改三处——漏改一处就分裂真相。

**减少重复**，就是让同一事实尽量只存一份，其它地方用标识去引用。

## 重复怎样产生

把会员资料嵌进每一笔订单：

```text
订单1：阿明 138… 拿铁
订单2：阿明 138… 美式
订单3：阿明 138… 手冲
```

电话出现三次。一处更新失败，就会出现「同一人两个电话」。

## 改成引用

会员表只存一份资料；订单表只存 `会员主键` 与订单自己的字段。改电话只改会员表一行。

```text
会员表：M001 阿明 138…
订单表：订单只记 M001 + 品项金额…
```

@Callout(title: "同一事实只存一份", tone: "information", accent: "amber") {
其它地方存主键引用，而不是复制整段资料。
}

@Quiz(id: "db-design-dup.quiz-1", kind: "singleChoice") {
三笔订单里都写了完整电话。阿明换号后只改了两笔。这暴露了什么设计问题？

@Option(id: "db-design-dup-q1-copy", correct: true) {
同一事实被复制多份，更新无法一次完成

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
重复存储导致更新异常。
}
}
@Option(id: "db-design-dup-q1-pk") {
主键太多了
}
@Option(id: "db-design-dup-q1-null") {
电话不能为 NULL 导致的
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
复制会制造多份真相。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
自检：电话若只存在会员表，改一处是否全部订单都通过引用看到新号？
}
}
