# ``PointFreeHTML/HTMLDocument``

A complete HTML document with head and body sections.

## Overview

The `HTMLDocument` struct provides a convenient way to create complete HTML documents using PointFreeHTML's declarative syntax. It implements the `HTMLDocumentProtocol` and automatically handles the complex rendering pipeline described in the architecture tour.

Unlike basic `HTML` elements, `HTMLDocument` orchestrates the complete document generation process, including:

- DOCTYPE declaration
- HTML structure with `<html>`, `<head>`, and `<body>` tags
- Automatic stylesheet collection and injection
- Proper head/body separation

## Creating Documents

### Simple Document Creation

```swift
let document = HTML.Document {
    // Body content
    div {
        h1 { "Welcome to My Site" }
        p { "This is a complete HTML document." }
    }
} head: {
    // Head content  
    title { "My Site" }
    meta().charset("utf-8")
}
```

### Alternative Initialization

```swift
let document = HTMLDocument(
    head: {
        title { "My Site" }
        meta().charset("utf-8")
        meta().name("viewport").content("width=device-width, initial-scale=1")
    },
    body: {
        div {
            h1 { "Welcome" }
            p { "Built with PointFreeHTML" }
        }
    }
)
```

## Rendering Pipeline

As detailed in the tour, `HTMLDocument` follows a sophisticated rendering approach:

### 1. Body Pre-rendering

The document first renders the body content into a separate `HTMLPrinter`:

```swift
@Dependency(\.htmlPrinter) var htmlPrinter
var bodyPrinter = htmlPrinter
Content._render(html.body, into: &bodyPrinter)
```

### 2. Stylesheet Collection

During body rendering, any inline styles are automatically collected into `bodyPrinter.stylesheet`. This enables the elegant styling system described in the tour where styles are defined with elements but rendered as a proper stylesheet.

### 3. Complete Document Assembly

The final document is assembled with:

- DOCTYPE declaration (`<!DOCTYPE html>`)
- HTML root element with language attributes
- Head section containing metadata and collected styles
- Body section with the pre-rendered content

```swift
Document(
    head: html.head,
    stylesheet: bodyPrinter.stylesheet,
    bodyBytes: bodyPrinter.bytes
)
```

## Advanced Features

### Dependency Integration

`HTMLDocument` integrates with Swift Dependencies to access the `HTMLPrinter` configuration:

```swift
let document = HTML.Document {
    div { "Content" }
        .inlineStyle("color", "blue")
}

// Configure rendering
withDependencies {
    $0.htmlPrinter.configuration = .pretty
} {
    let html = try String(document)
    print(html) // Pretty-formatted output
}
```

### Stylesheet Management

The document automatically handles stylesheet generation from inline styles:

```swift
let styledDocument = HTML.Document {
    div { "Styled content" }
        .inlineStyle("color", "blue")
        .inlineStyle("font-size", "1.2em")
} head: {
    title { "Styled Page" }
}

// Renders with:
// - Styles collected in <style> tag in head
// - Elements with appropriate class names
// - No duplicate style definitions
```

## Protocol Conformance

`HTMLDocument` conforms to `HTMLDocumentProtocol`, which extends the basic `HTML` protocol with document-specific requirements:

```swift
public protocol HTMLDocumentProtocol: HTML.View {
    associatedtype Head: HTML
    
    @HTML.Builder
    var head: Head { get }
}
```

This protocol enables the sophisticated rendering pipeline while maintaining compatibility with the broader `HTML` ecosystem.

## Performance Considerations

The document rendering process is optimized for efficiency:

- **Two-phase rendering**: Body rendered once, then composed into final document
- **Stylesheet deduplication**: Identical styles are automatically merged
- **Memory efficiency**: Direct byte manipulation without intermediate strings
- **Lazy evaluation**: Content only rendered when converted to string/bytes

## Usage with Web Frameworks

`HTMLDocument` integrates seamlessly with web frameworks:

```swift
// Vapor
app.get("home") { req in
    let document = HTML.Document {
        homePage(for: req.user)
    } head: {
        title { "Home - My App" }
        meta().charset("utf-8")
    }
    
    return try String(document)
}
```

## Topics

### Creating Documents

- ``init(body:head:)-4uxa6``
- ``init(head:body:)-7z2vn``

### Document Structure

- ``head``
- ``body``

### Protocol Conformance

- ``HTMLDocumentProtocol``
