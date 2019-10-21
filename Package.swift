// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SwiftEval",
    platforms: [.macOS(.v10_13)],
    products: [
        .library(
            name: "SwiftEval",
            type: .dynamic,
            targets: ["SwiftEval"]),
    ],
    targets: [
        .target(
            name: "SwiftEval",
            dependencies: []),
        .testTarget(
            name: "SwiftEvalTests",
            dependencies: ["SwiftEval"]),
    ]
)
