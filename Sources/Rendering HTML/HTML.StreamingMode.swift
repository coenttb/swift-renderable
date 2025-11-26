//
//  HTML.StreamingMode.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension HTML {
    /// Controls how HTML content is streamed to clients.
    ///
    /// ## Important: Choosing the Right API
    ///
    /// This enum is used with `AsyncStream` and `AsyncThrowingStream` initializers.
    /// However, **neither mode provides true backpressure** because `AsyncStream`
    /// has unbounded internal buffering.
    ///
    /// For true backpressure with bounded memory, use `asyncChannel()` instead.
    ///
    /// ## Mode Comparison
    ///
    /// | Mode       | Memory During Render | Backpressure | Use Case                    |
    /// |------------|---------------------|--------------|------------------------------|
    /// | `.buffered`| O(doc size)         | No           | Simple, predictable          |
    /// | `.streaming`| O(doc size)*       | No*          | Progressive chunk emission   |
    /// | `asyncChannel()` | **O(chunk)** | **Yes**      | Large docs, memory-constrained |
    ///
    /// *Note: `.streaming` mode emits chunks progressively during sync rendering,
    /// but cannot apply true backpressure because the synchronous producer cannot
    /// suspend to wait for a slow consumer.
    ///
    /// ## Buffered Mode
    /// Renders the entire HTML into memory first, then streams chunks from that buffer.
    /// - Pros: Simple, predictable, works with any `HTML.View`
    /// - Cons: Higher Time To First Byte (TTFB), O(doc size) memory during render
    /// - Memory: O(doc size) during render → O(chunkSize) during stream
    /// - Best for: Small to medium documents, simple use cases
    ///
    /// ## Streaming Mode (Progressive)
    /// Emits chunks progressively as synchronous rendering proceeds.
    /// - Pros: Lower TTFB than buffered, chunks arrive during rendering
    /// - Cons: Still O(doc size) memory, **no true backpressure**
    /// - Memory: Chunks emitted during render, but no consumer flow control
    /// - Best for: When you want progressive output but don't need backpressure
    ///
    /// ## True Streaming with Backpressure
    /// For bounded memory throughout, use `asyncChannel()`:
    /// - Requires: `AsyncRendering & Sendable` conformance
    /// - Memory: O(chunkSize) throughout entire process
    /// - The producer suspends when the consumer is slow
    ///
    /// ## Academic Foundation
    ///
    /// The distinction between modes reflects a fundamental computer science concept:
    /// **backpressure requires suspension points**.
    ///
    /// - Buffered/streaming modes use synchronous CPS-style rendering (Hughes 1989)
    /// - `asyncChannel()` uses CSP-style channels (Hoare 1978) with `async/await`
    ///
    /// You cannot achieve true backpressure in synchronous code because the producer
    /// cannot yield control to wait for the consumer.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Buffered: render all, then stream chunks (no backpressure)
    /// for await chunk in AsyncStream(mode: .buffered) { myView } {
    ///     await response.write(chunk)
    /// }
    ///
    /// // Progressive: emit chunks during render (no backpressure)
    /// for await chunk in AsyncStream(mode: .streaming) { myView } {
    ///     await response.write(chunk)
    /// }
    ///
    /// // True streaming with backpressure (requires AsyncRendering)
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
        ///
        /// Chunks are yielded after rendering completes.
        case buffered

        /// Progressive chunk emission during synchronous rendering.
        ///
        /// Chunks are emitted as rendering proceeds, providing lower TTFB than
        /// buffered mode. However, this mode **does not provide true backpressure**
        /// because `AsyncStream` cannot signal the synchronous producer to slow down.
        ///
        /// - Important: For true backpressure with bounded memory, use
        ///   `asyncChannel()` with `AsyncRendering` conformance instead.
        case streaming
    }
}
