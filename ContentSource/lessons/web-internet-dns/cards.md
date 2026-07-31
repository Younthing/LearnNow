@Card(id: "web-internet-dns-card-map", revision: 1, sourcePage: "web-internet-dns-page-name", topic: "认识互联网和 Web", accent: "mint", frontTitle: "域名和 IP", frontSubtitle: "小记的名字与门牌", backTitle: "名字指向门牌") {
域名给人记，IP 给设备定位；中间靠对应关系连接二者。

@Highlight {
换服务器常改对应，而不是强迫用户改记名字。
}
}

@Card(id: "web-internet-dns-card-order", revision: 1, sourcePage: "web-internet-dns-page-lookup", topic: "认识互联网和 Web", accent: "mint", frontTitle: "解析排在哪", frontSubtitle: "打开网址时的顺序", backTitle: "先解析再连接") {
通常先把域名查成 IP，再用 IP 连接服务器。

@Highlight {
解析失败时，请求往往还发不出去。
}
}
