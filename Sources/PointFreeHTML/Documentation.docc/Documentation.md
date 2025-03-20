# ``PointFreeHTML``

A type-safe, declarative HTML library for Swift with a SwiftUI-like syntax.

## Overview

PointFreeHTML is a Swift library for building HTML in a type-safe, declarative way. It provides a DSL (Domain-Specific Language) that closely mirrors the structure of HTML while leveraging Swift's strong type system to catch errors at compile time rather than runtime.

```swift
import PointFreeHTML

struct MyDocument: HTMLDocument {
    var head: some HTML {
        title { "My Web Page" }
        meta()
            .attribute("charset", "utf-8")
        meta()
            .attribute("name", "viewport")
            .attribute("content", "width=device-width, initial-scale=1")
    }

    var body: some HTML {
        div {
            h1 { "Welcome to PointFreeHTML" }
            p {
                "This is a declarative way to write HTML in Swift. "
                "It's type-safe and feels like "
                strong { "SwiftUI" }
                "."
            }
            
            if showFeatureList {
                ul {
                    HTMLForEach(features) { feature in
                        li { feature }
                    }
                }
            }
        }
        .inlineStyle("max-width", "800px")
        .inlineStyle("margin", "0 auto")
        .inlineStyle("font-family", "system-ui, sans-serif")
    }
    
    var showFeatureList = true
    let features = [
        "Type-safety",
        "Declarative syntax",
        "CSS support",
        "Efficient rendering",
        "Composable components"
    ]
}
```

## Key Features

### Declarative Syntax

Write HTML with a SwiftUI-like syntax that leverages Swift's result builders to create a natural, hierarchical structure that closely mirrors HTML.

### Type Safety

Catch HTML structure and attribute errors at compile time, rather than discovering them at runtime or during testing.

### CSS Integration

Apply CSS styles directly to elements with the `inlineStyle` method, which automatically generates optimized stylesheets.

### Efficient Rendering

Renders directly to bytes with minimal overhead, avoiding intermediate string representations.

### Composable Design

Build reusable components and compose them together to create complex HTML structures.

## Getting Started

### Installation

Add PointFreeHTML to your Swift package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/pointfree-html.git", from: "0.0.1")
]
```

### Basic Usage

Import the library and create your HTML:

```swift
import PointFreeHTML

// Create a simple HTML element
let content = p {
    "Hello, "
    b { "World" }
    "!"
}

// Render it to a string
let htmlString = String(bytes: content.render(), encoding: .utf8)!
```

### Creating Complete HTML Documents

For full HTML documents, conform to the `HTMLDocument` protocol:

```swift
struct HomePage: HTMLDocument {
    var head: some HTML {
        title { "Home Page" }
        meta().attribute("charset", "utf-8")
    }
    
    var body: some HTML {
        div {
            h1 { "Welcome" }
            p { "This is my home page." }
        }
    }
}

let document = HomePage()
let htmlBytes = document.render()
```

## Topics

### Core Components

- ``HTML``
- ``HTMLDocument``
- ``HTMLBuilder``
- ``HTMLElement``
- ``HTMLTag``

### HTML Content

- ``HTMLText``
- ``HTMLRaw``
- ``HTMLEmpty``
- ``HTMLGroup``
- ``HTMLForEach``

### Styling

- ``HTMLInlineStyle``
- ``MediaQuery``
- ``Pseudo``

### Attributes

- ``_HTMLAttributes``
- ``InputType``

### Rendering

- ``HTMLPrinter``

### Articles

- <doc:BuildingReusableComponents>
