// swift-tools-version:5.10.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let pointfreeHtml: Self = "PointFreeHTML"
}

extension Target.Dependency {
    static var pointfreeHtml: Self { .target(name: .pointfreeHtml) }
}

let package = Package(
    name: "pointfree-html",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10),
        .macCatalyst(.v17),
      ],
    products: [
        .library(name: .pointfreeHtml, targets: [.pointfreeHtml]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.5")
    ],
    targets: [
        .target(
            name: .pointfreeHtml,
            dependencies: [
                .product(name: "OrderedCollections", package: "swift-collections"),
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        )
    ]
)
