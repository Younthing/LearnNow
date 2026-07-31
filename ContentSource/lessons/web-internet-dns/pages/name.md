五步里的第一步是「读懂你要去哪」。你输入的是 `notes.example.com`，机器真正用来连接的往往是一串数字地址。

**域名**是给人读的名字；**IP 地址**是给设备在网上定位用的编号。两者需要一份「姓名→门牌」的对应，查找这份对应的过程，日常就叫域名解析。

## 为什么不直接记数字

`notes.example.com` 好记、好说；一长串数字难记，也难在换机器时口头传达。名字稳定，底下的门牌偶尔会换——换的时候改对应表即可，用户仍输入同一个域名。

```text
你记住的
notes.example.com
  ↓  查对应
设备用来连接的
例如 203.0.113.10
```

（例子里的数字只是占位，不必背。）

## 关系一句话

域名不是「另一种 IP」，而是**指向**某个 IP（有时是一组）的名字。没有对应关系，光有好听的名字也连不上。

## 落到换服务器

「小记」换机器后门牌变了，用户仍输入同一域名——改的是对应表，不是强迫所有人改记名字。

## 域名不是另一种 IP

它是指向门牌的名字。没有对应关系，名字再好听也连不上。

@Callout(title: "名字指向门牌", tone: "information", accent: "mint") {
域名给人用，IP 给设备定位用；中间靠查找把名字变成门牌。
}

@Quiz(id: "web-internet-dns-page-name.quiz-1", kind: "singleChoice") {
「小记」换了一台服务器，对外门牌号变了，但希望用户仍输入 notes.example.com。按本课模型，通常改什么？

@Option(id: "web-internet-dns-q1-map", correct: true) {
改域名到新 IP 的对应

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
用户侧名字不变，改的是姓名簿里的门牌。
}
}

@Option(id: "web-internet-dns-q1-rename") {
强制所有用户改记新域名
}

@Option(id: "web-internet-dns-q1-browser") {
只升级浏览器版本，对应会自动变
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
域名稳定、门牌可换，靠的是更新对应关系。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问：用户还输入同一个名字吗？是。那变的只能是名字背后的门牌记录。
}
}
