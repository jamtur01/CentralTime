// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "CentralTime",
    platforms: [
        .macOS(.v10_13)
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
