//
//  HTML.View.swift
//  pointfree-html
//
//  Created by Point-Free, Inc
//

import OrderedCollections
public import Rendering
import Standards

/// A protocol representing an HTML element or component that can be rendered.
///
/// The `HTML.View` protocol is the core abstraction of the RenderingHTML library,
/// allowing Swift types to represent HTML content in a declarative, composable manner.
/// It uses a component-based architecture similar to SwiftUI, where each component
/// defines its `body` property to build up a hierarchy of HTML elements.
///
/// This protocol is available as `HTML.View` for a more SwiftUI-like API.
///
/// Example:
/// ```swift
/// struct MyView: HTML.View {
///     var body: some HTML.View {
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
extension HTML {
    public protocol View: Rendering where Content: HTML.View, Context == HTML.Context {
        @HTML.Builder var body: Content { get }
    }
}

extension HTML.View {
    @inlinable
    @_disfavoredOverload
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        Content._render(html.body, into: &buffer, context: &context)
    }
}


// MARK: - UInt8.Streaming Compatible

// Note: HTML.View provides the same `serialize(into:)` method signature as `UInt8.Streaming`
// from swift-standards, enabling interoperability. Concrete HTML types that are Sendable
// can add `UInt8.Streaming` conformance if needed for composition with other streaming types.

extension HTML.View {
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
        var context = HTML.Context()
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

// Streaming extensions for HTML.View are defined in:
// - AsyncStream.swift (asyncStream)
// - AsyncThrowingStream.swift (asyncThrowingStream)

/// Extension to add attribute capabilities to all HTML elements.
extension HTML.View {
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
    public func attribute(_ name: String, _ value: String? = "") -> HTML._Attributes<Self> {
        HTML._Attributes(content: self, attributes: value.map { [name: $0] } ?? [:])
    }
}

extension HTML.View {
    @inlinable
    func render<Buffer: RangeReplaceableCollection>(
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        Self._render(self, into: &buffer, context: &context)
    }
}

extension HTML.View {
    /// Asynchronously render this HTML to a String.
    ///
    /// Convenience method that delegates to `String.init(_:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML string.
    @inlinable
    public func asyncString(
        configuration: HTML.Context.Configuration? = nil
    ) async -> String {
        await String(self, configuration: configuration)
    }
}

extension HTML.View {
    /// Asynchronously render this HTML to a complete byte array.
    ///
    /// Convenience method that delegates to `[UInt8].init(_:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncBytes(
        configuration: HTML.Context.Configuration? = nil
    ) async -> [UInt8] {
        await [UInt8].init(self, configuration: configuration)
    }
}

/// Provides a default `description` implementation for HTML types that also conform to `CustomStringConvertible`.
///
/// This allows any HTML element to be printed or interpolated into strings,
/// automatically rendering its HTML representation.
///
/// ## Example
///
/// ```swift
/// struct Greeting: HTML.View, CustomStringConvertible {
///     var body: some HTML.View {
///         tag("div") { HTML.Text("Hello!") }
///     }
/// }
///
/// let greeting = Greeting()
/// print(greeting) // Prints: <div>Hello!</div>
/// ```
extension CustomStringConvertible where Self: HTML.View {
    public var description: String {
        String(decoding: self.bytes, as: UTF8.self)
    }
}
