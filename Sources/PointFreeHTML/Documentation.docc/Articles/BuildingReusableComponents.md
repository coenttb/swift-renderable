# Building Reusable HTML Components with PointFreeHTML

Create modular, composable UI components that enhance code organization and reusability.

## Overview

One of the greatest advantages of PointFreeHTML is the ability to create reusable components that encapsulate both structure and behavior. This article explores patterns and practices for building a component-based architecture in your Swift HTML applications.

## What Makes a Good Component?

Before diving into implementation details, let's consider what makes a component "good":

- **Single responsibility**: A component should do one thing and do it well
- **Encapsulated styling**: Styling should be self-contained or easily customizable
- **Flexible but focused**: Accept configuration options without trying to handle every edge case
- **Composable**: Work well with other components
- **Well-documented**: Include clear documentation about purpose and usage

## Basic Component Structure

Any type conforming to the HTML protocol is valid HTML. That means you can create HTML using a function, a struct, and an enum, or a composition of any of them. You could even use a class or actor, but I'll leave that for you to explore.

The simplest approach is to create functions that return HTML content:

```swift
func primaryButton(title: String, action: String) -> some HTML {
    button {
        title
    }
    .attribute("onclick", action)
    .inlineStyle("background-color", "#4CAF50")
    .inlineStyle("color", "white")
    .inlineStyle("padding", "10px 15px")
}
```

This can be used anywhere in your HTML:

```swift
var body: some HTML {
    div {
        h1 { "Welcome to My App" }
        primaryButton(title: "Sign Up", action: "signup()")
    }
}
```

## Creating Configurable Components

For more flexibility, you can accept style overrides or additional attributes:

```swift
struct ButtonStyle {
    var backgroundColor: String = "#4CAF50"
    var textColor: String = "white"
    var padding: String = "10px 15px"
    var borderRadius: String = "4px"
    
    static let primary = ButtonStyle()
    static let secondary = ButtonStyle(
        backgroundColor: "#6c757d",
        textColor: "white"
    )
    static let danger = ButtonStyle(
        backgroundColor: "#dc3545",
        textColor: "white"
    )
}

func styledButton(
    title: String,
    action: String,
    style: ButtonStyle = .primary,
    additionalAttributes: [String: String] = [:]
) -> some HTML {
    var button = button {
        title
    }
    .attribute("onclick", action)
    .inlineStyle("background-color", style.backgroundColor)
    .inlineStyle("color", style.textColor)
    .inlineStyle("padding", style.padding)
    .inlineStyle("border", "none")
    .inlineStyle("border-radius", style.borderRadius)
    .inlineStyle("cursor", "pointer")
    
    // Apply any additional attributes
    for (name, value) in additionalAttributes {
        button = button.attribute(name, value)
    }
    
    return button
}
```

## Component Types

More commonly however, you create a dedicated type that conform to the `HTML` protocol:

```swift
struct Card: HTML {
    let title: String
    let content: () -> some HTML
    
    var body: some HTML {
        div {
            div {
                h3 { title }
            }
            .inlineStyle("padding", "10px 15px")
            .inlineStyle("background-color", "#f8f9fa")
            .inlineStyle("border-bottom", "1px solid #dee2e6")
            
            div {
                content()
            }
            .inlineStyle("padding", "15px")
        }
        .inlineStyle("border", "1px solid #dee2e6")
        .inlineStyle("border-radius", "4px")
        .inlineStyle("margin-bottom", "20px")
    }
}
```

You can use it like this:

```swift
var body: some HTML {
    div {
        Card(title: "User Profile") {
            div {
                p { "Name: John Doe" }
                p { "Email: john@example.com" }
                styledButton(title: "Edit Profile", action: "editProfile()")
            }
        }
        
        Card(title: "Recent Activity") {
            ul {
                li { "Logged in at 10:35 AM" }
                li { "Updated profile picture" }
                li { "Posted a new comment" }
            }
        }
    }
}
```

