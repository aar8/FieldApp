// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Insieme",
    platforms: [
       .macOS(.v12)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Insieme",
            targets: ["Insieme"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "4.0.0" ..< "5.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Insieme",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto")
            ]
        ),
        .testTarget(
            name: "InsiemeTests",
            dependencies: ["Insieme"]
        ),
    ]
)