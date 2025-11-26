# Higher-Order Components

Create components that wrap and enhance other components:

```swift
struct WithLoading<Content: HTML>: HTML {
    let isLoading: Bool
    let content: Content
    
    init(isLoading: Bool, @Builder content: () -> Content) {
        self.isLoading = isLoading
        self.content = content()
    }
    
    var body: some HTML {
        div {
            if isLoading {
                div {
                    span { "Loading..." }
                }
                .class("loading-spinner")
            } else {
                content
            }
        }
        .class("loading-container")
    }
}

// Usage
WithLoading(isLoading: dataIsLoading) {
    UserProfile(user: currentUser)
}
```

These advanced patterns enable building sophisticated, maintainable HTML applications while leveraging PointFreeHTML's performance and type safety benefits. The key is to start simple and gradually introduce these patterns as your application's complexity grows.
