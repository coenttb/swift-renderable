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

// MARK: - Async Rendering

extension HTML {
    /// A protocol for HTML views that support async rendering with backpressure.
    ///
    /// Async rendering allows suspension at element boundaries, enabling true
    /// progressive streaming where memory is bounded to O(chunkSize).
    ///
    /// ## Rendering Options
    ///
    /// There are two canonical ways to render HTML:
    ///
    /// | Pattern | Memory | Use Case |
    /// |---------|--------|----------|
    /// | `[UInt8](html)` | O(doc) | Complete bytes (PDF, simple responses) |
    /// | `AsyncChannel { html }` | **O(chunk)** | Streaming with backpressure (HTTP) |
    ///
    /// ## Example Usage
    ///
    /// ```swift
    /// // Sync - complete bytes
    /// let bytes = [UInt8](myView)
    ///
    /// // Streaming with backpressure
    /// for await chunk in AsyncChannel { myView } {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// Choose sync when you need the complete document (e.g., PDF generation).
    /// Choose AsyncChannel when streaming to a client that benefits from
    /// progressive delivery and you want bounded memory usage.
    public protocol AsyncView: HTML.View, AsyncRendering where Content: AsyncRendering {}
}

extension HTML.AsyncView {
    /// Default implementation delegates to content's async render method.
    @inlinable
    @_disfavoredOverload
    public static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
        _ html: Self,
        into stream: Stream,
        context: inout HTML.Context
    ) async {
        await Content._renderAsync(html.body, into: stream, context: &context)
    }
}


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
        do {
            return try String(self)
        } catch {
            return ""
        }
    }
}
