// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "CentralTime",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "CentralTime", targets: ["CentralTime"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "CentralTime",
            dependencies: [],
            path: "Sources"
        )
    ]
)
