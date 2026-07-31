例子失败时，不要整份推倒重来。沿追踪记录**定位**出错的那一步，再改。

## 失败点附近改

若在「冲泡」一步发现没有热水，问题多在前面的烧水或顺序，而不在「端出」。

```text
追踪记录
  ↓
第一步结果异常处
  ↓
只改相关步骤 / 条件
  ↓
重跑同一例子
```

## 单元收口

计算思维：拆解 → 用顺序/选择/重复组织 → 写成图或伪代码 → 用例子检验。下一单元进入程序设计，把这些结构落进语言。

## 改完重跑同一例

定位并修改后，用**同一个失败例子**再走一遍。若只换新例子，可能旧路径仍是坏的。

正确性修复的仪式是：旧失败 → 修改 → 旧例变通过。

@Callout(title: "定位再改", tone: "warning", accent: "amber") {
失败例子是地图：指向该改的步骤，而不是整份作废。
}

@Quiz(id: "cs-thinking-correctness-fix.quiz-1", kind: "singleChoice") {
追踪显示：烧水输出正常，冲泡时茶叶为空。你该优先检查哪一步？

@Option(id: "cs-thinking-correctness-fix-q1-tea", correct: true) {
放茶叶是否漏写或放在冲泡之后

@Feedback(title: "对准异常输入", tone: "success", accent: "mint") {
冲泡缺茶叶，说明提供茶叶的步骤有问题。
}
}

@Option(id: "cs-thinking-correctness-fix-q1-end") {
只改最后的「端出」，与茶叶无关也没关系
}

@Option(id: "cs-thinking-correctness-fix-q1-all") {
删除全部步骤，从零空想一套新的且不再测试
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用异常出现的位置缩小修改范围。
}

@Feedback(when: "incorrect", title: "看追踪断点", tone: "warning", accent: "amber") {
哪一步的输入第一次变得不满足？就从那里查。
}
}
