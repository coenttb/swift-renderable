//
//  HTML.swift
//
//
//  Created by Point-Free, Inc
//

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

// MARK: - UInt8.Streaming Conformance

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

/// Conformance of `Never` to `HTML` to support the type system.
///
/// This conformance is provided to allow the use of the `HTML` protocol in
/// contexts where no content is expected or possible.
extension Never: HTML {
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {}

    @inlinable
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {}

    public var body: Never { fatalError() }
}

public struct AnyHTML: HTML {
    let base: any HTML
    public init(_ base: any HTML) {
        self.base = base
    }
    public static func _render(_ html: AnyHTML, into printer: inout HTMLPrinter) {
        func render<T: HTML>(_ html: T) {
            T._render(html, into: &printer)
        }
        render(html.base)
    }

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: AnyHTML,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        func render<T: HTML>(_ html: T) {
            T._render(html, into: &buffer, context: &context)
        }
        render(html.base)
    }

    public var body: Never { fatalError() }
}

extension AnyHTML {
    public init(
        _ closure: () -> any HTML
    ) {
        self = .init(closure())
    }
}

// MARK: - Async Streaming

extension HTML where Self: Sendable {
    /// Stream this HTML as async byte chunks.
    ///
    /// This method enables HTML to be streamed chunk-by-chunk to HTTP responses,
    /// providing cooperative scheduling and backpressure support through Swift's
    /// structured concurrency.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let page = div {
    ///     h1 { "Hello" }
    ///     p { "Streaming HTML!" }
    /// }
    ///
    /// // Stream to HTTP response
    /// for try await chunk in page.asyncStream() {
    ///     try await response.write(chunk)
    /// }
    /// ```
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
        let html = self
        let config = configuration ?? .default
        return AsyncThrowingStream { continuation in
            Task { @Sendable in
                do {
                    // Render synchronously into buffer
                    var buffer: [UInt8] = []
                    var context = HTMLContext(config)
                    Self._render(html, into: &buffer, context: &context)

                    // Yield in chunks with cooperative scheduling
                    var offset = 0
                    while offset < buffer.count {
                        // Cooperative scheduling - allow other tasks to run
                        await Task.yield()

                        // Check for cancellation
                        try Task.checkCancellation()

                        let end = min(offset + chunkSize, buffer.count)
                        continuation.yield(buffer[offset..<end])
                        offset = end
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    /// Stream this HTML as async byte chunks (non-throwing variant).
    ///
    /// This variant ignores cancellation errors and simply finishes the stream.
    /// Use `asyncStream()` if you need to handle cancellation explicitly.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncStream yielding byte chunks.
    @inlinable
    public func asyncStreamNonThrowing(
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncStream<ArraySlice<UInt8>> {
        let html = self
        let config = configuration ?? .default
        return AsyncStream { continuation in
            Task { @Sendable in
                // Render synchronously into buffer
                var buffer: [UInt8] = []
                var context = HTMLContext(config)
                Self._render(html, into: &buffer, context: &context)

                // Yield in chunks with cooperative scheduling
                var offset = 0
                while offset < buffer.count {
                    await Task.yield()

                    // Check for cancellation (finish gracefully)
                    if Task.isCancelled {
                        continuation.finish()
                        return
                    }

                    let end = min(offset + chunkSize, buffer.count)
                    continuation.yield(buffer[offset..<end])
                    offset = end
                }
                continuation.finish()
            }
        }
    }
}

extension HTML {
    /// Asynchronously render this HTML to a complete byte array.
    ///
    /// This method yields to the scheduler during rendering to avoid blocking,
    /// making it suitable for use in async contexts where responsiveness matters.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncBytes(
        configuration: HTMLPrinter.Configuration? = nil
    ) async -> [UInt8] {
        // Yield to allow other tasks to run
        await Task.yield()

        var buffer: [UInt8] = []
        var context = HTMLContext(configuration ?? .default)
        Self._render(self, into: &buffer, context: &context)
        return buffer
    }

    /// Asynchronously render this HTML to a String.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML string.
    @inlinable
    public func asyncString(
        configuration: HTMLPrinter.Configuration? = nil
    ) async -> String {
        let bytes = await asyncBytes(configuration: configuration)
        return String(decoding: bytes, as: UTF8.self)
    }
}
