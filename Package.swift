// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftEval",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "BuildKit",
            targets: ["BuildKit"]),
        .library(
            name: "SwiftEval",
            type: .dynamic,
            targets: ["SwiftEval"])
    ],
    targets: [
        .target(
            name: "BuildKit"
            ),
        .target(
            name: "SwiftEval",
            dependencies: ["BuildKit"]),
        .testTarget(
            name: "SwiftEvalTests",
            dependencies: ["SwiftEval"]),
    ]
)
