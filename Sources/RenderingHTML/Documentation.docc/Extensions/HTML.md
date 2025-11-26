# ``PointFreeHTML/HTML``

The core protocol for creating HTML content with a declarative syntax.

## Overview

The `HTML` protocol is the foundation of PointFreeHTML, enabling you to create HTML content using Swift types. Similar to SwiftUI's `View` protocol, `HTML` provides a declarative, composable approach to building web content.

Every type conforming to `HTML` must implement a `body` property that defines the structure and content of the HTML element or component.

## Creating HTML Components

### Basic Implementation

```swift
struct WelcomeMessage: HTML.View {
    let name: String
    
    var body: some HTML.View {
        div {
            h1 { "Welcome, \(name)!" }
            p { "Thanks for using PointFreeHTML." }
        }
    }
}

// Usage
let welcome = WelcomeMessage(name: "Alice")
let htmlString = try String(welcome)
```

### Stateless Components

For simple, stateless HTML, you can create functions that return HTML:

```swift
func alertBanner(message: String, type: AlertType = .info) -> some HTML.View {
    div {
        message
    }
    .class("alert alert-\(type.rawValue)")
}
```

## Key Features

### Declarative Syntax
Build HTML hierarchies using a natural, nested syntax similar to SwiftUI.

### Type Safety
Leverage Swift's type system to catch errors at compile time rather than runtime.

### Composability
Combine simple components into complex layouts through composition.

### Performance
Efficient rendering with minimal memory allocation and fast string generation.

## Advanced Usage

### Conditional Content

```swift
struct UserProfile: HTML.View {
    let user: User
    let isEditable: Bool
    
    var body: some HTML.View {
        div {
            h2 { user.name }
            p { user.email }
            
            if isEditable {
                button { "Edit Profile" }
                    .onclick("editProfile()")
            }
        }
    }
}
```

### Dynamic Content with Loops

```swift
struct NavigationMenu: HTML.View {
    let items: [MenuItem]
    
    var body: some HTML.View {
        nav {
            ul {
                for item in items {
                    li {
                        a { item.title }
                            .href(item.url)
                    }
                }
            }
        }
    }
}
```

## Type Erasure

Use `AnyHTML` when you need to render stored HTML values of different concrete types:

```swift
let components: [any HTML] = [
    WelcomeMessage(name: "Alice"),
    alertBanner(message: "System update available", type: .warning)
]

for component in components {
    AnyHTML(component)
}
```

## Topics

### Essential Protocol Requirements

- ``body``

### Rendering System

- ``_render(_:into:)``

### Type Erasure

- ``AnyHTML``

### System Extensions

- ``Never``
