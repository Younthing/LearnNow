@Card(id: "py-mod-files-card-why", revision: 1, sourcePage: "py-mod-files-page-why", topic: "函数与程序组织", accent: "mint", frontTitle: "拆多文件为了什么", frontSubtitle: "程序组织", backTitle: "职责清晰与复用") {
工具函数与主流程分开，查找更容易，也能避免到处复制同一规则。

@Highlight {
一文件一主责。
}
}

@Card(id: "py-mod-files-card-import", revision: 1, sourcePage: "py-mod-files-page-import", topic: "函数与程序组织", accent: "mint", frontTitle: "import 之后怎么调用", frontSubtitle: "模块", backTitle: "模块名.函数名") {
import study_lib 后，用 study_lib.is_done(...) 取用其中的函数。

@Highlight {
运行主文件，库文件当工具箱。
}
}
