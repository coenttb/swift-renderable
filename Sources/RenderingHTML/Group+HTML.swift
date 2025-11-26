//
//  Group.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

/// A container that groups multiple HTML elements together without adding a wrapper element.
///
/// `Group` allows you to group a collection of HTML elements together
/// without introducing an additional HTML element in the rendered output.
/// This is useful for creating reusable components that contain multiple
/// elements but don't need a container element.
///
/// Example:
/// ```swift
/// func navigation() -> some HTML {
///     Group {
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

extension Group: HTML where Content: HTML {}
