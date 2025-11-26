//
//  HTML.StreamingMode.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension HTML {
    /// Controls how HTML content is streamed to clients.
    ///
    /// ## Batch Mode
    /// Renders the entire HTML into memory first, then streams chunks from that buffer.
    /// - Pros: Simple, predictable memory usage pattern
    /// - Cons: Higher Time To First Byte (TTFB) for large documents
    /// - Best for: Small to medium documents
    ///
    /// ## Progressive Mode
    /// Streams chunks as they are rendered, with minimal buffering.
    /// - Pros: Lower TTFB, content starts appearing immediately
    /// - Cons: For documents with styles, `<style>` tag is placed at end of `<body>`
    /// - Best for: Large documents, streaming APIs, real-time content
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Batch: render all, then stream
    /// for try await chunk in AsyncThrowingStream(mode: .batch) {
    ///     div { "Hello" }
    /// } {
    ///     try await response.write(chunk)
    /// }
    ///
    /// // Progressive: stream as we render
    /// for try await chunk in AsyncThrowingStream(mode: .progressive) {
    ///     div { "Hello" }
    /// } {
    ///     try await response.write(chunk)
    /// }
    /// ```
    public enum StreamingMode: Sendable {
        /// Render entire content first, then stream chunks from buffer.
        case batch

        /// Stream chunks as content renders (lower TTFB).
        case progressive
    }
}
