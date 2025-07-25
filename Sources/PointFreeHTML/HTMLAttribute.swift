//
//  HTMLAttribute.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections

/// Extension to add attribute capabilities to all HTML elements.
extension HTML {
    /// Adds a custom attribute to an HTML element.
    ///
    /// This method allows you to set any attribute on an HTML element,
    /// providing flexibility for both standard and custom attributes.
    ///
    /// Example:
    /// ```swift
    /// div { "Content" }
    ///     .attribute("data-testid", "main-content")
    ///     .attribute("aria-label", "Main content section")
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the attribute.
    ///   - value: The optional value of the attribute. If nil, the attribute is omitted.
    ///            If an empty string, the attribute is included without a value.
    /// - Returns: An HTML element with the attribute applied.
    ///
    /// - Note: This is the primary method for adding any HTML attribute.
    ///   Use this for all attributes including common ones like
    ///   `charset`, `name`, `content`, `type`, etc.
    ///
    /// Example:
    /// ```swift
    /// meta().attribute("charset", "utf-8")
    /// meta().attribute("name", "viewport").attribute("content", "width=device-width, initial-scale=1")
    /// input().attribute("type", "text").attribute("placeholder", "Enter your name")
    /// div().attribute("id", "main").attribute("class", "container")
    /// ```
    public func attribute(_ name: String, _ value: String? = "") -> _HTMLAttributes<Self> {
        _HTMLAttributes(content: self, attributes: value.map { [name: $0] } ?? [:])
    }
}

/// A wrapper that applies attributes to an HTML element.
///
/// `_HTMLAttributes` is used to attach HTML attributes to elements in
/// a type-safe, chainable manner. It manages the collection of attributes
/// and their rendering into the final HTML output.
///
/// You typically don't create this type directly but use the `attribute`
/// method and its convenience wrappers (like `href`, `src`, etc.) on HTML elements.
///
/// Example:
/// ```swift
/// a { "Visit our site" }
///     .href("https://example.com")
///     .attribute("target", "_blank")
/// ```
public struct _HTMLAttributes<Content: HTML>: HTML {
    /// The HTML content to which attributes are being applied.
    let content: Content

    /// The collection of attributes to apply.
    var attributes: OrderedDictionary<String, String>

    /// Adds an additional attribute to this element.
    ///
    /// This method allows for chaining multiple attributes on a single element.
    ///
    /// Example:
    /// ```swift
    /// img()
    ///     .src("image.jpg")
    ///     .attribute("loading", "lazy")
    ///     .attribute("width", "300")
    /// ```
    ///
    /// - Parameters:
    ///   - name: The name of the attribute.
    ///   - value: The optional value of the attribute.
    /// - Returns: An HTML element with both the original and new attributes applied.
    public func attribute(_ name: String, _ value: String? = "") -> _HTMLAttributes<Content> {
        var copy = self
        copy.attributes[name] = value
        return copy
    }

    /// Renders this HTML element with attributes into the provided printer.
    ///
    /// This method:
    /// 1. Saves the current attributes
    /// 2. Merges the new attributes
    /// 3. Renders the content with the merged attributes
    /// 4. Restores the original attributes
    ///
    /// - Parameters:
    ///   - html: The HTML with attributes to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        let previousValue = printer.attributes  // TODO: should we optimize this?
        defer { printer.attributes = previousValue }
        printer.attributes.merge(html.attributes, uniquingKeysWith: { $1 })
        Content._render(html.content, into: &printer)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
