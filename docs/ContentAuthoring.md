# LearnNow 内容编写与发布

课程的唯一作者源位于 `ContentSource/`。App 不直接解析 Markdown；构建期由
`learnnow-content` 把受限 Markdown/YAML 编译成强类型 `CatalogV2.json`。

## 目录与职责

```text
ContentSource/
  learnnow.yml                 # 唯一固定入口和完整课程编排
  lessons/
    stats/
      lesson.yml               # Lesson、页面和完成信息
      pages/
        mean.md                # 一页正文与随堂练习
        variance.md
      cards.md                 # 本 Lesson 的 FSRS 卡片
      tips.md                  # 本 Lesson 的首页 Tips
      assets/                  # 本 Lesson 的本地媒体
  shared/
    tips.md                    # 可选的全局 Tips
```

除 `learnnow.yml` 外，目录名和文件名没有编译语义。编译器只跟随根配置直接列出的
Lesson manifest，再跟随 manifest 列出的页面、Card 和 Tip 文件；可以按团队需要移动
或拆分文件。`id` 才是用户进度、卡片记忆和引用的稳定身份：

- ID 必须显式填写，并匹配 `[A-Za-z0-9][A-Za-z0-9._-]*`。
- 已发布 ID 不从标题生成、不改名、不复用。
- 文案修正保留 ID；学习含义发生实质变化且应重置记忆时创建新 ID。
- 删除任何稳定实体（包括题目选项）时把旧 ID 加入 `learnnow.yml` 的
  `retiredIDs`；该列表只增不减，退休 ID 永远不能重新使用。
- Route、Track 和 Lesson 顺序由根 YAML 数组决定，页面顺序由 `lesson.yml` 的
  `pages` 数组决定；作者格式中没有 `order`。
- Card 和 Tip 按 manifest 文件数组及文件内声明顺序编译；选项和页面 badge 由
  客户端派生。

## 项目与路线编排

根配置包含发布信息，并把 Route、Track 和 Lesson manifest 路径放在同一棵有序树中：

```yaml
format: learnnow.project/v1
schemaVersion: 2
releaseVersion: "2026.07.28.2"
locale: zh-Hans
primaryRouteID: datascience
minAppBuild: 1
publishedAt: "2026-07-28T00:00:00Z"
retiredIDs: []

routes:
  - id: datascience
    title: 数据科学与人工智能
    subtitle: 统计 · 机器学习 · 深度学习
    systemImage: cpu
    accent: blue
    cta: 继续学习
    interactive: true
    tracks:
      - id: statistics
        title: 统计基础
        lessons:
          - lessons/stats/lesson.yml
```

Track ID 全局唯一；同一 Lesson manifest 不得挂载到多个 Track 或 Route。Lesson
先修使用稳定 Lesson ID，不使用文件路径。`requiredCapabilities` 始终由编译后的 IR
推导，作者不填写。

项目、Route、Track 和 Lesson 都可声明同形的 `defaults`：

```yaml
defaults:
  locale: zh-Hans
  page:
    accent: blue
  card:
    accent: mint
    topic: 描述统计
  tip:
    accent: amber
    systemImage: lightbulb
```

优先级为 `project → route → track → lesson → page/card/tip`。只允许继承 `locale`、
page accent、card accent/topic、tip accent/systemImage；Map 深合并。V1 不开放数组
defaults，后续若开放也只会整体覆盖而不拼接。ID、revision、路径、顺序、先修、XP、
答案和正文必须显式定义。未知字段、类型冲突以及不同于项目 locale 的覆盖都会报错。

## Lesson Bundle

作者语义中的一个 Lesson 会编译为 App 的一个可完成 Module；`pages` 中的每一项会
编译为一个稳定 Page：

```yaml
format: learnnow.lesson-bundle/v1
id: stats
title: 描述统计与数据探索
prerequisites: []
completion:
  xp: 15
  message: 均值与方差已经加入复习池。

pages:
  - id: stats-page-1
    title: 均值描述数据中心
    source: pages/mean.md
    accent: mint
    revision: 1
    objectives: [stats.mean.outlier-effect]

cards:
  - cards.md
tips:
  - tips.md
```

页面始终一页一个 Markdown 文件，且不允许 YAML front matter。页面文件只保存正文、
`@Quiz`、`@Callout` 等内容块。

正文基于 CommonMark，允许段落、1–6 级标题、单层列表、fenced code，以及有限的
inline `**strong**`、`*emphasis*` 和 `` `code` ``。不允许 raw HTML、链接、脚本、
远程组件或 inline 图片。

可用 directive：

