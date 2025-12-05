// swift-tools-version:6.1
import PackageDescription

let package = Package(
    name: "FieldPrimeServer",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.118.0"),
        // 🗄 An ORM for SQLite databases.
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "6.0.0"),
        // Shared library
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.59.0"),

        .package(path: "../../shared")
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "Insieme", package: "shared")
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
