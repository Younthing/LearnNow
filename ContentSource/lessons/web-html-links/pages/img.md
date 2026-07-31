留言旁若有配图，用 `img` 这类元素嵌入。图片路径写在 `src` 属性；**必须**用 `alt` 提供替代文字，描述图里是什么。

```text
img
├─ src  图片从哪来
└─ alt  图加载失败或不能看图时的文字说明
```

## 图片是空元素形态

`img` 通常没有「中间夹一段字再结束」的写法，信息都在属性上。这和 `p`、`a` 不同。

## alt 不是可选项（对学习与可访问性）

网络慢或图片失效时，`alt` 仍能告诉用户图想表达什么；读屏软件也依赖它。写「小记」头像时，`alt` 应是「用户阿茶的头像」，而不是 `img1`。

## 落到「小记」上

用户头像或示意图用 `img` 嵌入。网络慢时，`alt` 仍能说明「这是阿茶的头像」，而不是丢下一个破图图标了事。

## 和链接的对比

| 元素 | 关键属性 |
| --- | --- |
| a | href（去哪） |
| img | src（图从哪来）+ alt（图是什么） |

写成完整短句，说明图的作用或内容。文件名、`image1`、空白，都几乎帮不上忙。

回到本页的目标：围绕「链接和图片怎样加入网页？」，你应能用自己的话解释关键判断，并能在「小记」场景里指出对应的那一步。若仍觉得含糊，先复述页面里的模型图，再去做题核对。下一页或下一课会接上新的支撑概念，但不会改掉本页已经立住的那条主线。

@Callout(title: "src 取图，alt 说明", tone: "information", accent: "mint") {
图片靠 src 定位文件，靠 alt 用文字说明图像含义。
}

@Quiz(id: "web-html-links-page-img.quiz-1", kind: "singleChoice") {
「小记」某条留言配了一张示意图，但图暂时加载失败。怎样仍让用户大致明白图的内容？

@Option(id: "web-html-links-q2-alt", correct: true) {
为 img 写清楚的 alt 替代文字

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
失败时替代文字仍可传达含义。
}
}

@Option(id: "web-html-links-q2-href") {
把 src 改成 href 就会自动修好
}

@Option(id: "web-html-links-q2-empty") {
留空 alt，让浏览器自己猜
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
alt 就是给「看不见图」时用的说明。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
href 是链接的事；图片用的是 src 和 alt。
}
}
