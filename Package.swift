// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UDPChat",
    dependencies: [
        .package(url: "https://github.com/robbiehanson/CocoaAsyncSocket", from: "7.6.4")
    ],
    targets: [
        .target(
            name: "Client",
            dependencies: ["CocoaAsyncSocket"]),
        .target(
            name: "Server",
            dependencies: ["CocoaAsyncSocket"])
    ]
)
