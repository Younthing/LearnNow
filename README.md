# LearnNow

LearnNow 是一个 iOS 学习应用。项目包含主应用、单元测试和 UI 测试。

## 环境要求

- Xcode 26.2 或更高版本
- iOS 26.2 Simulator

首次构建时，Xcode 会根据 `Package.resolved` 自动解析 Swift Package 依赖。

## 启动项目

在仓库根目录打开项目：

```bash
open LearnNow.xcodeproj
```

在 Xcode 中选择 `LearnNow` scheme 和一个 iOS 26.2 模拟器，然后按 `⌘R` 启动。

也可以先通过命令行验证项目能够为模拟器构建：

```bash
xcodebuild \
  -project LearnNow.xcodeproj \
  -scheme LearnNow \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -derivedDataPath .build/DerivedData \
  build
```

构建成功后，使用命令行启动模拟器、安装并启动应用：

```bash
# 模拟器尚未启动时执行；如果已经启动，可跳过这一行
xcrun simctl boot 'iPhone 17 Pro'

# 打开模拟器窗口并等待设备启动完成
open -a Simulator
xcrun simctl bootstatus booted -b

# 安装并启动刚才构建的应用
xcrun simctl install booted \
  .build/DerivedData/Build/Products/Debug-iphonesimulator/LearnNow.app
xcrun simctl launch booted com.fanxi.learnnow
```

后续应用已经安装时，只需执行启动命令：

```bash
xcrun simctl launch booted com.fanxi.learnnow
```

如果本机没有 `iPhone 17 Pro`，可先查看可用设备，并替换上面命令中的设备名称：

```bash
xcrun simctl list devices available
```

## 课程内容

课程正文、随堂练习、复习卡片和 Tips 的作者源位于 `ContentSource/`。唯一固定入口是
`ContentSource/learnnow.yml`；它显式编排 Route、Track 和 Lesson 顺序。每个
由根配置列出的 manifest 管理一个自包含 Lesson Bundle，页面正文、`cards.md`、
`tips.md` 和本地资源都相对该 manifest 组织；除根入口外，目录名没有编译语义。日常
更新编辑 Markdown/YAML，再由本地 SwiftPM 工具生成 App 使用的强类型
`CatalogV2.json`：

```bash
swift run --package-path Packages/LearnNowContentKit learnnow-content lint \
  --source ContentSource

swift run --package-path Packages/LearnNowContentKit learnnow-content build \
  --source ContentSource \
  --output .build/content
```

需要同时检查尚未加入根课程树的 Lesson 草稿时，运行
`learnnow-content lint --source ContentSource --all`。

不要手改 `LearnNow/Resources/CatalogV2.json`。语法、稳定 ID、预览、语义 diff、
签名发布和远程更新配置见 [内容编写与发布](docs/ContentAuthoring.md)。

## 运行测试

运行全部单元测试和 UI 测试：

```bash
xcodebuild \
  -project LearnNow.xcodeproj \
  -scheme LearnNow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  test
```

只运行单元测试：

```bash
xcodebuild \
  -project LearnNow.xcodeproj \
  -scheme LearnNow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:LearnNowTests \
  test
```

只运行 UI 测试：

```bash
xcodebuild \
  -project LearnNow.xcodeproj \
  -scheme LearnNow \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:LearnNowUITests \
  test
```
