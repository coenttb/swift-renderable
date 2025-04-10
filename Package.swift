// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

extension String {
    static let pointfreeHtml: Self = "PointFreeHTML"
    static let pointfreeHtmlElements: Self = "PointFreeHTMLElements"
}

extension Target.Dependency {
    static var pointfreeHtml: Self { .target(name: .pointfreeHtml) }
    static var pointfreeHtmlElements: Self { .target(name: .pointfreeHtmlElements) }
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
                .product(name: "DependenciesTestSupport", package: "swift-dependencies")
            ]
        ),
    ]
)

extension String {
    var tests: Self {
        "\(self) Tests"
    }
}

#if !os(Windows)
  // Add the documentation compiler plugin if possible
  package.dependencies.append(
    .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0")
  )
#endif
