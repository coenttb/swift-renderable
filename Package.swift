// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let pointfreeHtml: Self = "PointFreeHTML"
    static let pointfreeHtmlElements: Self = "PointFreeHTMLElements"
    static let pointfreeHtmlTestSupport: Self = "PointFreeHtmlTestSupport"
}

extension Target.Dependency {
    static var pointfreeHtml: Self { .target(name: .pointfreeHtml) }
    static var pointfreeHtmlElements: Self { .target(name: .pointfreeHtmlElements) }
    static var pointfreeHtmlTestSupport: Self { .target(name: .pointfreeHtmlTestSupport) }
}

extension Target.Dependency {
    static var dependenciesTestSupport: Self { .product(name: "DependenciesTestSupport", package: "swift-dependencies") }
    static var inlineSnapshotTesting: Self { .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing") }
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
        .library(name: .pointfreeHtmlElements, targets: [.pointfreeHtmlElements]),
        .library(name: .pointfreeHtmlTestSupport, targets: [.pointfreeHtmlTestSupport]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-collections.git", from: "1.1.2"),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", from: "1.3.5"),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.18.3")
    ],
    targets: [
        .target(
            name: .pointfreeHtml,
            dependencies: [
                .product(name: "Dependencies", package: "swift-dependencies"),
                .product(name: "OrderedCollections", package: "swift-collections"),
            ]
        ),
        .testTarget(
            name: .pointfreeHtml.tests,
            dependencies: [
                .pointfreeHtml,
                .product(name: "DependenciesTestSupport", package: "swift-dependencies")
            ]
        ),
        .target(
            name: .pointfreeHtmlElements,
            dependencies: [
                .pointfreeHtml
            ]
        ),
        .testTarget(
            name: .pointfreeHtmlElements.tests,
            dependencies: [
                .pointfreeHtmlElements,
                .dependenciesTestSupport,
                .inlineSnapshotTesting
            ]
        ),
        .target(
            name: .pointfreeHtmlTestSupport,
            dependencies: [
                .pointfreeHtml,
                .inlineSnapshotTesting,
                .dependenciesTestSupport
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)

extension String {
    var tests: Self {
        "\(self) Tests"
    }
}
