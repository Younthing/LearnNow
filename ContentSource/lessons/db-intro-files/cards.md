@Card(id: "db-intro-files-card-limit", revision: 1, sourcePage: "db-intro-files-page-pain", topic: "数据库基础", accent: "mint", frontTitle: "文件何时不够用", frontSubtitle: "放得下却管不住", backTitle: "临界条件") {
数据少、少改、单人用时文件够用；一多、常改、多人同时动，整份覆盖与查找成本就会炸。

@Highlight {
存得下不等于管得住。
}
}

@Card(id: "db-intro-files-card-dbms", revision: 1, sourcePage: "db-intro-files-page-dbms", topic: "数据库基础", accent: "mint", frontTitle: "DBMS 做什么", frontSubtitle: "你下指令，它改数据", backTitle: "中间层") {
数据库管理系统夹在程序与磁盘数据之间：按条件定位、改写，并尽量处理多人冲突。

@Highlight {
它执行规则，不替你设计业务字段。
}
}
