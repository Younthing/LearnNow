@Card(id: "kc-os-card-turns", revision: 1, sourcePage: "kc-os-page-share", topic: "认识计算机", accent: "purple", frontTitle: "同时开着两个 app", frontSubtitle: "歌不断，记账也不卡", backTitle: "轮换很快") {
两份清单被轮着读，每次只读一小段。轮到谁、轮多久，由操作系统决定，不由 app 自己宣布。

@Highlight {
「同时」通常是轮换快到看不出接缝，不是各占一半机器。
}
}

@Card(id: "kc-os-card-boundary", revision: 1, sourcePage: "kc-os-page-isolate", topic: "认识计算机", accent: "purple", frontTitle: "一个 app 崩了", frontSubtitle: "别的为什么还活着", backTitle: "地盘被划开") {
每个 app 在内存里有自己的一片，别的 app 碰不到。崩溃通常被关在那一片里面。

@Highlight {
同一块台面不等于同一片地盘；界线由系统划，不靠 app 自觉。
}
}

@Card(id: "kc-os-card-request", revision: 1, sourcePage: "kc-os-page-gateway", topic: "认识计算机", accent: "purple", frontTitle: "app 想用麦克风", frontSubtitle: "那句「是否允许」是谁弹的", backTitle: "申请，不自取") {
屏幕、麦克风、存储这些共用的东西，app 只能向操作系统请求，由它去操作。

@Highlight {
关掉权限改的不是 app 的步骤，是这个请求会不会被答应。
}
}
