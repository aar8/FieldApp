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
        .library(
            name: "SyncClient",
            targets: ["SyncClient"]
        ),
        .executable(
            name: "fieldprime",
            targets: ["FieldPrimeCLI"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", "4.0.0" ..< "5.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.3"),
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
        .target(
            name: "SyncClient",
            dependencies: [
                "Insieme",
                .product(name: "GRDB", package: "GRDB.swift"),
            ]
        ),
        .executableTarget(
            name: "FieldPrimeCLI",
            dependencies: [
                "Insieme",
                "SyncClient",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .testTarget(
            name: "InsiemeTests",
            dependencies: ["Insieme"]
        ),
    ]
)
