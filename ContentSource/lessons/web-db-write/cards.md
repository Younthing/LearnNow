@Card(id: "web-db-write-card-path", revision: 1, sourcePage: "web-db-write-page-path", topic: "Web 与数据库", accent: "mint", frontTitle: "表单如何入库", frontSubtitle: "POST→校验→写入", backTitle: "字段对上列") {
通过校验后，服务器把字段写成数据库记录。

@Highlight {
表单 name、程序变量、列名要对齐。
}
}

@Card(id: "web-db-write-card-check", revision: 1, sourcePage: "web-db-write-page-check", topic: "Web 与数据库", accent: "mint", frontTitle: "为何先校验", frontSubtitle: "空与超长", backTitle: "不通过就不写") {
校验失败不应写入；写入失败也要有反馈。

@Highlight {
先验再写，避免脏数据。
}
}
