import OrderedCollections

//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

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

    /// Streaming render - writes directly to any byte buffer.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        let previousValue = context.attributes
        defer { context.attributes = previousValue }
        context.attributes.merge(html.attributes, uniquingKeysWith: { $1 })
        Content._render(html.content, into: &buffer, context: &context)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
