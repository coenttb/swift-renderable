# ``PointFreeHTML/_HTMLAttributes``

A wrapper that applies HTML attributes to elements in a chainable, type-safe manner.

## Overview

`_HTMLAttributes` is the internal type that powers PointFreeHTML's attribute system. While you typically interact with attributes through the `.attribute(_:_:)` method on HTML elements, understanding this wrapper helps explain how the elegant chainable API works.

As described in the architecture tour, all HTML attributes are implemented through a single extension that creates this wrapper type.

## How Attributes Work

### The Extension Pattern

All HTML attributes use a single extension on the `HTML` protocol:

```swift
extension HTML {
    public func attribute(_ name: String, _ value: String? = "") -> _HTMLAttributes<Self> {
        _HTMLAttributes(content: self, attributes: value.map { [name: $0] } ?? [:])
    }
}
```

This enables a fluent, chainable API:

```swift
a { "Visit our website" }
    .attribute("href", "https://example.com")
    .attribute("target", "_blank")
    .attribute("rel", "noopener")
```

### The Wrapper Structure

`_HTMLAttributes` contains:
- The original HTML content
- An `OrderedDictionary<String, String>` of attributes to apply

```swift
public struct _HTMLAttributes<Content: HTML>: HTML.View {
    let content: Content
    var attributes: OrderedDictionary<String, String>
}
```

### Chaining Attributes

Each time you chain another attribute, it creates a modified copy with the new attribute added:

```swift
public func attribute(_ name: String, _ value: String? = "") -> _HTMLAttributes<Content> {
    var copy = self
    copy.attributes[name] = value
    return copy
}
```

## Rendering Process

The wrapper uses direct rendering rather than delegating through a `body` property:

```swift
public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
    let previousValue = printer.attributes
    defer { printer.attributes = previousValue }
    printer.attributes.merge(html.attributes, uniquingKeysWith: { $1 })
    Content._render(html.content, into: &printer)
}
```

This method:
1. Saves the current printer attributes
2. Merges in the new attributes (newer values override older ones)  
3. Renders the wrapped content with access to these attributes
4. Restores the previous attributes using `defer`

## Usage Examples

### Basic Attributes

```swift
div { "Content" }
    .attribute("id", "main-content")
    .attribute("class", "container")
    .attribute("data-testid", "main-div")
```

### Form Elements

```swift
input()
    .attribute("type", "email")
    .attribute("name", "email")
    .attribute("placeholder", "Enter your email")
    .attribute("required", "")
```

### Custom Data Attributes

```swift
div { "Widget" }
    .attribute("data-widget-id", widget.id)
    .attribute("data-config", widget.configJSON)
    .attribute("aria-label", "Interactive widget")
```

### Conditional Attributes

```swift
button { "Submit" }
    .attribute("type", "submit")
    .attribute("disabled", isLoading ? "" : nil)
    .attribute("aria-busy", isLoading ? "true" : "false")
```

## Attribute Value Handling

The attribute method handles different value scenarios:

- **`nil`**: Attribute is omitted entirely
- **Empty string `""`**: Attribute included without a value (e.g., `disabled`)
- **Non-empty string**: Attribute included with the value

```swift
// Results in: <input disabled required type="text">
input()
    .attribute("type", "text")
    .attribute("disabled", "")      // Boolean attribute
    .attribute("required", "")      // Boolean attribute  
    .attribute("hidden", nil)       // Omitted entirely
```

## Performance Considerations

The wrapper is designed for efficiency:

- **Copy-on-write semantics**: Only creates copies when attributes change
- **Ordered dictionary**: Maintains consistent attribute order
- **Deferred restoration**: Uses Swift's `defer` to safely manage state
- **Direct rendering**: No intermediate string representations

## Integration with Styling

Attributes work seamlessly with the inline styling system:

```swift
div { "Styled content" }
    .attribute("id", "unique-element")
    .attribute("role", "button")
    .inlineStyle("background-color", "blue")
    .inlineStyle("color", "white")
    .attribute("tabindex", "0")
```

The styling system actually uses the attribute system internally, adding generated class names as `class` attributes.

## Architectural Benefits

This wrapper pattern provides several advantages:

- **Type safety**: Attributes are checked at compile time
- **Chainability**: Natural, fluent API for building elements  
- **Composability**: Works with any HTML element
- **Performance**: Efficient rendering without string concatenation
- **Flexibility**: Supports any HTML attribute, standard or custom

The `_HTMLAttributes` wrapper is a key part of what makes PointFreeHTML's attribute system both powerful and elegant, enabling the declarative, chainable API that feels natural in Swift.

## Topics

### Core Functionality

- ``attribute(_:_:)``

### Content and Attributes

- ``content``
- ``attributes``
