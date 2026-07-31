选择方法时问：这次主要是「拿来看」还是「送出并让服务器改状态」？

| 场景 | 更常选 |
| --- | --- |
| 打开详情页 | GET |
| 发布留言 | POST |
| 搜索关键字（仅查询） | 常为 GET |

## 误用的味道

用 GET 把整篇留言塞进 URL，又长又易泄露在历史记录里；用 POST 去「只读一张公开图片」也别扭。意图对齐，方法才对。

## 选择口诀

```text
主要是拿来看  →  GET
主要是送去改  →  POST
```

## 误用的味道

用 GET 把长文塞进地址栏，既难看又易泄露；用 POST 去「只读一张公开图」也别扭。先写清意图，再选方法。

| 场景 | 更常选 |
| --- | --- |
| 打开详情 | GET |
| 发布留言 | POST |
| 关键字搜索（仅查询） | 常为 GET |

## 和表单课接上

HTML 表单提交「发布留言」时，方法常选 POST，正是因为意图是提交处理，而不是单纯取回一页。

回到本页的目标：围绕「GET 和 POST 有什么区别？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "按意图选方法", tone: "information", accent: "mint") {
先问是取回还是提交处理，再选 GET 或 POST。
}

@Quiz(id: "web-server-get-post-page-choose.quiz-1", kind: "singleChoice") {
「发布留言」应优先选哪一种？

@Option(id: "web-server-get-post-q2-post", correct: true) {
POST：提交数据并创建

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
创建资源是提交处理。
}
}

@Option(id: "web-server-get-post-q2-get") {
GET：把全文放进地址栏反复刷新
}

@Option(id: "web-server-get-post-q2-css") {
用 CSS 的 POST 属性
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
发布是提交，用 POST。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
刷新地址栏不应重复创建留言——这也是意图差异的实践理由之一。
}
}
