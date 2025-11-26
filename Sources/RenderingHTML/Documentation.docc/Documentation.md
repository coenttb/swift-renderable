# ``PointFreeHTML``

**Build HTML in Swift with the performance, type safety, and elegance your library deserves.**

PointFreeHTML brings SwiftUI-style declarative syntax to HTML generation. Write HTML that feels like native Swift code—because it is. No string templates, no runtime crashes, just pure Swift that compiles to lightning-fast byte streams.

## Why PointFreeHTML?

### ⚡ **Performance that scales**
- **780,000+ elements/second** for plain HTML
- **10,000+ styled elements/second** with automatic CSS optimization
- **Direct byte rendering** - no string concatenation overhead
- **Memory efficient** - predictable ~523 bytes per element

### 🛡️ **Type safety throughout**
- **Compile-time validation** - malformed HTML won't compile
- **No runtime surprises** - catch errors during development
- **Refactoring confidence** - rename methods and properties safely
- **Full IDE support** - autocompletion and inline documentation

### 🎨 **Developer experience that works**
- **Familiar syntax** - if you know SwiftUI, you know PointFreeHTML
- **Result builders** - natural HTML structure with `@Builder`
- **Smart CSS handling** - automatic deduplication and optimization
- **Easy integration** - extend your existing types with a few lines

## Quick start

### Installation

Add PointFreeHTML to your package dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/coenttb/pointfree-html.git", from: "0.0.1")
]
```

## Real-world example

Here's a complete blog post component using one PointFreeHTML integration: [swift-html](https://github.com/coenttb/swift-html):

```swift
struct BlogPost: HTML {
    let post: Post
    
    var body: some HTML {
        article {
            header {
                h1 { post.title }
                time { post.date.formatted() }
                    .datetime(post.date.iso8601)
                    .color(.hex("#666"))
                    .fontSize(.rem(0.9))
            }
            
            div { HTMLRaw(post.htmlContent) }
                .lineHeight(1.6)
                .margin(.rem(2), 0)
            
            if !post.tags.isEmpty {
                footer {
                    HTMLForEach(post.tags) { tag in
                        span { tag }
                            .background", .color(.hex("#eee")))
                            .padding(.rem(0.25), .rem(0.5))
                            .borderRadius(.px(3)
                            .marginRight(.rem(0.5)
                    }
                }
            }
        }
        .maxWidth(.px(800))
        .margin(0, .auto)
        .padding(.rem(2))
    }
}
```
> TIP: 
>
> You can even **preview** HTML components using [swift-html](https://github.com/coenttb/swift-html):

> ```swift
> import SwiftUI
> #Preview {
>     HTMLDocument {
>         h1 { "Hello world!" }
>             .color(.red)
>     }
> }
```

### Your first component

```swift
import PointFreeHTML

struct WelcomeMessage: HTML {
    let name: String
    
    var body: some HTML {
        tag("div") {
            tag("h1") { "Hello, \(name)!" }
            tag("p") { "Welcome to type-safe HTML generation." }
        }
        .inlineStyle("padding", "2rem")
        .inlineStyle("color", "#333")
    }
}
```

### Rendering options

```swift
let welcome = WelcomeMessage(name: "Developer")

// Get raw bytes for maximum performance
let htmlBytes: ContiguousArray<UInt8> = welcome.render()

// Or convert to string when needed
let htmlString: String = try String(welcome)
```

### Complete documents

Build full HTML5 documents with proper structure:

```swift
let document = HTMLDocument {
    WelcomeMessage(name: "World")
} head: {
    tag("title") { "My App" }
    tag("meta").attribute("charset", "utf-8")
    tag("meta")
        .attribute("name", "viewport")
        .attribute("content", "width=device-width, initial-scale=1")
}

let html = try String(document)
```

## Core concepts

### The HTML protocol: simple yet powerful

Everything starts with this protocol:

```swift
public protocol HTML {
    associatedtype Content: HTML
    @Builder var body: Content { get }
    static func _render(_ html: Self, into printer: inout HTMLPrinter)
}
```

This recursive design enables composability. Components delegate rendering to their body, creating a natural hierarchy that matches HTML's structure.

### Declarative syntax that feels right

Build interfaces using patterns you already know:

```swift
struct UserCard: HTML {
    let user: User
    
