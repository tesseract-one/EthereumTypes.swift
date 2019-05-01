// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "EthereumTypes",
    products: [
        .library(name: "EthereumTypes", targets: ["EthereumTypes"]),
        .library(name: "PKEthereumTypes", targets: ["PKEthereumTypes"])
    ],
    dependencies: [
        // Core dependencies
        .package(url: "https://github.com/attaswift/BigInt.git", from: "4.0.0"),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git", from: "1.0.0"),
        .package(url: "https://github.com/tesseract-one/Serializable.swift.git", from: "0.1.0"),
        
        // PromiseKit dependency
        .package(url: "https://github.com/mxcl/PromiseKit.git", from: "6.8.0"),
    ],
    targets: [
        .target(
            name: "EthereumTypes",
            dependencies: ["BigInt", "CryptoSwift", "Serializable"]
        ),
        .target(
            name: "PKEthereumTypes",
            dependencies: ["EthereumTypes", "PromiseKit"],
            path: "Sources",
            sources: ["PromiseKit"]
        ),
        .testTarget(
            name: "EthereumTypesTests",
            dependencies: ["EthereumTypes", "PKEthereumTypes"]
        )
    ]
)