## Using Result Builders for Complex Content

For components that need to compose multiple child elements, you can create your own result builders:

```swift
@resultBuilder
struct NavItemBuilder {
    static func buildBlock(_ components: NavItem...) -> [NavItem] {
        components
    }
}

struct NavItem {
    let title: String
    let url: String
    let isActive: Bool
}

struct Navigation: HTML {
    let items: [NavItem]
    
    init(@NavItemBuilder builder: () -> [NavItem]) {
        self.items = builder()
    }
    
    var body: some HTML {
        nav {
            ul {
                for item in items {
                    li {
                        a { item.title }
                            .href(item.url)
                            .inlineStyle("color", item.isActive ? "#007bff" : "#212529")
                            .inlineStyle("font-weight", item.isActive ? "bold" : "normal")
                    }
                }
            }
            .inlineStyle("display", "flex")
            .inlineStyle("list-style", "none")
            .inlineStyle("gap", "20px")
            .inlineStyle("padding", "0")
        }
        .inlineStyle("background-color", "#f8f9fa")
        .inlineStyle("padding", "10px")
    }
}
```

Usage:

```swift
var body: some HTML {
    div {
        Navigation {
            NavItem(title: "Home", url: "/", isActive: true)
            NavItem(title: "About", url: "/about", isActive: false)
            NavItem(title: "Contact", url: "/contact", isActive: false)
        }
        
        h1 { "Welcome to My Website" }
        // More content...
    }
}
```

## Best Practices

### 1. Composition over inheritance

Build complex components by combining simpler ones:

```swift
struct NewsItem: HTML {
    let title: String
    let content: String
    let date: Date
    
    var body: some HTML {
        Card(title: title) {
            div {
                p { content }
                div {
                    small {
                        dateFormatter.string(from: date)
                    }
                    .inlineStyle("color", "#6c757d")
                }
            }
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
```

### 2. Define style constants

Create a theme or design system to ensure consistency:

```swift
enum Theme {
    enum Color {
        static let primary = "#007bff"
        static let secondary = "#6c757d"
        static let success = "#28a745"
        static let danger = "#dc3545"
        static let background = "#f8f9fa"
        static let text = "#212529"
    }
    
    enum Spacing {
        static let small = "8px"
        static let medium = "16px"
        static let large = "24px"
    }
    
    enum BorderRadius {
        static let small = "4px"
        static let medium = "8px"
        static let rounded = "50%"
    }
}
```

Then use these in your components:

```swift
func alertBox(message: String, type: AlertType = .info) -> some HTML {
    let backgroundColor: String
    let textColor: String
    
    switch type {
    case .success:
        backgroundColor = Theme.Color.success
        textColor = "white"
    case .error:
        backgroundColor = Theme.Color.danger
        textColor = "white"
    case .info:
        backgroundColor = Theme.Color.primary
        textColor = "white"
    }
    
    return div {
        message
    }
    .inlineStyle("background-color", backgroundColor)
    .inlineStyle("color", textColor)
    .inlineStyle("padding", Theme.Spacing.medium)
    .inlineStyle("border-radius", Theme.BorderRadius.small)
    .inlineStyle("margin-bottom", Theme.Spacing.medium)
}

enum AlertType {
    case success
    case error
    case info
}
```

## Conclusion

Building reusable components with PointFreeHTML not only makes your code more maintainable but also leads to a more consistent user experience. By leveraging Swift's type system and the declarative HTML syntax, you can create a powerful component library that grows with your application.

The approaches outlined in this article—from simple functions to complex custom types with dedicated result builders—give you the flexibility to choose the right level of abstraction for your specific needs. As your component library grows, you'll find that new pages and features can be composed quickly from existing building blocks, accelerating your development workflow.

Remember that the best components evolve over time based on real usage. Start simple, refactor as patterns emerge, and continuously improve your component library as your application's needs change.
