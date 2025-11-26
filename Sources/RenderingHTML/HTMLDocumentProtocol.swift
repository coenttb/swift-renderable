//
//  HTMLDocument.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections
import Rendering

/// A protocol representing a complete HTML document.
///
/// The `HTMLDocument` protocol extends `HTML` to specifically represent
/// a complete HTML document with both head and body sections. This allows
/// for structured creation of full HTML pages with proper doctype, head
/// metadata, and body content.
///
/// Example:
/// ```swift
/// struct MyDocument: HTMLDocument {
///     var head: some HTML {
///         title { "My Web Page" }
///         meta().charset("utf-8")
///         meta().name("viewport").content("width=device-width, initial-scale=1")
///     }
///
///     var body: some HTML {
///         div {
///             h1 { "Welcome to My Website" }
///             p { "This is a complete HTML document." }
///         }
///     }
/// }
/// ```
public protocol HTMLDocumentProtocol: HTML {
    /// The type of HTML content for the document's head section.
    associatedtype Head: HTML

    /// The head section of the HTML document.
    ///
    /// This property defines metadata, title, stylesheets, scripts, and other
    /// elements that should appear in the document's head section.
    @Builder
    var head: Head { get }
}

extension HTMLDocumentProtocol {
    /// Streaming render for HTML documents.
    ///
    /// Documents require two-phase rendering:
    /// 1. Render body to collect styles
    /// 2. Stream document with collected styles
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        // Phase 1: Render body to collect styles
        var bodyBuffer: [UInt8] = []
        var bodyContext = HTMLContext(context.rendering)
        Content._render(html.body, into: &bodyBuffer, context: &bodyContext)

        // Transfer collected styles to main context
        for (key, value) in bodyContext.styles {
            context.styles[key] = value
        }

        // Phase 2: Render document structure
        let doc = Document(
            head: html.head,
            stylesheetBytes: bodyContext.stylesheetBytes,
            bodyBytes: ContiguousArray(bodyBuffer)
        )
        Document._render(doc, into: &buffer, context: &context)
    }
}

extension HTMLDocumentProtocol where Self: Sendable {
    /// Stream this HTML document as async byte chunks (throwing).
    ///
    /// Convenience method that delegates to `AsyncThrowingStream.init(document:chunkSize:configuration:)`.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncDocumentStream(
        chunkSize: Int = 4096,
        configuration: HTMLContext.Rendering? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(document: self, chunkSize: chunkSize, configuration: configuration)
    }

    /// Stream this HTML document as async byte chunks (non-throwing).
    ///
    /// Convenience method that delegates to `AsyncStream.init(document:chunkSize:configuration:)`.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncStream yielding byte chunks.
    @inlinable
    public func asyncDocumentStreamNonThrowing(
        chunkSize: Int = 4096,
        configuration: HTMLContext.Rendering? = nil
    ) -> AsyncStream<ArraySlice<UInt8>> {
        AsyncStream(document: self, chunkSize: chunkSize, configuration: configuration)
    }
}

extension HTMLDocumentProtocol {
    /// Asynchronously render this document to a complete byte array.
    ///
    /// Convenience method that delegates to `[UInt8].init(document:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncDocumentBytes(
        configuration: HTMLContext.Rendering? = nil
    ) async -> [UInt8] {
        await [UInt8](document: self, configuration: configuration)
    }

    /// Asynchronously render this document to a String.
    ///
    /// Convenience method that delegates to `String.init(document:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML document string.
    @inlinable
    public func asyncDocumentString(
        configuration: HTMLContext.Rendering? = nil
    ) async -> String {
        await String(document: self, configuration: configuration)
    }
}



extension HTMLDocumentProtocol {
    /// Renders this HTML document to bytes.
    ///
    /// This method creates a printer with the current configuration and
    /// renders the HTML document into it, then returns the resulting bytes.
    ///
    /// - Returns: A buffer of bytes representing the rendered HTML document.
    ///
    /// - Warning: This method is deprecated. Use the RFC pattern initialization instead:
    ///   ```swift
    ///   // Old (deprecated)
    ///   let bytes = document.render()
    ///
    ///   // New (RFC pattern - zero-copy)
    ///   let bytes = ContiguousArray(document)
    ///
    ///   // Or for String output
    ///   let string = try String(document)
    ///   ```
    @available(*, deprecated, message: "Use ContiguousArray(html) or String(html) instead. The RFC pattern makes bytes canonical and String derived.")
    public func render() -> ContiguousArray<UInt8> {
        var buffer: ContiguousArray<UInt8> = []
        var context = HTMLContext(HTMLContext.Rendering.current)
        Self._render(self, into: &buffer, context: &context)
        return buffer
    }
}
