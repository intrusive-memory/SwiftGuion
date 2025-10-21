// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SwiftGuion",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .macCatalyst(.v26)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "SwiftGuion",
            targets: ["SwiftGuion"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/mcritz/TextBundle.git", from: "1.0.0"),
        .package(url: "https://github.com/stovak/SwiftFijos.git", from: "1.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "SwiftGuion",
            dependencies: [
                .product(name: "TextBundle", package: "TextBundle")
            ]
        ),
        .testTarget(
            name: "SwiftGuionTests",
            dependencies: [
                "SwiftGuion",
                .product(name: "SwiftFijos", package: "SwiftFijos")
            ]
        ),
    ]
)
