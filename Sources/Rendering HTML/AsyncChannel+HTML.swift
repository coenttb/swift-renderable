//
//  AsyncChannel+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension AsyncChannel<ArraySlice<UInt8>> {
    /// Stream HTML with true progressive rendering and backpressure.
    ///
    /// This is the canonical way to stream HTML when you need bounded memory.
    /// The producer suspends when the consumer is slow, ensuring memory
    /// usage is bounded to O(chunkSize) throughout the entire process.
    ///
    /// ## When to Use
    ///
    /// Use `AsyncChannel` when:
    /// - Streaming large documents to HTTP clients
    /// - Memory usage must be bounded regardless of document size
    /// - You want true backpressure (producer waits for slow consumers)
    ///
    /// Use `[UInt8](html)` instead when:
    /// - You need the complete document (e.g., PDF generation)
    /// - The document is small
    /// - Simplicity is preferred over streaming
    ///
    /// ## Canonical Usage
    ///
    /// ```swift
    /// for await chunk in AsyncChannel { myView } {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// ## Memory Characteristics
    ///
    /// | Pattern | Memory |
    /// |---------|--------|
    /// | `[UInt8](html)` | O(doc size) |
    /// | `AsyncChannel { html }` | **O(chunkSize)** |
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - view: The HTML content to stream.
    public convenience init<View: HTML.View & AsyncRendering & Sendable>(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ view: () -> View
    ) {
        self.init()
        let view = view()
        let config = configuration ?? .current
        let channel = self

        // IMPORTANT: Task.detached is required here for concurrent producer/consumer.
        //
        // Why not `async init`?
        // - AsyncChannel.send() suspends until a consumer reads (backpressure)
        // - If we made this init async and awaited rendering inline, send() would
        //   suspend waiting for a consumer that can't start until init completes
        // - Result: DEADLOCK
        //
        // With Task.detached:
        // - init returns immediately with the channel
        // - Producer runs concurrently in background
        // - Consumer can start iterating while producer is still rendering
        // - Backpressure works: send() suspends producer when consumer is slow
        Task.detached {
            let stream = AsyncRenderingStream(channel: channel, chunkSize: chunkSize)
            var context = HTML.Context(config)
            await View._renderAsync(view, into: stream, context: &context)
            await stream.finish()
        }
    }
}

extension AsyncChannel<ArraySlice<UInt8>> {
    /// Stream an HTML document with true progressive rendering and backpressure.
    ///
    /// ## Canonical Usage
    ///
    /// ```swift
    /// let document = HTML.Document { div { "Hello" } }
    /// for await chunk in AsyncChannel { document } {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - document: The HTML document to stream.
    public convenience init<Document: HTML.DocumentProtocol & AsyncRendering & Sendable>(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ document: () -> Document
    ) {
        self.init()
        let document = document()
        let config = configuration ?? .current
        let channel = self

        // IMPORTANT: Task.detached is required here for concurrent producer/consumer.
        // See the HTML.View init above for detailed explanation.
        Task.detached {
            let stream = AsyncRenderingStream(channel: channel, chunkSize: chunkSize)
            var context = HTML.Context(config)
            await Document._renderAsync(document, into: stream, context: &context)
            await stream.finish()
        }
    }
}
