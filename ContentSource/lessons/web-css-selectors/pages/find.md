CSS 规则的前半句是**选择器**：说明这条外观应用到哪些元素。

「小记」里若只想改留言正文，而不是改导航，就要把选择器写准。

## 三种常见找法

```text
按标签   p          所有段落
按类别   .note      class 为 note 的元素
按编号   #hero      id 为 hero 的元素
```

类别适合重复样式；`id` 适合页内唯一块。入门先会用标签与类别。

## 选错了就改错了

选择器太宽，导航和留言会一起变色；太窄，又有些留言改不到。先想清楚「我要命中谁」。

## 落到「小记」上

导航链接和留言正文都可能是文字，但你只想让留言变灰。给留言加上 `class="note"`，再用 `.note` 选中，就不会误伤导航。

## 选太宽的代价

选择器一宽，副作用就大：改「所有段落」可能连页脚说明一起变。写规则前先问：我要命中的最小集合是什么？

同一外观要出现多次，就给 HTML 加同一 `class`，再用类别选择器一次打中。比复制很多条「按标签」规则更稳。

@Callout(title: "先选中，再上样式", tone: "information", accent: "mint") {
选择器决定规则打在谁身上；选错对象，再好看的属性也贴错地方。
}

@Quiz(id: "web-css-selectors-page-find.quiz-1", kind: "singleChoice") {
只想让 class="note" 的留言变色，导航链接不动。更合适的选择器是？

@Option(id: "web-css-selectors-q1-class", correct: true) {
.note

@Feedback(title: "为什么对", tone: "success", accent: "mint") {
按类别精确命中留言。
}
}

@Option(id: "web-css-selectors-q1-all") {
选中页面上全部元素
}

@Option(id: "web-css-selectors-q1-a") {
只写 a，因为链接最重要
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
用类别选择器限制范围。
}

@Feedback(when: "incorrect", title: "再想一步", tone: "warning", accent: "amber") {
问：导航和留言是否共享同一个 class？不共享就别用过宽的选择器。
}
}
