首页要展示留言，服务器向数据库**查询**符合条件的记录，再交给模板或 API 输出。

```text
请求首页
  ↓
查询最近留言
  ↓
得到一排记录
```

查询可以按时间排序、限制条数，避免一次拖出全部历史。

## 读与写对称

写是插入/更新；读是按条件取回。两者都经服务器，不让浏览器直接拿着数据库口令去查。

## 落到「小记」上

首页不是「把数据库整张表倒给浏览器」，而是服务器按条件查询——例如按时间倒序取最近 `20` 条。

## 读与写对称

```text
写：插入或更新
读：按条件取回
```

两者都经服务器；浏览器不应持有数据库口令直接查。

## 条件从需求来

「最近」「我的」「某条详情」都会变成查询条件。先用中文写清要哪些行，再落到程序与数据库语句。

回到本页的目标：围绕「怎样从数据库读取并展示数据？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "先查询再展示", tone: "information", accent: "mint") {
列表页的数据来自服务器对数据库的查询结果。
}

@Quiz(id: "web-db-read-page-query.quiz-1", kind: "singleChoice") {
首页应显示最近 20 条。更合理的做法是？

@Option(id: "web-db-read-q1-limit", correct: true) {
查询时排序并限制 20 条

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
在查询侧限制，而不是瞎传全部。
}
}

@Option(id: "web-db-read-q1-all") {
每次取出全部历史再靠运气
}

@Option(id: "web-db-read-q1-client-db") {
把数据库密码给浏览器自己查
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
查询带排序与条数限制。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
浏览器不该直连数据库。
}
}
