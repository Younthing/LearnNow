// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "LearnNowContentKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "LearnNowContentKit", targets: ["LearnNowContentKit"]),
        .library(name: "LearnNowContentAuthoring", targets: ["LearnNowContentAuthoring"]),
        .executable(name: "learnnow-content", targets: ["LearnNowContentCLI"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-markdown.git",
            exact: "0.8.0"
        ),
        .package(
            url: "https://github.com/jpsim/Yams.git",
            exact: "6.2.2"
        ),
    ],
    targets: [
        .target(
            name: "LearnNowContentKit"
        ),
        .target(
            name: "LearnNowContentAuthoring",
            dependencies: [
                "LearnNowContentKit",
                .product(name: "Markdown", package: "swift-markdown"),
                .product(name: "Yams", package: "Yams"),
            ],
            resources: [.copy("Resources")]
        ),
        .executableTarget(
            name: "LearnNowContentCLI",
            dependencies: ["LearnNowContentAuthoring", "LearnNowContentKit"]
        ),
        .testTarget(
            name: "LearnNowContentKitTests",
            dependencies: ["LearnNowContentKit", "LearnNowContentAuthoring"]
        ),
    ]
)
