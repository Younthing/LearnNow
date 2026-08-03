# AGENTS.md

## Cursor Cloud specific instructions

### Platform requirement (read first)

LearnNow is an Apple-platform project and its full toolchain is **macOS-only**. The
product is a SwiftUI **iOS app** built with **Xcode 26.2 / iOS 26.2 Simulator** (see
`README.md`). All CI runs on `macos-15` (`.github/workflows/app.yml`,
`.github/workflows/content.yml`, `.github/workflows/content-publish.yml`).

The Cursor Cloud VM is **Linux x86_64**, so it **cannot build, test, or run** this
project end to end:

- The iOS app (`LearnNow`, `LearnNowTests`, `LearnNowUITests`) requires Xcode + the
  iOS Simulator, which do not exist on Linux.
- The `Packages/LearnNowContentKit` SwiftPM package and its `learnnow-content` CLI
  hard-import `CryptoKit` (Apple-only; no `canImport` guard — used for `SHA256` and
  `Curve25519.Signing` in `Sources/LearnNowContentKit/DeterministicJSON.swift`,
  `Sources/LearnNowContentAuthoring/ContentCompiler.swift`, and the tests). On Linux
  `swift build` / `swift test` / `swift run` fail with `no such module 'CryptoKit'`.

Do not spend time trying to build or run the app or the content package on the Linux
VM — it is a hard platform limitation, not a missing dependency. Use a macOS machine
with Xcode for build/test/run.

### What the Linux VM CAN do

- Swift 6.3.3 is installed via swiftly. It is on `PATH` in interactive shells; the
  binary is also at `~/.local/share/swiftly/bin/swift`.
- `swift package resolve --package-path Packages/LearnNowContentKit` succeeds, and the
  third-party dependencies (`swift-markdown`, `Yams`) compile. This is enough for
  editing, dependency resolution, and SourceKit/LSP on the non-CryptoKit code paths.
- If Swift is ever missing (e.g. a snapshot did not capture it), reinstall with:
  `curl -fsSL https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz | tar xz && ./swiftly init --assume-yes && swiftly install latest --assume-yes`
  (system deps: `binutils libc6-dev libcurl4-openssl-dev libedit2 libpython3-dev libsqlite3-0 libstdc++-13-dev libxml2-dev libz3-dev zlib1g-dev`).

### Build / test / run (macOS + Xcode only)

- App build + launch in Simulator: see `README.md` (`xcodebuild … build`, then
  `xcrun simctl boot/install/launch`, bundle id `com.fanxi.learnnow`).
- App tests: `xcodebuild -project LearnNow.xcodeproj -scheme LearnNow -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
  (scope with `-only-testing:LearnNowTests` or `-only-testing:LearnNowUITests`).
- Content compiler tests + lint: `swift test --package-path Packages/LearnNowContentKit`
  and `swift run --package-path Packages/LearnNowContentKit learnnow-content lint --source ContentSource`.
- Content authoring, catalog generation, diff, and publish flows are documented in
  `docs/ContentAuthoring.md`. Never hand-edit `LearnNow/Resources/CatalogV2.json` or
  `LearnNow/Resources/ContentManifest.json`; regenerate them with `learnnow-content build`.
