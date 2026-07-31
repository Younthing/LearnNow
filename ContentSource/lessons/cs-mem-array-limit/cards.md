@Card(id: "cs-mem-array-limit-card-insert", revision: 1, sourcePage: "cs-mem-array-limit-page-fixed", topic: "数组局限", accent: "purple", frontTitle: "数组中间插入为何贵", frontSubtitle: "原因", backTitle: "后续元素需要搬移腾位") {
连续的代价。

@Highlight {
插入快慢，取决于要搬多少。
}
}

@Card(id: "cs-mem-array-limit-card-when", revision: 1, sourcePage: "cs-mem-array-limit-page-when", topic: "选型", accent: "amber", frontTitle: "数组仍然擅长什么", frontSubtitle: "场景", backTitle: "稳定长度下的下标随机访问") {
灵活不是唯一目标。

@Highlight {
读得多、插得少时，数组很合适。
}
}
