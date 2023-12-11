// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoatsPythonDemo",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(name: "GoatsPythonDemo", targets: ["GoatsPythonDemo"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/pvieito/PythonKit.git", branch: "master"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(name: "GoatsPythonDemo", dependencies: ["PythonKit"])
    ]
)
