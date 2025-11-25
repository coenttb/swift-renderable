//
//  HTMLTag.swift
//
//
//  Created by Point-Free, Inc
//

/// Represents a standard HTML tag that can contain other HTML elements.
///
/// `HTMLTag` provides a convenient way to create HTML elements with a function-call
/// syntax. It supports both empty elements and elements with content.
///
/// Example:
/// ```swift
/// // Empty div
/// let emptyDiv = div()
///
/// // Div with content
/// let contentDiv = div {
///     h1 { "Title" }
///     p { "Paragraph" }
/// }
/// ```
///
/// This struct is primarily used through the predefined tag variables like `div`, `span`,
/// `h1`, etc., but can also be used directly with custom tag names.
public struct HTMLTag: ExpressibleByStringLiteral {
    /// The name of the HTML tag.
    public let rawValue: String

    /// Creates a new HTML tag with the specified name.
    ///
    /// - Parameter rawValue: The name of the HTML tag.
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a new HTML tag from a string literal.
    ///
    /// - Parameter value: The string literal representing the tag name.
    public init(stringLiteral value: String) {
        self.init(value)
    }

    /// Creates an empty HTML element with this tag.
    ///
    /// This allows using tags as functions, e.g. `div()`.
    ///
    /// - Returns: An empty HTML element with this tag.
    public func callAsFunction() -> HTMLElement<HTMLEmpty> {
        tag(self.rawValue)
    }

    /// Creates an HTML element with this tag and the provided content.
    ///
    /// This allows using tags as functions with closures, e.g. `div { ... }`.
    ///
    /// - Parameter content: A closure that returns the content for this element.
    /// - Returns: An HTML element with this tag and the provided content.
    public func callAsFunction<T: HTML>(@HTMLBuilder _ content: () -> T) -> HTMLElement<T> {
        tag(self.rawValue, content)
    }
}

/// Creates an HTML element with the specified tag and content.
///
/// This function is the core builder for HTML elements, allowing you to create
/// elements with any tag name and content. It's generally used through the predefined
/// tag variables like `div`, `span`, etc., but can be used directly for custom tags.
///
/// Example:
/// ```swift
/// // Standard tag
/// let div = tag("div") {
///     p { "Content" }
/// }
///
/// // Custom tag
/// let customElement = tag("custom-element") {
///     "Custom content"
/// }
/// ```
///
/// - Parameters:
///   - tag: The name of the HTML tag.
///   - content: A closure that returns the content for this element.
/// - Returns: An HTML element with the specified tag and content.
public func tag<T: HTML>(
    _ tag: String,
    @HTMLBuilder _ content: () -> T = { HTMLEmpty() }
) -> HTMLElement<T> {
    HTMLElement(tag: tag, content: content)
}
