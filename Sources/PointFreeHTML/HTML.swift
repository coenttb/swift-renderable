//
//  HTML.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections
import Standards
import Dependencies

/// A protocol representing an HTML element or component that can be rendered.
///
/// The `HTML` protocol is the core abstraction of the PointFreeHTML library,
/// allowing Swift types to represent HTML content in a declarative, composable manner.
/// It uses a component-based architecture similar to SwiftUI, where each component
/// defines its `body` property to build up a hierarchy of HTML elements.
///
/// Example:
/// ```swift
/// struct MyView: HTML {
///     var body: some HTML {
///         div {
///             h1 { "Hello, World!" }
///             p { "This is a paragraph." }
///         }
///     }
/// }
/// ```
///
/// - Note: This protocol is similar in design to SwiftUI's `View` protocol,
///   making it familiar to Swift developers who have worked with SwiftUI.
public protocol HTML {
    /// The type of HTML content that this HTML element or component contains.
    associatedtype Content: HTML

    /// The body of this HTML element or component, defining its structure and content.
    ///
    /// This property uses the `HTMLBuilder` result builder to allow for a declarative
    /// syntax when defining HTML content, similar to how SwiftUI's ViewBuilder works.
    @HTMLBuilder
    var body: Content { get }

    /// Renders this HTML element or component into the provided printer.
    ///
    /// This method is typically not called directly by users of the library,
    /// but is used internally to convert the HTML tree into rendered output.
    ///
    /// - Parameters:
    ///   - html: The HTML element or component to render.
    ///   - printer: The printer to render the HTML into.
    static func _render(_ html: Self, into printer: inout HTMLPrinter)

    /// Streaming render method - writes directly to any byte buffer.
    ///
    /// This is the generic, streaming-capable rendering method. The buffer can be
    /// any `RangeReplaceableCollection` of `UInt8`, enabling zero-copy streaming
    /// to various destinations.
    ///
    /// - Parameters:
    ///   - html: The HTML element to render.
    ///   - buffer: The buffer to write bytes into.
    ///   - context: The rendering context (attributes, styles, configuration).
    static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8
}

extension HTML {
    /// Default implementation of the render method that delegates to the body's render method.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        Content._render(html.body, into: &printer)
    }

    /// Streaming render method - writes directly to any byte buffer.
    ///
    /// This is the generic, streaming-capable rendering method. The buffer can be
    /// any `RangeReplaceableCollection` of `UInt8`, enabling zero-copy streaming
    /// to various destinations.
    ///
    /// - Parameters:
    ///   - html: The HTML element to render.
    ///   - buffer: The buffer to write bytes into.
    ///   - context: The rendering context (attributes, styles, configuration).
    @inlinable
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        Content._render(html.body, into: &buffer, context: &context)
    }
}

// MARK: - UInt8.Streaming Compatible

// Note: HTML provides the same `serialize(into:)` method signature as `UInt8.Streaming`
// from swift-standards, enabling interoperability. Concrete HTML types that are Sendable
// can add `UInt8.Streaming` conformance if needed for composition with other streaming types.

extension HTML {
    /// Serialize this HTML to bytes using the streaming protocol.
    ///
    /// This method enables HTML to be used with any `UInt8.Streaming` consumer,
    /// allowing composition with RFC types and other streaming content.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let html = div { p { "Hello" } }
    ///
    /// // Direct buffer writing
    /// var buffer: [UInt8] = []
    /// html.serialize(into: &buffer)
    ///
    /// // Or get bytes directly
    /// let bytes = html.bytes
    /// ```
    @inlinable
    public func serialize<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        var context = HTMLContext()
        Self._render(self, into: &buffer, context: &context)
    }

    /// Get the serialized bytes of this HTML.
    ///
    /// Convenience property that creates a buffer and serializes into it.
    @inlinable
    public var bytes: [UInt8] {
        var buffer: [UInt8] = []
        serialize(into: &buffer)
        return buffer
    }
}


extension HTML where Self: Sendable {
    /// Stream this HTML as async byte chunks (throwing).
    ///
    /// Convenience method that delegates to `AsyncThrowingStream.init(_:chunkSize:configuration:)`.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncStream(
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(self, chunkSize: chunkSize, configuration: configuration)
    }
}

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


extension HTML {
    func render(into printer: inout HTMLPrinter) {
        Self._render(self, into: &printer)
    }

    @inlinable
    func render<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        Self._render(self, into: &buffer, context: &context)
    }
}

extension HTML {
    /// Renders this HTML element to bytes.
    ///
    /// This method creates a printer with the current configuration and
    /// renders the HTML element into it, then returns the resulting bytes.
    ///
    /// - Returns: A buffer of bytes representing the rendered HTML.
    ///
    /// - Warning: This method is deprecated. Use the RFC pattern initialization instead:
    ///   ```swift
    ///   // Old (deprecated)
    ///   let bytes = html.render()
    ///
    ///   // New (RFC pattern - zero-copy)
    ///   let bytes = ContiguousArray(html)
    ///
    ///   // Or for String output
    ///   let string = try String(html)
    ///   ```
    @available(*, deprecated, message: "Use ContiguousArray(html) or String(html) instead. The RFC pattern makes bytes canonical and String derived.")
    public func render() -> ContiguousArray<UInt8> {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var printer = htmlPrinter
        Self._render(self, into: &printer)
        return printer.bytes
    }
}
