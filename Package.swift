// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDPChat",
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4"),
        .package(url: "https://github.com/apple/swift-tools-support-core.git", from: "0.0.1")
    ],
    targets: [
        .target(name: "UDPCore"),
        .target(
            name: "Client",
            dependencies: ["UDPCore", "CocoaAsyncSocket", "SwiftToolsSupport"]),
        .target(
            name: "Server",
            dependencies: ["UDPCore", "CocoaAsyncSocket"])
    ]
)
