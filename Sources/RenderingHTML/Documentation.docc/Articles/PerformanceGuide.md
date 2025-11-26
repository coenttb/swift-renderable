# Performance Guide

Make your HTML rendering fast, efficient, and memory-friendly with PointFreeHTML.

## The Big Picture

PointFreeHTML is built for speed. But knowing how it works under the hood will help you squeeze out even more performance. This guide shows you exactly how fast it can go and how to write efficient code.

## Why It's Fast

### Direct to Bytes = Less Work

Unlike other libraries that build strings piece by piece (which is slow), PointFreeHTML renders directly to bytes:

```swift
// Fast - goes straight to bytes
let content = div { "Hello, World!" }
let bytes = content.render() // Returns ContiguousArray<UInt8>

// Also fast - converts once at the end
let htmlString = try String(content)
```

Think of it like this: instead of writing a letter by hand, erasing parts, and rewriting them, you're typing it all at once on a computer. Much faster!

### Nothing Happens Until You Ask

HTML structures are "lazy" - they don't do any work until you actually need the output:

```swift
// This is instant - just creates a blueprint
let hugeList = div {
    for i in 1...10000 {
        p { "Item \(i)" }
    }
}

// The actual work happens here
let htmlString = try String(hugeList)
```

It's like having a recipe - writing down the recipe is quick, but cooking only happens when you're ready to eat.

### Smart Memory Management

The library uses specialized containers that are optimized for different scenarios:
- Arrays of elements without wasted memory
- Stack-allocated storage for small groups
- Zero-cost abstractions for if/else logic

## Real-World Performance Numbers

Here's what PointFreeHTML can actually do, measured on modern Apple Silicon:

### Rendering Speed

**Plain HTML**: Lightning fast!
- **1 million elements**: 780,000 elements per second
- **100,000 elements**: 796,000 elements per second
- **Memory usage**: About 523 bytes per element

To put this in perspective: you can generate a webpage with 100,000 items in just 0.13 seconds. That's faster than a blink!

### Styling Performance

**With CSS styles**: Still impressively quick!
- **10,000 styled elements**: 10,000+ elements per second
- **Smart deduplication**: Only 3 CSS rules for 10,000 identical styles
- **Mixed styles**: 10,000+ elements per second even with variety

The magic here? If you style 10,000 buttons the same way, PointFreeHTML is smart enough to create just one CSS rule and reuse it. That's a 3,333x efficiency gain!

### Complex Structures

**Deep and wide HTML**: No problem!
- **100 levels deep**: 109,000 levels per second
- **10,000 siblings**: 383,000 elements per second
- **5,000 user cards**: 3,100 components per second
- **1,000 form fields**: 4,700 fields per second

Whether you're nesting elements like Russian dolls or laying them out side by side, performance stays excellent.

### Pretty vs Compact Output

Want readable HTML? It barely costs anything:
- **Compact mode**: 513,000 elements per second
- **Pretty mode**: 503,000 elements per second
- **Difference**: Only 2% slower!

Feel free to use pretty printing during development - the performance cost is negligible.

## Writing Fast Code

### 1. Understand the Speed Hierarchy

From fastest to slowest:
- **Plain HTML** (baseline speed)
- **HTML with attributes** (nearly as fast)
- **Styled HTML** (about 77x slower than plain, but still 10,000+ elements/sec)

This doesn't mean avoid styles! Even at "77x slower," you're still rendering 10,000 styled elements per second. For context:
- A complex dashboard with 1,000 styled elements: 0.1 seconds
- A form with 100 styled fields: 0.02 seconds
- A product catalog with 500 styled cards: 0.05 seconds

### 2. Let Styles Work for You

The style deduplication is automatic and powerful:

```swift
// Efficient - these styles get deduplicated
struct ProductList: HTML {
    let products: [Product]
    
    var body: some HTML {
        div {
            for product in products {
                div { product.name }
                    .inlineStyle("background", "white")  // Same style
                    .inlineStyle("padding", "16px")      // gets reused!
                    .inlineStyle("border-radius", "8px")
            }
        }
    }
}
```

With 1,000 products, this creates just a few CSS rules, not 1,000!

### 3. Choose the Right Configuration

```swift
import Dependencies

// Production - smallest, fastest
withDependencies {
    $0.htmlPrinter.configuration = .compact
} {
    let html = try String(myDocument)
}

// Development - readable, only 2% slower
withDependencies {
    $0.htmlPrinter.configuration = .pretty
} {
    let html = try String(myDocument)
}
```

### 4. Break Up Large Components

Instead of one massive component, compose smaller ones:

```swift
// Better: Small, focused components
struct Dashboard: HTML {
    let data: DashboardData
    
    var body: some HTML {
        div {
            Header(data.header)
            Sidebar(data.navigation)
            MainContent(data.content)
            Footer(data.footer)
        }
    }
}

// Avoid: Everything in one giant component
struct MonolithicDashboard: HTML {
    // Hundreds of lines of HTML...
}
```

Smaller components are easier to understand, test, and reuse.

### 5. Use Conditionals

Swift's conditionals are efficient - use them:

```swift
struct UserProfile: HTML {
    let user: User?
    let showPrivate: Bool
    
    var body: some HTML {
        div {
            if let user = user {
                h1 { "Welcome, \(user.name)" }
                
                if showPrivate && user.hasAccess {
                    PrivateContent(for: user)
                }
            } else {
                LoginPrompt()
            }
        }
    }
}
```

## Memory Planning

For large documents, here's what to expect:

| Document Size | Memory Usage | Render Time |
|--------------|--------------|-------------|
| 10K elements | ~5 MB | 0.01 seconds |
| 100K elements | ~50 MB | 0.13 seconds |
| 1M elements | ~500 MB | 1.28 seconds |

Plan accordingly if you're generating massive documents!

## Common Scenarios

### Building a Data Table

For a table with 10,000 rows:
- **Plain HTML**: ~0.025 seconds
- **With styling**: ~1 second
- **Memory**: ~5 MB

### Generating Email Templates

For an email with 100 styled components:
- **Render time**: ~0.01 seconds
- **With images and links**: Still under 0.02 seconds

### Creating a Dashboard

For a dashboard with 50 widgets and 1,000 data points:
- **Component composition**: ~0.3 seconds
- **Full render with styles**: ~0.5 seconds

## Quick Tips

**Do:**
- ✅ Reuse styles (automatic deduplication makes this super efficient)
- ✅ Use `.compact` for production
- ✅ Build collections in single loops
- ✅ Compose smaller components
- ✅ Trust the conditional rendering

**Don't:**
- ❌ Create unique styles when shared ones work (but don't obsess - 10K/sec is still fast!)
- ❌ Worry about pretty printing performance (only 2% overhead)
- ❌ Assume nesting depth matters much (100 levels renders in 0.001 seconds)
- ❌ Render the same HTML multiple times

**Remember:**
- 780,000 plain elements per second is your speed limit
- 10,000 styled elements per second is still blazing fast
- Pretty printing costs almost nothing
- Memory usage is predictable: ~523 bytes per element

## The Bottom Line

PointFreeHTML is fast enough for virtually any use case:
- **Server-side rendering?** Absolutely. 
- **Static site generation?** Perfect.
- **Email templates?** Lightning quick.
- **Reports with millions of rows?** It can handle it.

The architecture gives you excellent performance by default. These optimizations help you get the absolute best performance when you need it, but for most applications, you can just write clean, idiomatic Swift and let PointFreeHTML handle the rest.

Happy rendering! 🚀
