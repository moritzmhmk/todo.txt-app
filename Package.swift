// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "TodoTxt",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "TodoTxt", targets: ["TodoTxt"])
    ],
    targets: [
        .executableTarget(name: "TodoTxt")
    ]
)