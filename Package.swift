// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "TodoTxt",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "TodoTxt", targets: ["TodoTxt"])
    ],
    targets: [
        .target(name: "TodoParser"),
        .executableTarget(name: "TodoTxt", dependencies: ["TodoParser"]),
        .testTarget(name: "TodoParserTests", dependencies: ["TodoParser"]),
    ]
)
