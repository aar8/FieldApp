// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Insieme",
    platforms: [
       .macOS(.v12),
       .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "Insieme",
            targets: ["Insieme"]),
        .executable(
            name: "insieme-cli",
            targets: ["InsiemeCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "4.0.0" ..< "5.0.0"),
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "7.8.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Insieme",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .executableTarget(
            name: "InsiemeCLI",
            dependencies: ["Insieme"]
        ),
        .testTarget(
            name: "InsiemeTests",
            dependencies: ["Insieme"]
        ),
    ]
)
