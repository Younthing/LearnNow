方差衡量每个观测值与均值之间的平方偏差，值越大通常表示数据越分散。

@Callout(title: "理解方式", tone: "information", accent: "mint") {
标准差是方差的平方根，与原数据保持相同量纲，通常更容易解释。
}

@Quiz(id: "stats-page-2.quiz", kind: "singleChoice") {
两组数据均值相同，但第二组的数值更分散，哪组方差更大？

@Option(id: "variance-second", correct: true) {
第二组
}

@Option(id: "variance-same") {
一定相同
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
第二组观测值离均值更远，平方偏差更大，因此方差也更大。
}

@Feedback(when: "incorrect", title: "关注离均值的距离", tone: "warning", accent: "amber") {
均值相同不代表离散程度相同；比较每组数据与均值之间的偏差。
}
}
