这个主要工作区通常叫**内存**：程序运行时变量、数组元素所在的地方。

## 工作台比喻（有边界）

把内存想成桌面：正在算的稿纸摊在桌上，伸手就能够。比喻只解释「近、快、正在用」，不解释电路细节。

```text
磁盘/长期柜（以后再说）
  ↓ 需要时加载
内存工作台
  ↓ CPU 读写
正在运行的程序
```

## 数组在内存里占连续格子（常见情形）

下标访问快，常因元素按约定排在可推算的位置。细节下一课用「地址」说清。

程序、变量、中间结果在运行时都会占用工作台空间。工作台越挤，能同时摊开的稿纸越少——这是后文谈结构与效率时的背景。

@Callout(title: "内存是工作台", tone: "information", accent: "mint") {
运行中的数据主要在内存里被读写。
}

@Quiz(id: "cs-mem-where-mem.quiz-1", kind: "singleChoice") {
步数数组正在被循环累加。这些元素当前主要在哪一类存放处？

@Option(id: "cs-mem-where-mem-q1-ram", correct: true) {
内存工作台，供运行中快速读写

@Feedback(title: "运行态在内存", tone: "success", accent: "mint") {
正在算的数据要在 CPU 够得着的工作区。
}
}

@Option(id: "cs-mem-where-mem-q1-paper") {
只印在说明书封面，CPU 从不读取
}

@Option(id: "cs-mem-where-mem-q1-nowhere") {
不在任何地方，却仍能被下标访问
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
运行中的结构，默认先想内存。
}

@Feedback(when: "incorrect", title: "问谁在被读写", tone: "warning", accent: "amber") {
循环每一步读的 steps[i] 从哪来？
}
}
