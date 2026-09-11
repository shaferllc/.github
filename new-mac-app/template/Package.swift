// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "__APP__",
    platforms: [.macOS(.v14)],
    dependencies: [
        // Free shafer.llc registration, Help and Contact Support.
        .package(url: "https://github.com/shaferllc/swift-licensing", from: "1.1.0"),
    ],
    targets: [
        .executableTarget(
            name: "__APP__",
            dependencies: [.product(name: "ShaferAccount", package: "swift-licensing")],
            path: "Sources/__APP__"
        ),
        .testTarget(
            name: "__APP__Tests",
            dependencies: ["__APP__"],
            path: "Tests/__APP__Tests"
        ),
    ]
)