    var body: some HTML {
        tag("div") {
            tag("img")
                .attribute("src", user.avatarURL)
                .attribute("alt", "\(user.name)'s avatar")
                .inlineStyle("border-radius", "50%")
                .inlineStyle("width", "64px")
            
            tag("div") {
                tag("h3") { user.name }
                tag("p") { user.bio }
            }
        }
        .inlineStyle("display", "flex")
        .inlineStyle("gap", "1rem")
        .inlineStyle("padding", "1rem")
    }
}
```

### CSS optimization built in

PointFreeHTML handles CSS intelligently:
- **Automatic deduplication** - identical styles share classes
- **Efficient selectors** - short, optimized class names
- **Media query support** - responsive design made easy
- **Pseudo-class handling** - `:hover`, `:focus`, and more
- **Clean output** - all CSS collected in document head

```swift
// These elements automatically share a CSS class
tag("p") { "Red text" }.inlineStyle("color", "red")
tag("span") { "Also red" }.inlineStyle("color", "red")

// Output:
// <style>.c0{color:red}</style>
// <p class="c0">Red text</p>
// <span class="c0">Also red</span>
```

## Advanced patterns

### Composable components

Create reusable wrappers for common patterns:

```swift
struct Card<Content: HTML>: HTML {
    let content: Content
    
    init(@Builder content: () -> Content) {
        self.content = content()
    }
    
    var body: some HTML {
        tag("div") { content }
            .inlineStyle("border", "1px solid #ddd")
            .inlineStyle("border-radius", "8px")
            .inlineStyle("padding", "1rem")
    }
}

// Usage is clean and intuitive
Card {
    tag("h2") { "Product name" }
    tag("p") { "Description here" }
}
```

### Efficient collections

Render arrays without boilerplate:

```swift
struct ProductGrid: HTML {
    let products: [Product]
    
    var body: some HTML {
        tag("div") {
            HTMLForEach(products) { product in
                ProductCard(product: product)
            }
        }
        .inlineStyle("display", "grid")
        .inlineStyle("grid-template-columns", "repeat(auto-fill, minmax(300px, 1fr))")
        .inlineStyle("gap", "1rem")
    }
}
```

### Integration with your types

Make your existing HTML/CSS types work with PointFreeHTML:

```swift
// Add rendering capability to your color type
extension HTML {
    func foregroundColor(_ color: YourColorType) -> HTMLInlineStyle<Self> {
        self.inlineStyle("color", color.cssValue)  
    }
}

// Now it works everywhere
tag("p") { "Styled text" }
    .foregroundColor(.primary)
```

## Performance in practice

Real benchmarks from actual hardware:

| What you're building | Speed | Memory |
|---------------------|-------|---------|
| Plain HTML | 780,000+ elements/sec | ~523 bytes/element |
| Styled components | 10,000+ elements/sec | Efficient deduplication |
| Complex forms | 4,700+ fields/sec | Scales linearly |
| Deep nesting | 109,000+ levels/sec | Stack efficient |

**Why it's fast:**
- Renders directly to bytes (no string building)
- Zero-copy operations where possible
- Hash-based style deduplication
- Compile-time optimizations via result builders

Curious about performance? Check out our <doc:PerformanceGuide>.

## For library authors

PointFreeHTML is designed with library authors in mind:

- **Non-invasive integration** - your types stay independent
- **Gradual adoption** - integrate one component at a time
- **Extensible design** - add custom functionality easily
- **Performance focused** - minimal overhead for your users

Want to integrate your library? See <doc:IntegrateyourlibrarywithPointFreeHTML>.

## Learn more

### Essential guides

- <doc:ATourofPointFreeHTML> - Understand the architecture and design decisions
- <doc:IntegrateyourlibrarywithPointFreeHTML> - Connect your existing types seamlessly
- <doc:TestingPointFreeHTML.md> - Write tests that matter, skip the rest
- <doc:PerformanceGuide> - Optimization strategies and benchmarks
- <doc:HigherOrderComponents> - Advanced composition patterns

### Get started

PointFreeHTML makes HTML generation in Swift a pleasure. Whether you're building a web framework, generating email templates, or creating documentation, you'll appreciate the type safety, performance, and clean syntax.

**Ready to upgrade your HTML generation?** Install PointFreeHTML and see the difference type-safe, performant HTML makes.

## Topics

### Core components

- ``HTML``
- ``HTMLDocument``
- ``HTMLBuilder``
- ``HTMLElement``
- ``HTMLTag``

### HTML content

- ``HTMLText``
- ``HTMLRaw``
- ``Empty``
- ``Group``
- ``HTMLForEach``

### HTML attributes

- ``HTML.attribute(name:value:)``

### Styling

- ``HTMLInlineStyle``
- ``MediaQuery``
- ``Pseudo``

### Rendering

- ``HTMLPrinter``

### Articles

- <doc:ATourofPointFreeHTML>
- <doc:IntegrateyourlibrarywithPointFreeHTML>
- <doc:TestingPointFreeHTML>
- <doc:PerformanceGuide>
- <doc:HigherOrderComponents>
