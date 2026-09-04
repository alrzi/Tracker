// swift-tools-version: 6.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrackerDomain",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TrackerDomain",
            targets: ["TrackerDomain"]
        )

    ],
    dependencies: [
        .package(url: "https://github.com/alrzi/Utils.git", branch: "main"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.9.1"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TrackerDomain",
            dependencies: [
                .product(name: "Utils", package: "Utils"),
                .product(name: "Swinject", package: "Swinject"),
            ]
        ),
        .testTarget(
            name: "TrackerDomainTests",
            dependencies: ["TrackerDomain"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
