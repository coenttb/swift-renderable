//
//  HTMLGroup.swift
//
//
//  Created by Point-Free, Inc
//

/// A container that groups multiple HTML elements together without adding a wrapper element.
///
/// `HTMLGroup` allows you to group a collection of HTML elements together
/// without introducing an additional HTML element in the rendered output.
/// This is useful for creating reusable components that contain multiple
/// elements but don't need a container element.
///
/// Example:
/// ```swift
/// func navigation() -> some HTML {
///     HTMLGroup {
///         a().href("/home") { "Home" }
///         a().href("/about") { "About" }
///         a().href("/contact") { "Contact" }
///     }
/// }
///
/// var body: some HTML {
///     nav {
///         navigation()
///     }
/// }
/// ```
///
/// This would render as:
/// ```html
/// <nav>
///     <a href="/home">Home</a>
///     <a href="/about">About</a>
///     <a href="/contact">Contact</a>
/// </nav>
/// ```
///
/// - Note: This is similar to React's Fragment concept or SwiftUI's Group.
public struct HTMLGroup<Content: HTML>: HTML {
    /// The grouped HTML content.
    let content: Content

    /// Creates a new group with the given HTML content.
    ///
    /// - Parameter content: A closure that returns the HTML content to group.
    public init(@HTMLBuilder content: () -> Content) {
        self.content = content()
    }

    /// The body of this group, which is the grouped content.
    public var body: some HTML {
        content
    }
}

extension HTMLGroup: Sendable where Content: Sendable {}
