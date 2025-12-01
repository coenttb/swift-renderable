# PointFreeHTML

[![CI](https://github.com/coenttb/pointfree-html/workflows/CI/badge.svg)](https://github.com/coenttb/pointfree-html/actions/workflows/ci.yml)
![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

A cross-platform Swift package to render any Swift type as HTML.

## Overview

PointFreeHTML enables **any Swift type** to be rendered as HTML through a simple protocol conformance. Other libraries use it to render their types to HTML.

## Key features

- **Universal HTML Protocol**: Any Swift type can be rendered as HTML by conforming to the `HTML` protocol
- **Performance Focused**:
  - Zero-copy byte rendering (~3,500 docs/sec)
  - RFC pattern with bytes as canonical representation
  - Optimized attribute escaping with fast-path detection
  - Capacity pre-allocation for known document sizes
- **Declarative Syntax**: SwiftUI-like syntax with `@Builder` result builder
- **Type Safety**: Compile-time checking prevents malformed HTML
- **Composable Components**: Build complex UIs from reusable components
- **Minimal Dependencies**: Core library has minimal external dependencies

## Usage examples

### Basic Usage

```swift
import PointFreeHTML

struct Greeting: HTML.View {
    let name: String
    var body: some HTML.View {
        tag("h1") { "Hello, \(name)!" }
    }
}

let greeting = Greeting(name: "World")

// Render to String (validates UTF-8)
let htmlString = try String(greeting)

// Render to bytes (zero-copy, canonical)
let htmlBytes = ContiguousArray(greeting)

// Or use Array (convenience wrapper)
let htmlArray: [UInt8] = Array(greeting)

// Legacy API (deprecated but still supported)
// let htmlBytes = greeting.render()  // ⚠️ Deprecated
```

PointFreeHTML follows the RFC pattern where **bytes are canonical**. All rendering goes through `ContiguousArray<UInt8>` (zero-copy) or `Array<UInt8>` (convenience), with String derived from bytes via validation.

### Complete Examples

For comprehensive examples of building HTML elements and components, see [swift-html](https://github.com/coenttb/swift-html), which provides a complete developer experience built on top of HTML_Renderable.

See [swift-html-css-pointfree](https://github.com/coenttb/swift-html-css-pointfree) for an example of how third-party libraries can integrate PointFreeHTML as their rendering engine.

## Integration with Swift Ecosystem

PointFreeHTML integrates seamlessly with the broader Swift web development ecosystem:

### Swift-HTML Integration

[swift-html](https://github.com/coenttb/swift-html) builds on PointFreeHTML to provide domain-accurate HTML and CSS integration and additional convenience APIs:

```swift
import HTML // This imports swift-html which includes PointFreeHTML

struct StyledComponent: HTML.View {
    var body: some HTML.View {
        tag("div") {
            tag("a") { "Styled Heading" }
                .attribute("href", "#")
                .inlineStyle("color", "blue")
                .inlineStyle("font-size", "24px")
                .inlineStyle("margin-bottom", "16px")
        }
    }
}
```

### Server Integration

PointFreeHTML works with Swift server frameworks like Vapor:

```swift
import Vapor
import PointFreeHTML

app.get("hello", ":name") { req -> String in
    let name = req.parameters.get("name") ?? "World"

    struct Greeting: HTML.View {
        let name: String
        var body: some HTML.View {
            tag("h1") { "Hello, \(name)!" }
        }
    }

    return try String(Greeting(name: name))
}
```

## Installation

### Swift Package Manager

Add PointFreeHTML to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/pointfree-html", from: "0.1.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: [
            .product(name: "PointFreeHTML", package: "pointfree-html")
        ]
    )
]
```

### Xcode Project

Add the package dependency in Xcode:
- File → Add Package Dependencies
- Enter: `https://github.com/coenttb/pointfree-html`


## Testing

PointFreeHTML includes support for snapshot testing:

```swift
import HTML_Renderable_TestSupport

@Test
func testMyComponent() {
    let component = Greeting(name: "Coen ten Thije Boonkkamp")
    assertInlineSnapshot(of: component, as: .html) {
        """
        <h1>Hello, Coen ten Thije Boonkkamp!</h1> 
        """
    }
}
```

## Real-World Usage

PointFreeHTML powers production applications:

- **[coenttb.com](https://coenttb.com)**: Personal website built entirely with PointFreeHTML
- **[coenttb-com-server](https://github.com/coenttb/coenttb-com-server)**: Open-source backend demonstrating full-stack Swift

## Related Packages

### Used By

- [coenttb-blog](https://github.com/coenttb/coenttb-blog): A Swift package for blog functionality with HTML generation.
- [coenttb-web](https://github.com/coenttb/coenttb-web): A Swift package with tools for web development building on swift-web.
- [pointfree-html-to-pdf](https://github.com/coenttb/pointfree-html-to-pdf): A Swift package integrating pointfree-html with swift-html-to-pdf.
- [pointfree-html-translating](https://github.com/coenttb/pointfree-html-translating): A Swift package integrating pointfree-html with swift-translating.
- [swift-html](https://github.com/coenttb/swift-html): The Swift library for domain-accurate and type-safe HTML & CSS.
- [swift-html-css-pointfree](https://github.com/coenttb/swift-html-css-pointfree): A Swift package integrating swift-html-standard and swift-css-types with pointfree-html.
- [swift-html-prism](https://github.com/coenttb/swift-html-prism): A Swift package integrating PrismJS with swift-html.
- [swift-web-foundation](https://github.com/coenttb/swift-web-foundation): A Swift package with tools to simplify web development.

### Third-Party Dependencies

- [pointfreeco/swift-dependencies](https://github.com/pointfreeco/swift-dependencies): A dependency management library for controlling dependencies in Swift.
- [pointfreeco/swift-snapshot-testing](https://github.com/pointfreeco/swift-snapshot-testing): Delightful snapshot testing for Swift.
- [apple/swift-collections](https://github.com/apple/swift-collections): Commonly used data structures for Swift.

## Related Projects

PointFreeHTML is part of a comprehensive Swift web development ecosystem:

### Core Libraries
- [swift-html](https://github.com/coenttb/swift-html): Type-safe HTML & CSS DSL built on PointFreeHTML -** use this for examples and full developer experience**
- [swift-html-css-pointfree](https://github.com/coenttb/swift-html-css-pointfree): Integration layer combining PointFreeHTML with CSS types - **use this as example for third-party library integration**
- [swift-html-standard](https://github.com/coenttb/swift-html-standard): Complete Swift domain model of HTML elements and attributes  
- [swift-css-types](https://github.com/coenttb/swift-css-types): Complete Swift domain model of CSS properties and types

### Extended Functionality
- [coenttb-html](https://github.com/coenttb/coenttb-html): Extensions for HTML, Markdown, Email, and PDF generation
- [pointfree-html-to-pdf](https://github.com/coenttb/swift-html-to-pdf): Convert HTML to PDF on iOS and macOS

### Server & Web
- [swift-web](https://github.com/coenttb/swift-web): Modular web development tools
- [coenttb-web](https://github.com/coenttb/coenttb-web): Feature collection for Swift servers
- [coenttb-server](https://github.com/coenttb/coenttb-server): Modern Swift server framework
- [coenttb-server-vapor](https://github.com/coenttb/coenttb-server-vapor): Vapor integration

### Utilities
- **[swift-languages](https://github.com/coenttb/swift-languages)**: Cross-platform translation library

## Documentation

Comprehensive documentation is available at the [Swift Package Index](https://swiftpackageindex.com/coenttb/pointfree-html/main/documentation/pointfreehtml).

## Acknowledgements

This project builds upon the foundational work by Point-Free (Brandon Williams and Stephen Celis). PointFreeHTML is a fork and adaptation of their original swift-html library.

## Contributing

Contributions are welcome! Please feel free to:

- Open issues for bugs or feature requests
- Submit pull requests
- Improve documentation
- Share your projects built with PointFreeHTML

## Feedback & Support

- **Issues**: [GitHub Issues](https://github.com/coenttb/pointfree-html/issues)
- **Newsletter**: [Subscribe](http://coenttb.com/en/newsletter/subscribe)
- **Social**: [Follow @coenttb](http://x.com/coenttb)
- **Professional**: [LinkedIn](https://www.linkedin.com/in/tenthijeboonkkamp)

## License

PointFreeHTML is licensed under the MIT License. See [LICENSE](LICENSE) for details.
