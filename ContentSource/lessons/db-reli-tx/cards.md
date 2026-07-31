@Card(id: "db-reli-tx-card", revision: 1, sourcePage: "db-reli-tx-page-unit", topic: "数据库基础", accent: "mint", frontTitle: "事务", frontSubtitle: "扣库存写订单", backTitle: "一体") {
事务把多步写入绑成整体：提交则全留，回滚则全无，避免部分完成。

@Highlight {
要么一起成功，要么一起取消。
}
}
