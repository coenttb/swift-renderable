//
//  HTMLDocument.swift
//
//
//  Created by Point-Free, Inc
//

import Dependencies
import OrderedCollections

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
    @HTMLBuilder
    var head: Head { get }
}

extension HTMLDocumentProtocol {
    /// Renders the HTML document into the provided printer.
    ///
    /// This method orchestrates the rendering of a complete HTML document:
    /// 1. First renders the body content into a separate printer
    /// 2. Extracts any collected stylesheets from the body rendering
    /// 3. Creates a complete document with doctype, html, head, and body elements
    /// 4. Renders the complete document into the provided printer
    ///
    /// - Parameters:
    ///   - html: The HTML document to render.
    ///   - printer: The printer to render the HTML into.
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {
        @Dependency(\.htmlPrinter) var htmlPrinter
        var bodyPrinter = htmlPrinter
        Content._render(html.body, into: &bodyPrinter)
        Document
            ._render(
                Document(
                    head: html.head,
                    stylesheet: bodyPrinter.stylesheet,
                    bodyBytes: bodyPrinter.bytes
                ),
                into: &printer
            )
    }

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
        var bodyContext = HTMLContext(context.configuration)
        Content._render(html.body, into: &bodyBuffer, context: &bodyContext)

        // Transfer collected styles to main context
        for (key, value) in bodyContext.styles {
            context.styles[key] = value
        }

        // Phase 2: Render document structure
        let doc = Document(
            head: html.head,
            stylesheet: bodyContext.stylesheet,
            bodyBytes: ContiguousArray(bodyBuffer)
        )
        Document._render(doc, into: &buffer, context: &context)
    }
}

// MARK: - Async Streaming for Documents

extension HTMLDocumentProtocol where Self: Sendable {
    /// Stream this HTML document as async byte chunks.
    ///
    /// Documents require two-phase rendering (body first to collect styles),
    /// so the entire document is rendered before streaming begins. However,
    /// the chunked delivery still provides benefits for HTTP responses:
    /// - Cooperative scheduling via `Task.yield()`
    /// - Cancellation support
    /// - Backpressure through Swift concurrency
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyPage: HTMLDocumentProtocol {
    ///     var head: some HTML { title { "My Page" } }
    ///     var body: some HTML { div { "Content" } }
    /// }
    ///
    /// let page = MyPage()
    /// for try await chunk in page.asyncDocumentStream() {
    ///     try await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncDocumentStream(
        chunkSize: Int = 4096,
        configuration: HTMLPrinter.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        let document = self
        let config = configuration ?? .default
        return AsyncThrowingStream { continuation in
            Task { @Sendable in
                do {
                    // Two-phase render: body first to collect styles
                    var buffer: [UInt8] = []
                    var context = HTMLContext(config)
                    Self._render(document, into: &buffer, context: &context)

                    // Stream in chunks with cooperative scheduling
                    var offset = 0
                    while offset < buffer.count {
                        await Task.yield()
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
}

extension HTMLDocumentProtocol {
    /// Asynchronously render this document to a complete byte array.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncDocumentBytes(
        configuration: HTMLPrinter.Configuration? = nil
    ) async -> [UInt8] {
        await Task.yield()

        var buffer: [UInt8] = []
        var context = HTMLContext(configuration ?? .default)
        Self._render(self, into: &buffer, context: &context)
        return buffer
    }

    /// Asynchronously render this document to a String.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML document string.
    @inlinable
    public func asyncDocumentString(
        configuration: HTMLPrinter.Configuration? = nil
    ) async -> String {
        let bytes = await asyncDocumentBytes(configuration: configuration)
        return String(decoding: bytes, as: UTF8.self)
    }
}

/// A private implementation of an HTML document.
///
/// This struct assembles the different parts of an HTML document (head, stylesheet, body)
/// into a complete HTML document with proper structure.
private struct Document<Head: HTML>: HTML {
    /// The head content for the document.
    let head: Head

    /// Collected stylesheet content to be included in the document head.
    let stylesheet: String

    /// Pre-rendered bytes for the document body.
    let bodyBytes: ContiguousArray<UInt8>

    /// The body content of the document, which assembles the complete HTML structure.
    var body: some HTML {
        // Add the doctype declaration
        Doctype()

        // Create the html element with language attribute
        HTMLTag("html") {
            // Add the head section with metadata and styles
            HTMLTag("head") {
                head
                HTMLTag("style") {
                    HTMLText(stylesheet)
                }
            }

            // Add the body section with pre-rendered content
            HTMLTag("body") {
                HTMLRaw(bodyBytes)
            }
        }
    }
}
