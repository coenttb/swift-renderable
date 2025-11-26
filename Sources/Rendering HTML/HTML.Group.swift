//
//  Group+HTML.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering
public typealias RenderingGroup = Group

/// A container that groups multiple HTML elements together without adding a wrapper element.
///
/// `Group` allows you to group a collection of HTML elements together
/// without introducing an additional HTML element in the rendered output.
/// This is useful for creating reusable components that contain multiple
/// elements but don't need a container element.
///
/// Example:
/// ```swift
/// func navigation() -> some HTML.View {
///     Group {
///         a().href("/home") { "Home" }
///         a().href("/about") { "About" }
///         a().href("/contact") { "Contact" }
///     }
/// }
///
/// var body: some HTML.View {
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

extension HTML {
    public typealias Group = RenderingGroup
}

extension HTML.Group: HTML.View where Content: HTML.View {}
