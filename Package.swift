// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "feat_ble",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(name: "feat_ble", targets: ["feat_ble"]),
    ],
    dependencies: [
        // Define external dependencies here using GitHub URLs or package names.
        // Example: A dependency on 'feat_base' hosted on GitHub.
        .package(url: "https://github.com/netcanis/feat_base.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "feat_ble",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "feat_bleTests",
            dependencies: ["feat_ble"],
            path: "Tests"
        ),
    ]
)
