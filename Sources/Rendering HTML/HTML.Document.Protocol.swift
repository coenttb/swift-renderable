//
//  HTML.Document.Protocol.swift
//
//
//  Created by Point-Free, Inc
//

import OrderedCollections
import Rendering

extension HTML {
    /// A protocol representing a complete HTML document.
    ///
    /// The `HTML.Document.Protocol` extends `HTML.View` to specifically represent
    /// a complete HTML document with both head and body sections. This allows
    /// for structured creation of full HTML pages with proper doctype, head
    /// metadata, and body content.
    ///
    /// Example:
    /// ```swift
    /// struct MyDocument: HTML.Document.Protocol {
    ///     var head: some HTML.View {
    ///         title { "My Web Page" }
    ///         meta().charset("utf-8")
    ///         meta().name("viewport").content("width=device-width, initial-scale=1")
    ///     }
    ///
    ///     var body: some HTML.View {
    ///         div {
    ///             h1 { "Welcome to My Website" }
    ///             p { "This is a complete HTML document." }
    ///         }
    ///     }
    /// }
    /// ```
    public protocol DocumentProtocol: HTML.View {
        /// The type of HTML content for the document's head section.
        associatedtype Head: HTML.View

        /// The head section of the HTML document.
        ///
        /// This property defines metadata, title, stylesheets, scripts, and other
        /// elements that should appear in the document's head section.
        @HTML.Builder
        var head: Head { get }
    }
}

extension HTML.DocumentProtocol {
    /// Streaming render for HTML documents.
    ///
    /// Documents require two-phase rendering:
    /// 1. Render body to collect styles
    /// 2. Write document structure with collected styles
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        let configuration = context.configuration
        let indent = configuration.indentation

        // Phase 1: Render body to collect styles
        // Body content is 2 levels deep: html > body > content
        var bodyBuffer: [UInt8] = []
        var bodyContext = HTML.Context(configuration)
        bodyContext.currentIndentation = indent + indent
        Content._render(html.body, into: &bodyBuffer, context: &bodyContext)

        // Transfer collected styles to main context
        for (key, value) in bodyContext.styles {
            context.styles[key] = value
        }

        // Phase 2: Write document structure directly (more performant than building HTML tree)
        // Match HTML.Element's block-level rendering behavior for consistent output
        let newline = configuration.newline

        // <!doctype html>
        buffer.append(contentsOf: [UInt8].html.tag.doctype)

        // <html> (block element - newline before, indent content)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: [UInt8].html.tag.open)

        // <head> (block element inside html - newline + indent before)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: indent)
        buffer.append(contentsOf: [UInt8].html.tag.headOpen)

        // Render head content (with increased indentation)
        let oldIndentation = context.currentIndentation
        context.currentIndentation = indent + indent
        Head._render(html.head, into: &buffer, context: &context)

        // Add collected styles if any (as block element inside head)
        // Style content indentation: 3 levels deep (html > head > style content)
        let styleContentIndent = indent + indent + indent
        let stylesheetBytes = bodyContext.stylesheetBytes(baseIndentation: styleContentIndent)
        if !bodyContext.styles.isEmpty {
            // <style> tag as block element: newline + indent before
            buffer.append(contentsOf: newline)
            buffer.append(contentsOf: indent)
            buffer.append(contentsOf: indent)
            buffer.append(contentsOf: [UInt8].html.tag.styleOpen)
            // Stylesheet content (starts with newline, has proper indentation)
            buffer.append(contentsOf: stylesheetBytes)
            // </style> as block element: newline + indent before closing
            buffer.append(contentsOf: newline)
            buffer.append(contentsOf: indent)
            buffer.append(contentsOf: indent)
            buffer.append(contentsOf: [UInt8].html.tag.styleClose)
        }

        // </head> (newline + indent before closing)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: indent)
        buffer.append(contentsOf: [UInt8].html.tag.headClose)

        // <body> (block element inside html)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: indent)
        buffer.append(contentsOf: [UInt8].html.tag.bodyOpen)

        // Append pre-rendered body bytes (already has proper indentation)
        buffer.append(contentsOf: bodyBuffer)

        // </body> (newline + indent before closing)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: indent)
        buffer.append(contentsOf: [UInt8].html.tag.bodyClose)

        // </html> (newline before closing, no indent since it's root)
        buffer.append(contentsOf: newline)
        buffer.append(contentsOf: [UInt8].html.tag.close)

        // Restore indentation
        context.currentIndentation = oldIndentation
    }
}







extension HTML.DocumentProtocol {
    /// Asynchronously render this document to a complete byte array.
    ///
    /// Convenience method that delegates to `[UInt8].html.init(document:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Complete rendered bytes.
    @inlinable
    public func asyncDocumentBytes(
        configuration: HTML.Context.Configuration? = nil
    ) async -> [UInt8] {
        await [UInt8](self, configuration: configuration)
    }

    /// Asynchronously render this document to a String.
    ///
    /// Convenience method that delegates to `String.init(document:configuration:)`.
    ///
    /// - Parameter configuration: Rendering configuration.
    /// - Returns: Rendered HTML document string.
    @inlinable
    public func asyncDocumentString(
        configuration: HTML.Context.Configuration? = nil
    ) async -> String {
        await String(self, configuration: configuration)
    }
}

// Streaming extensions for HTML.DocumentProtocol are defined in:
// - AsyncStream.swift (asyncStream)
// - AsyncThrowingStream.swift (asyncThrowingStream)
