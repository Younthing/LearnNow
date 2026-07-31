@Card(id: "cs-prog-functions-card-why", revision: 1, sourcePage: "cs-prog-functions-page-pack", topic: "函数", accent: "purple", frontTitle: "函数如何降复杂度", frontSubtitle: "机制", backTitle: "分层打包细节，并支持复用") {
一层只看一层。

@Highlight {
名字对外，细节对内。
}
}

@Card(id: "cs-prog-functions-card-io", revision: 1, sourcePage: "cs-prog-functions-page-boundary", topic: "边界", accent: "amber", frontTitle: "函数的边界是什么", frontSubtitle: "与调用者", backTitle: "参数进入，返回值出去") {
约定稳定，内部可改。

@Highlight {
调用者依赖 I/O，不依赖内部每一步。
}
}
