# Integrate your library with PointFreeHTML

Want to use PointFreeHTML with your existing HTML/CSS types? Here's how to make them work together beautifully.

## The integration philosophy

PointFreeHTML plays nicely with others. Instead of forcing you to rewrite everything, it lets you **add rendering superpowers to your existing types** with just a few extensions.

Think of it like adding a printer to your computer. Your documents don't change - you just gain the ability to print them. Same idea here: your HTML and CSS types stay the same, but now they can render through PointFreeHTML.

Let's see how this works with a real example.

## Case study: making anchor elements work with styling

We'll integrate a complete HTML anchor element (the `<a>` tag) with href attributes and color styling. This example shows the pattern you can use for any HTML/CSS library.

### Step 1: your foundation types (before integration)

Let's say you have these types in your codebase. Notice they know nothing about PointFreeHTML:

#### Your HTML element type

```swift
// Your existing Anchor type - totally independent
public struct Anchor: HTMLElement {
    public static var tag: String { "a" }
    
    public var href: HTMLAttributeTypes.Href?
    public var target: HTMLAttributeTypes.Target?
    public var rel: HTMLAttributeTypes.Rel?
    
    public init(
        href: HTMLAttributeTypes.Href? = nil,
        target: HTMLAttributeTypes.Target? = nil,
        rel: HTMLAttributeTypes.Rel? = nil
    ) {
        self.href = href
        self.target = target
        self.rel = rel
    }
}

// Convenience alias
public typealias a = Anchor
```

#### Your attribute types

```swift
// Type-safe href attribute
@dynamicMemberLookup
public struct Href: HTMLStringAttribute {
    public static var attribute: String { "href" }
    public let rawValue: String
    
    public init(value: String) {
        self.rawValue = value
    }
}

// Convenient factory methods
extension Href {
    public static func mailto(_ email: String) -> Href {
        Href(value: "mailto:\(email)")
    }
    
    public static func tel(_ phoneNumber: String) -> Href {
        Href(value: "tel:\(phoneNumber)")
    }
    
    public static func fragment(_ fragment: String) -> Href {
        Href(value: "#\(fragment)")
    }
}
```

#### Your CSS color type

```swift
// Type-safe color values
public indirect enum Color: Sendable, Hashable {
    case named(NamedColor)
    case hex(HexColor)
    case rgb(Int, Int, Int)
    case rgba(Int, Int, Int, Double)
    
    // Convenient shortcuts
    public static let red: Color = .named(.red)
    public static let blue: Color = .named(.blue)
    public static let green: Color = .named(.green)
}
```

These types are **your types**. They don't depend on PointFreeHTML. They can live in their own package, have their own tests, and be used anywhere.

### Step 2: the magic of extensions

Now let's make these types work with PointFreeHTML. We don't modify your types - we just extend them:

#### Making attributes work

```swift
// Add this extension to connect Href with PointFreeHTML
import HTMLAttributeTypes
import PointFreeHTML

extension HTML {
    @discardableResult
    public func href(_ value: Href?) -> _HTMLAttributes<Self> {
        self.attribute(Href.attribute, value?.description)
    }
}
```

That's it! Now any HTML element can use your type-safe `Href`:

```swift
// This now works!
div { "Click me" }
    .href(.mailto("contact@example.com"))

button { "Call us" }
    .href(.tel("+1-555-123-4567"))
```

