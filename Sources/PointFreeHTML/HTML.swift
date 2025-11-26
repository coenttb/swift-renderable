//
//  HTML.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections
import Standards

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

    /// The canonical render method - writes directly to any byte buffer.
    ///
    /// This is the single, canonical rendering method. The buffer can be
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
    /// Default implementation that delegates to the body's render method.
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
    ///   - rendering: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncStream(
        chunkSize: Int = 4096,
        rendering: HTMLContext.Rendering? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(self, chunkSize: chunkSize, configuration: rendering)
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
    @inlinable
    func render<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        Self._render(self, into: &buffer, context: &context)
    }
}
