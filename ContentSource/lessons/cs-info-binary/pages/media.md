同一堆比特，文字、图片、声音的**落法**不同。差别在映射，不在「是不是二进制」。

## 三种落法

文字：字符 → 码表中的编号 → 比特。图片：像素颜色 → 数值 → 比特。声音：采样点振幅 → 数值 → 比特。

```text
文字「到」  →  码表编号  →  比特串
小图一角   →  像素颜色  →  比特串
提示音一瞬 →  采样数值  →  比特串
```

## 先认类型，再选规则

保存或打开文件时，系统要知道「按文字表还是按图片规则」。类型信息本身也是一种约定（扩展名、文件头等），服务于选对映射。

| 媒介 | 先切开什么 | 再写成什么 |
| --- | --- | --- |
| 文字 | 字符 | 码表编号 |
| 图片 | 像素 | 颜色数值 |
| 声音 | 采样点 | 振幅数值 |

@Callout(title: "媒介决定映射", tone: "information", accent: "mint") {
都变成比特；**怎么映射**由媒介类型决定。
}

@Quiz(id: "cs-info-binary-media.quiz-1", kind: "singleChoice") {
要把一张小图存进手机，按这一页的路径，第一步通常是什么？

@Option(id: "cs-info-binary-media-q1-pixel", correct: true) {
把画面分成像素，并把颜色写成数值

@Feedback(title: "先切再编码", tone: "success", accent: "mint") {
图片的表示单位是像素颜色，不是字符码表。
}
}

@Option(id: "cs-info-binary-media-q1-ascii") {
直接拿文字码表去套每个像素
}

@Option(id: "cs-info-binary-media-q1-skip") {
跳过数值，让比特自己长出颜色
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
媒介不同，切开的对象就不同。
}

@Feedback(when: "incorrect", title: "对表认媒介", tone: "warning", accent: "amber") {
问：此刻要表示的是字符、颜色，还是声波采样？
}
}
