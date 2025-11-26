# ``PointFreeHTML/HTMLTag``

A factory for creating HTML elements with a function-call syntax.

## Overview

`HTMLTag` represents standard HTML tag names that can be used to create HTML elements. As described in the architecture tour, this design cleverly separates tag definitions from actual HTML elements, enabling both empty tags (`div()`) and content-containing tags (`div { ... }`) without code duplication.

The tag abstraction is a key architectural decision that enables PointFreeHTML's intuitive syntax while maintaining clean internal architecture.

## Tag-to-Element Transformation

`HTMLTag` acts as a factory that creates `HTMLElement` instances through its `callAsFunction()` methods:

```swift
// Empty element: div()
public func callAsFunction() -> HTMLElement<Empty>

// Element with content: div { ... }
public func callAsFunction<T: HTML>(@Builder _ content: () -> T) -> HTMLElement<T>
```

When you write `div { "Hello" }`, Swift interprets this as calling `div.callAsFunction { "Hello" }`, returning an `HTMLElement<HTMLText>` that conforms to `HTML` and can be rendered.

## Usage

### Empty Elements

```swift
// Self-closing or empty elements
let lineBreak = br()
let horizontalRule = hr()
let emptyDiv = div()
```

### Elements with Content

```swift
// Single content
let paragraph = p { "Hello, World!" }

// Multiple content using HTMLBuilder
let section = div {
    h1 { "Title" }
    p { "First paragraph" }
    p { "Second paragraph" }
}
```

### With Attributes and Styling

Tags work seamlessly with the attribute and styling systems:

```swift
let styledDiv = div {
    "Content"
}
.class("container")
.id("main-content")
.inlineStyle("padding", "20px")
.inlineStyle("background-color", "#f0f0f0")
```

## Predefined Tags

PointFreeHTML provides predefined tag instances for all standard HTML elements:

### Document Structure
- `html`, `head`, `body`, `title`, `meta`

### Content Sectioning  
- `header`, `nav`, `main`, `section`, `article`, `aside`, `footer`

### Text Content
- `div`, `p`, `h1`, `h2`, `h3`, `h4`, `h5`, `h6`, `ul`, `ol`, `li`

### Inline Elements
- `span`, `a`, `strong`, `em`, `code`, `small`

### Form Elements
- `form`, `input`, `button`, `label`, `select`, `option`, `textarea`

### Media Elements
- `img`, `video`, `audio`, `source`

### And many more...

## Custom Tags

You can create custom tags for specialized use cases:

```swift
// Custom web component
let customElement = HTMLTag("my-custom-element") {
    "Custom content"
}

// HTML5 semantic elements
let time = HTMLTag("time") {
    "2023-12-25"
}
.attribute("datetime", "2023-12-25")
```

## Why Tags Don't Conform to HTML

As explained in the architecture tour, this design choice solves a critical challenge: providing both empty and content versions without code duplication. The `HTMLTag` serves as a factory that creates `HTMLElement` instances, which do conform to `HTML`.

This separation enables:

- **Consistent syntax**: Both `div()` and `div { ... }` work naturally
- **Type safety**: Each variant returns appropriately typed `HTMLElement`
- **Performance**: No overhead from conforming to `HTML` protocol
- **Flexibility**: Easy to extend with new tag types

## Integration with Result Builders

Tags work seamlessly with `HTMLBuilder` to enable declarative HTML construction:

```swift
struct BlogPost: HTML {
    let post: Post
    
    var body: some HTML {
        article {
            header {
                h1 { post.title }
                time { formatDate(post.publishedAt) }
                    .attribute("datetime", isoDate(post.publishedAt))
            }
            
            div {
                post.content
            }
            .class("post-content")
        }
    }
}
```

## Topics

### Creating Elements

- ``callAsFunction()-7mjn5``
- ``callAsFunction(_:)-8ww66``

### Tag Properties

- ``rawValue``

### Initialization

- ``init(_:)``
- ``init(stringLiteral:)``