```markdown
@Callout(title: "核心认知", tone: "warning", accent: "amber") {
极端值会明显拉动均值。
}

@Image(path: "assets/chart.png", alt: "均值变化图", caption: "图 1")

@Quiz(id: "stats-page-1.quiz", kind: "singleChoice") {
加入一个很大的极端值后，均值通常怎样？

@Option(id: "mean-rises", correct: true) {
向极端值方向移动
}

@Option(id: "mean-fixed") {
保持不变
}

@Feedback(when: "correct", title: "回答正确", tone: "success", accent: "mint") {
极端值参与总和，因此会拉动均值。
}

@Feedback(when: "incorrect", title: "再看公式", tone: "warning", accent: "amber") {
检查极端值是否参与了总和。
}
}
```

单选题必须有至少两个不同 ID 的选项、恰好一个 `correct: true`，以及 correct 和
incorrect 两种反馈。`@Option` 内还可带一个不含 `when` 的 `@Feedback`，用于
选项级解释。

Lesson 的 `cards.md` 可以聚合多张 Card：

```markdown
@Card(id: "mean", revision: 1, sourcePage: "stats-page-1", topic: "描述统计", accent: "mint", frontTitle: "均值", frontSubtitle: "平均数的中心位置", backTitle: "核心定义") {
均值是所有样本值之和除以样本个数。

@Highlight {
极端值会显著拉动均值，偏态分布下应搭配中位数。
}
}
```

Card 必须有普通 Markdown 背面正文和一个 `@Highlight`。所属 Lesson 自动继承；
`sourcePage` 可省略，填写时必须引用当前 Lesson 的 Page，并映射为 Catalog 的
`sourceLessonID`。

Lesson 的 `tips.md` 使用同样的聚合方式：

```markdown
@Tip(id: "mean-tip", revision: 1, sourcePage: "stats-page-1", title: "偏态分布别只看均值", systemImage: "chart.bar.xaxis", accent: "mint") {
极端值会拉动均值；同时查看中位数与分位数，通常更接近数据全貌。
}
```

Tip 只接受段落正文。根配置可通过 `globalTips: [shared/tips.md]` 引用使用相同
`@Tip` 语法的全局 Tip；全局 Tip 不允许填写 `sourcePage`。Cards、Tips 及
`globalTips` 均可为空；lint 会给出教学质量 warning，但不阻止构建。

Lesson 子文件和媒体路径都相对 `lesson.yml` 解析，并且必须留在该 Lesson 目录内。
图片用 `@Image(path: "assets/chart.png", ...)` 引用；输出路径会改写为
`assets/<lessonID>/<relative-path>`。路径仅允许 ASCII 字母、数字和 `._/-`，扩展名
限 `png/jpg/jpeg/gif/webp`。单个图片必须为 1 字节至 8 MiB，编译器会核对扩展名与
PNG/JPEG/GIF/WebP 文件签名；路径不能包含空段、`.`、`..`、绝对路径、URL 或符号
链接，也不能仅以字母大小写不同而产生跨文件系统资源碰撞。YAML anchors、aliases 和
custom tags 被禁用。

## 编译器命令

从仓库根目录运行：

```bash
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource

swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource \
  --all

swift run --package-path Packages/LearnNowContentKit learnnow-content build \
  --source ContentSource \
  --output /tmp/learnnow-content

swift run --package-path Packages/LearnNowContentKit learnnow-content preview \
  --source ContentSource \
  --output .build/content-preview

swift run --package-path Packages/LearnNowContentKit learnnow-content diff \
  --old previous/CatalogV2.json \
  --old-manifest previous/ContentManifest.json \
  --source ContentSource \
  --strict
```

普通 `lint/build/preview/publish` 只处理 `learnnow.yml` 引用的发布树。`lint --all`
还会递归发现带 `format: learnnow.lesson-bundle/v1` 的未引用 Lesson 草稿，对其执行
完整校验并输出 `lesson.unreferenced` warning；草稿不会进入发布包。warning 返回成功，
error 返回失败。

提供 `--old-manifest` 时，`diff --strict` 会比较完整的无签名内容包，因此同路径媒体
hash、`minAppBuild`、`publishedAt`、`compilerVersion`、能力列表或其他 manifest
字段变化也必须递增 `releaseVersion`。版本号在任何情况下都不允许倒退。首迁移若旧
提交尚无 manifest，可以省略该参数并安全回退到 Catalog 比较。

`build` 确定性生成：

- `CatalogV2.json`
- `ContentManifest.json`
- `CatalogV2.schema.json`
- 被当前目录实际引用的 `assets/**`

同一 source 的两次输出必须逐字节相同。每次 `build` 都会把输出目录的 `assets/`
同步为当前引用集合，删除该编译输出中的陈旧媒体。`requiredCapabilities` 永远从实际
block 与 inline IR 推导后写入 manifest，不信任作者手写列表。`publishedAt` 是
`learnnow.yml` 中的固定发布值，不使用本机当前时间。

App Bundle 基线必须与同一次编译的 Catalog、无签名 manifest 和媒体逐字节一致。
不要手改它们；从仓库根目录执行：

