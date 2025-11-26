//
//  HTML.StreamingMode.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension HTML {
    /// Controls how HTML content is streamed to clients.
    ///
    /// ## Buffered Mode
    /// Renders the entire HTML into memory first, then streams chunks from that buffer.
    /// - Pros: Simple, predictable, works with any `HTML.View`
    /// - Cons: Higher Time To First Byte (TTFB), O(doc size) memory during render
    /// - Memory: O(doc size) during render → O(chunkSize) during stream
    /// - Best for: Small to medium documents, simple use cases
    ///
    /// ## Streaming Mode
    /// True progressive streaming with backpressure via `AsyncChannel`.
    /// - Pros: Bounded memory throughout, true backpressure, low TTFB
    /// - Cons: Requires `AsyncRendering` conformance
    /// - Memory: O(chunkSize) throughout entire process
    /// - Best for: Large documents, memory-constrained environments
    ///
    /// ## Academic Foundation
    ///
    /// The distinction between buffered and streaming modes reflects a fundamental
    /// computer science concept: **backpressure requires suspension points**.
    ///
    /// - Buffered mode uses synchronous CPS-style rendering (Hughes 1989)
    /// - Streaming mode uses CSP-style channels (Hoare 1978) with `async/await`
    ///
    /// You cannot achieve true backpressure in synchronous code because the producer
    /// cannot yield control to wait for the consumer. This is why `AsyncRendering`
    /// conformance is required for streaming mode.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Buffered: render all, then stream chunks
    /// for await chunk in AsyncStream(mode: .buffered) { myView } {
    ///     await response.write(chunk)
    /// }
    ///
    /// // Streaming: true progressive with backpressure
    /// for await chunk in myView.asyncChannel(chunkSize: 4096) {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// ## References
    ///
    /// - Hughes, J. (1989). "Why Functional Programming Matters" - CPS serialization
    /// - Hoare, C.A.R. (1978). "Communicating Sequential Processes" - Channel semantics
    /// - Kiselyov, O. (2012). "Iteratees" - Stream processing with backpressure
    public enum StreamingMode: Sendable, Equatable {
        /// Render entire content into memory first, then stream chunks.
        ///
        /// This mode works with any `HTML.View` and provides predictable behavior,
        /// but requires O(document size) memory during the render phase.
        case buffered

        /// True progressive streaming with backpressure.
        ///
        /// Memory is bounded to O(chunkSize) throughout the entire process.
        /// The producer suspends when the consumer is slow, preventing unbounded
        /// memory growth.
        ///
        /// - Important: Requires `AsyncRendering` conformance. Use `asyncChannel()`
        ///   for the canonical streaming API with backpressure.
        case streaming
    }
}
