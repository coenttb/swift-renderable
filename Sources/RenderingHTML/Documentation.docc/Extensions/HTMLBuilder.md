# ``PointFreeHTML/HTMLBuilder``

A result builder that enables declarative HTML construction with SwiftUI-like syntax.

## Overview

`HTMLBuilder` is the result builder that powers PointFreeHTML's declarative syntax. It transforms Swift code blocks into HTML structures, supporting all the language features you'd expect: conditionals, loops, optional unwrapping, and more.

The builder automatically handles the composition of multiple HTML elements, making it feel natural to build complex hierarchies of content. As mentioned in your blog tour, this is what enables the elegant recursive definition of the `HTML` protocol.

## Basic Usage

### Simple Composition

```swift
let content = div {
    h1 { "Welcome to My Site" }
    p { "This is built with PointFreeHTML." }
    button { "Get Started" }
}
```

### With Variables and Expressions

```swift
let title = "My Blog"
let posts = ["First Post", "Second Post"]

let blogPage = div {
    header {
        h1 { title }
        nav { /* navigation content */ }
    }
    
    main {
        for post in posts {
            article {
                h2 { post }
                p { "Content for \(post)" }
            }
        }
    }
}
```

## Supported Language Features

### Conditionals

The builder supports `if`, `if-else`, and complex conditional logic through `buildEither` methods:

```swift
struct UserCard: HTML {
    let user: User
    let showActions: Bool
    
    var body: some HTML {
        div {
            h3 { user.name }
            p { user.email }
            
            // Simple conditional
            if user.isVerified {
                span { "✓ Verified" }
                    .class("verified-badge")
            }
            
            // If-else conditional  
            if showActions {
                div {
                    button { "Edit" }
                    button { "Delete" }
                }
            } else {
                p { "Read-only view" }
            }
        }
    }
}
```

### Loops and Arrays

Any Swift iteration construct works within the builder, handled by `buildArray`:

```swift
struct ProductList: HTML {
    let products: [Product]
    
    var body: some HTML {
        div {
            // For-in loop creates _HTMLArray internally
            for product in products {
                div {
                    h4 { product.name }
                    p { "$\(product.price)" }
                }
                .class("product-card")
            }
        }
    }
}
```

### Optional Content

Optional values are handled seamlessly through `buildOptional`:

```swift
struct ProfileView: HTML {
    let user: User
    
    var body: some HTML {
        div {
            h2 { user.name }
            
            // Optional unwrapping
            if let bio = user.bio {
                p { bio }
            }
            
            // Optional content directly
            user.avatar.map { url in
                img()
                    .src(url)
                    .alt("\(user.name)'s avatar")
            }
        }
    }
}
```

## Internal Builder Components

The builder uses several internal types to manage different kinds of content efficiently:

### HTMLText: Safe String Handling

String literals and interpolated strings create `HTMLText` instances that handle proper HTML escaping automatically:

```swift
// This creates HTMLText with automatic escaping
let content = p { "User input: \(userInput)" }
```

The `HTMLText` type ensures that special characters (`&`, `<`, `>`) are properly escaped to prevent HTML injection vulnerabilities.

### Arrays and Collections

When you use loops, the builder creates `_HTMLArray<Element>` internally to efficiently render collections of elements without intermediate string allocations.

### Conditionals

If-else statements create `_HTMLConditional<First, Second>` types that decide which branch to render at runtime, enabling type-safe conditional content.

### Tuples

Multiple elements in a block are combined into `_HTMLTuple` types that render each element in sequence, preserving the declarative structure.

## Advanced Patterns

### Building Custom Result Builders

You can create specialized result builders for specific use cases:

```swift
@resultBuilder
struct TableRowBuilder {
    static func buildBlock(_ cells: HTMLTableCell...) -> [HTMLTableCell] {
        cells
    }
}

struct HTMLTable: HTML {
    let rows: [[HTMLTableCell]]
    
    init(@TableRowBuilder builder: () -> [[HTMLTableCell]]) {
        self.rows = builder()
    }
    
    var body: some HTML {
        table {
            for row in rows {
                tr {
                    for cell in row {
                        cell
                    }
                }
            }
        }
    }
}
```

### Nested Builders

Builders compose naturally for complex content, enabling the recursive elegance described in the tour:

```swift
struct Dashboard: HTML {
    let widgets: [Widget]
    
    var body: some HTML {
        div {
            header { /* header content */ }
            
            main {
                div {  // Grid container
                    for widget in widgets {
                        div {  // Widget container
                            h3 { widget.title }
                            
                            // Widget-specific content
                            switch widget.type {
                            case .chart:
                                renderChart(widget.data)
                            case .stats:
                                div {
                                    for stat in widget.stats {
                                        span { "\(stat.label): \(stat.value)" }
                                    }
                                }
                            }
                        }
                        .class("widget")
                    }
                }
                .class("widget-grid")
            }
        }
    }
}
```

## Performance Considerations

The builder is designed for efficiency, as highlighted in the architecture tour:

- **Lazy evaluation**: Content is only rendered when converted to a string or bytes
- **Memory efficiency**: Minimal intermediate allocations during building
- **Direct byte rendering**: No intermediate string representations
- **Automatic capacity management**: The underlying printer reserves appropriate capacity

## Integration with the HTML Protocol

The builder works seamlessly with the recursive `HTML` protocol definition. When you define a `body` property with `@Builder`, the result builder transforms your declarative syntax into the appropriate `Content` type, which then participates in the elegant delegation pattern described in the architecture overview.

## Topics

### Core Builder Methods

- ``PointFreeHTML/HTMLBuilder/buildBlock()``
- ``PointFreeHTML/HTMLBuilder/buildArray(_:)``
- ``PointFreeHTML/HTMLBuilder/buildOptional(_:)``
- ``PointFreeHTML/HTMLBuilder/buildEither(first:)``
- ``PointFreeHTML/HTMLBuilder/buildEither(second:)``

### Expression Handling

- ``PointFreeHTML/HTMLBuilder/buildExpression(_:)->HTMLText``
- ``PointFreeHTML/HTMLBuilder/buildExpression(_:)->T``
- ``PointFreeHTML/HTMLBuilder/buildFinalResult(_:)``