> **Pro tip**: You might not want div elements to have href attributes (that's not valid HTML). In the real `swift-html-css-pointfree` library, these methods are implementation details; attributes are only set via the element's initializer.

#### Making elements work

```swift
// Make your Anchor callable as a function returning some HTML
extension HTML_Standard_Elements.Anchor {
    public func callAsFunction(
        @Builder _ content: () -> some HTML
    ) -> some HTML {
        HTMLElement(tag: Self.tag) { content() }
            .href(self.href)
            .target(self.target)
            .rel(self.rel)
    }
}
```

Now your anchor works like native PointFreeHTML elements:

```swift
// Beautiful, type-safe links!
let link = a(
    href: .mailto("hello@example.com"),
    target: .blank,
    rel: .noopener
) {
    "Send us an email"
}
```

#### Making CSS properties work

```swift
// Connect your Color type to PointFreeHTML's styling
extension HTML {
    @discardableResult
    public func color(
        _ color: W3C_CSS_Color.Color?,
        media: W3C_CSS_MediaQueries.Media? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        self.inlineStyle(color, media: media, pseudo: pseudo)
    }
}
```

And voilà - type-safe colors everywhere:

```swift
// Your colors, now with rendering powers!
div { "Colorful text" }
    .color(.rgb(255, 0, 0))

p { "Blue paragraph" }
    .color(.hex("#0066cc"))
```

### Step 3: enjoying the result

With these simple extensions, you can now write beautiful, type-safe HTML:

```swift
let styledLink = a(
    href: .mailto("support@company.com"),
    rel: .noopener
) {
    "Contact Support"
}
.color(.blue)
.inlineStyle("text-decoration", "underline")
.inlineStyle("font-weight", "bold")
```

This produces exactly what you'd expect:

```html
<a href="mailto:support@company.com" 
   rel="noopener" 
   class="color-xyz123"
>Contact Support</a>
```

## The integration recipe

Here's the pattern you can follow for any integration:

### For HTML attributes

```swift
// The recipe:
extension HTML {
    @discardableResult
    public func yourAttribute(_ value: YourType?) -> _HTMLAttributes<Self> {
        self.attribute("attribute-name", value?.description)
    }
}
```

It's that simple. Your type provides the value, PointFreeHTML handles the rendering.

### For HTML elements

```swift
// The recipe:
extension YourElement {
    public func callAsFunction(
        @Builder _ content: () -> some HTML
    ) -> some HTML {
        HTMLElement(tag: Self.tag) { content() }
            .yourAttribute(self.yourAttributeValue)
            .anotherAttribute(self.anotherValue)
            // ... map all your attributes
    }
}
```

Your element becomes a function that produces PointFreeHTML. Clean and intuitive.

### For CSS properties

```swift
// The recipe:
extension HTML {
    @discardableResult
    public func yourProperty(
        _ value: YourCSSType?,
        media: MediaQuery? = nil,
        pseudo: Pseudo? = nil
    ) -> HTMLInlineStyle<Self> {
        self.inlineStyle(value, media: media, pseudo: pseudo)
    }
}
```

Your CSS types get automatic style deduplication and all of PointFreeHTML's optimization.

## Why this approach rocks

### 1. Your types stay yours

Your HTML and CSS types don't need to import PointFreeHTML. They stay clean and independent:

```swift
// Use your types anywhere
let href = Href.mailto("test@example.com")  // Works without PointFreeHTML
let color = Color.red                        // Just a color enum

// But they also integrate seamlessly when needed
let html = a(href: href) { "Click" }.color(color)  // Magic!
```

### 2. Add features as you need them

Start small, grow gradually:

```swift
// Day 1: Just add one attribute
div { "Hello" }.href(.fragment("section"))

// Day 7: Add your element type
a(href: .fragment("section")) { "Hello" }

// Day 14: Add styling
a(href: .fragment("section")) { "Hello" }.color(.blue)

// No big rewrites needed!
```

### 3. The compiler has your back

Type safety everywhere means fewer bugs:

```swift
// This won't even compile - the types protect you
div { "Text" }
    .href(Color.red)  // ❌ Error: Can't use Color as Href

// This works perfectly
div { "Text" }
    .href(.mailto("test@example.com"))  // ✅ Type-safe href
    .color(.red)                        // ✅ Type-safe color
```

### 4. Zero performance penalty

Extensions compile away to nothing. This integration:

```swift
a(href: .mailto("test@example.com")) { "Email" }.color(.red)
```

Is exactly as fast as writing:

```swift
HTMLElement(tag: "a") { "Email" }
    .attribute("href", "mailto:test@example.com")
    .inlineStyle("color", "red")
```

But way more pleasant to write and read!

## Testing your integration

Keep your integration tests simple and focused:

```swift
@Test("Anchor integrates with styling")
func testAnchorIntegration() {
    let link = a(
        href: .mailto("test@example.com"),
        rel: .noopener
    ) {
        "Contact Us"
    }
    .color(.red)
    
    assertInlineSnapshot(of: link, as: .html) {
        """
        <a href="mailto:test@example.com" rel="noopener" class="color-xyz123">
            Contact Us
        </a>
        """
    }
}
```

**What we're testing**: That our extension correctly maps typed values to HTML.
**What we're NOT testing**: How PointFreeHTML renders (that's their job).

Want to know more about testing? Check out our [testing guide](TestingPointFreeHTML.md).

## Getting started with your integration

### 1. Pick one thing

Start with your most-used HTML element or CSS property. Don't try to integrate everything at once.

### 2. Write the extension

Use the recipes above. It's usually 5-10 lines of code per integration.

### 3. Test it works

Write one test to verify the output. Keep it simple.

### 4. Use it for real

Try it in your actual code. Does it feel good? If not, adjust.

### 5. Repeat

Add more integrations as you need them. There's no rush.

## A complete example

Here's what a real page looks like with full integration:

```swift
import HTMLElementTypes
import CSSTypes
import PointFreeHTML

let contactPage = HTMLDocument {
    div {
        h1 { "Get in touch" }
        
        p {
            "Questions? Email us at "
            a(href: .mailto("hello@company.com")) {
                "hello@company.com"
            }
            .color(.blue)
        }
        
        p {
            "Prefer to talk? Call "
            a(href: .tel("+1-555-123-4567")) {
                "(555) 123-4567"
            }
            .color(.green)
            .inlineStyle("font-weight", "bold")
        }
        
        a(href: .fragment("contact-form")) {
            "Skip to contact form ↓"
        }
        .color(.rgb(100, 50, 200))
    }
    .inlineStyle("padding", "2rem")
    .inlineStyle("font-family", "system-ui")
} head: {
    title { "Contact Us" }
}
```

This gives you:
- ✅ Type-safe attributes (no typos in href values)
- ✅ Type-safe colors (no invalid color strings)
- ✅ Beautiful Swift syntax
- ✅ All of PointFreeHTML's rendering performance

## The bottom line

Integrating your types with PointFreeHTML is like teaching your dog a new trick. Your dog doesn't change - it just learns to do something cool on command.

Your HTML and CSS types don't change either. They just learn how to render themselves through PointFreeHTML when you need them to.

Start with one small integration today. You'll be amazed how quickly your entire HTML library can gain rendering superpowers. And the best part? Your existing code keeps working exactly as it always has.

Happy integrating! 🔌
