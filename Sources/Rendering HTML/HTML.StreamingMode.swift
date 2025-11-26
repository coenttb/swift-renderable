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
    /// - Memory: O(doc size) during render, O(chunkSize) during stream
    /// - Best for: Small to medium documents
    ///
    /// ## Progressive Mode
    /// Streams chunks as they are rendered, with minimal buffering.
    /// - Pros: Lower TTFB, content starts appearing immediately
    /// - Cons: For documents with styles, `<style>` tag is placed at end of `<body>`
    /// - Memory: O(doc size) during render, O(chunkSize) during stream
    /// - Best for: Large documents, streaming APIs, real-time content
    ///
    /// ## Backpressure Mode
    /// True progressive streaming with bounded memory via `AsyncChannel`.
    /// - Pros: Bounded memory throughout entire process, true backpressure
    /// - Cons: Requires `AsyncRendering` conformance
    /// - Memory: O(chunkSize) during render, O(chunkSize) during stream
    /// - Best for: Very large documents, memory-constrained environments
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
    ///
    /// // Backpressure: bounded memory throughout
    /// for await chunk in html.progressiveStream(chunkSize: 4096) {
    ///     await response.write(chunk)
    /// }
    /// ```
    public enum StreamingMode: Sendable {
        /// Render entire content first, then stream chunks from buffer.
        case batch

        /// Stream chunks as content renders (lower TTFB).
        case progressive

        /// True progressive streaming with backpressure.
        ///
        /// Memory is bounded to O(chunkSize) throughout the entire process.
        /// Uses `AsyncChannel` to apply backpressure when the consumer is slow.
        ///
        /// - Note: Use via `progressiveStream(_:chunkSize:configuration:)` or
        ///   the `.progressiveStream()` extension method on `HTML.View`.
        case backpressure
    }
}