```bash
bundle_build=.build/content-bundle
swift run --package-path Packages/LearnNowContentKit learnnow-content build \
  --source ContentSource \
  --output "$bundle_build"
cp "$bundle_build/CatalogV2.json" LearnNow/Resources/CatalogV2.json
cp "$bundle_build/ContentManifest.json" LearnNow/Resources/ContentManifest.json
mkdir -p "$bundle_build/assets" LearnNow/Resources/assets
rsync -a --delete "$bundle_build/assets/" LearnNow/Resources/assets/
rmdir LearnNow/Resources/assets 2>/dev/null || true
```

最后一行只移除无图片时的空目录；`rsync --delete` 会删除 Bundle 中不再被 IR 引用的
陈旧媒体。

Debug App 可直接加载 `preview` 的真实内容包。在 Scheme 的 Run 环境变量中设置：

```text
LEARNNOW_CONTENT_PREVIEW_CATALOG=/absolute/path/to/.build/content-preview
```

该值既可指向输出目录，也可直接指向 `CatalogV2.json`。页面仍走生产
`CatalogDecoder`、语义校验和 SwiftUI block renderer，不存在第二套 Markdown 预览器。

## CI 签名发布

`publish` 只允许在 `CI=1/true/yes` 的发布环境执行；本地预览和检查使用 `build`。
发布 CI 先调用：

```bash
swift run --package-path Packages/LearnNowContentKit learnnow-content publish \
  --source ContentSource \
  --output /tmp/learnnow-publish \
  --private-key /secure/path/content-private-key \
  --key-id content-2026
```

私钥文件可为 Curve25519.Signing 的 32 字节 raw representation、64 位十六进制或
其 base64。签名是 base64 Ed25519 signature；payload 是以 sorted-key canonical
encoder 编码、保留 `keyID` 且仅令 `signature = nil` 的 manifest。私钥只能存在于
发布 CI，不能提交到仓库或 App。

## App 远程更新配置

没有远程配置时，更新器安全禁用，App 仍从 Bundle 或已验证的 last-known-good 启动。
生产构建通过 `Info.plist` 配置：

```xml
<key>LearnNowContentManifestURL</key>
<string>https://content.example.com/production/ContentManifest.json</string>
<key>LearnNowContentFilesBaseURL</key>
<string>https://content.example.com/production/</string>
<key>LearnNowContentPublicKeys</key>
<dict>
    <key>content-2026</key>
    <string>BASE64_ENCODED_32_BYTE_PUBLIC_KEY</string>
</dict>
```

`LearnNowContentFilesBaseURL` 可省略；此时文件相对 manifest 最终 URL 解析。公钥支持
32 字节 raw representation 的 base64 或 64 位十六进制，可同时保留多把公钥完成
密钥轮换。manifest 与所有 redirect 必须使用 HTTPS。

Debug 也可用以下环境变量覆盖：

```text
LEARNNOW_CONTENT_MANIFEST_URL
LEARNNOW_CONTENT_FILES_BASE_URL
LEARNNOW_CONTENT_PUBLIC_KEY_ID
LEARNNOW_CONTENT_PUBLIC_KEY
```

启动只读取本地 active/previous LKG 或 Bundle，不等待网络；随后使用 ETag 后台刷新。
下载先进入 staging，完成签名、版本、能力、引用、size 与 SHA-256 校验后才原子切换。
当前会话继续使用已加载的目录，新版本在下一次 `load()` 生效，避免打断正在作答或复习。
媒体按 SHA-256 blob 复用。回滚推荐把旧内容重新发布为更高的 `releaseVersion`；设备默认
拒绝版本号倒退。

`.github/workflows/content.yml` 会在合并前运行 compiler tests、lint，并从 PR base
分支的 `CatalogV2.json` 和无签名 `ContentManifest.json` 生成 `--strict` 语义 diff。
Catalog、manifest 元数据或资产 hash 变化却未递增 `releaseVersion`，版本倒退、删除
ID 未退休、退休列表缩短或退休 ID 复活都会令 CI 失败。首迁移的 base 尚无 manifest
时自动回退到 Catalog 检查。Catalog、无签名 manifest 与 Bundle `assets/` 也会做
逐字节比较，阻止遗漏或陈旧产物。手动的
`content-publish.yml` 只能在受保护的
`staging` / `production` GitHub environment 中运行，需要以下 environment secrets：

```text
CONTENT_PRIVATE_KEY
CONTENT_KEY_ID
CONTENT_PUBLISH_BASE_URL
CONTENT_PUBLISH_TOKEN
```

发布端点需接受带 Bearer token 的 HTTPS `PUT`。CI 先上传 Catalog、schema 和媒体，
最后上传签名 `ContentManifest.json`；因此中途失败不会激活半套内容。

## 合并前检查

```bash
swift test --package-path Packages/LearnNowContentKit
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource
```

内容 diff 中的删除、正确答案变化和同 ID 学习内容变化必须人工审阅。结构有效并不
替代教学审阅、VoiceOver、Dynamic Type、深浅模式和真实 SwiftUI 预览。
