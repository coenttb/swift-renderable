//
//  AsyncChannel+Rendering.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 10/12/2025.
//

import AsyncAlgorithms

extension AsyncChannel where Element == ArraySlice<UInt8> {
    /// Stream rendered content with true progressive rendering and backpressure.
    ///
    /// This is the canonical way to stream rendered content when you need bounded memory.
    /// The producer suspends when the consumer is slow, ensuring memory usage is bounded
    /// to O(chunkSize) throughout the entire process.
    ///
    /// ## When to Use
    ///
    /// Use `AsyncChannel` when:
    /// - Streaming large documents to HTTP clients
    /// - Memory usage must be bounded regardless of document size
    /// - You want true backpressure (producer waits for slow consumers)
    ///
    /// Use synchronous `_render` instead when:
    /// - You need the complete document (e.g., PDF generation)
    /// - The document is small
    /// - Simplicity is preferred over streaming
    ///
    /// ## Canonical Usage
    ///
    /// ```swift
    /// let channel = AsyncChannel(rendering: myRenderable, chunkSize: 4096)
    /// for await chunk in channel {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// ## Memory Characteristics
    ///
    /// | Pattern | Memory |
    /// |---------|--------|
    /// | Sync `_render` to buffer | O(doc size) |
    /// | `AsyncChannel(rendering:)` | **O(chunkSize)** |
    ///
    /// ## Why This Works
    ///
    /// `Task.detached` is required for concurrent producer/consumer:
    /// - `AsyncChannel.send()` suspends until a consumer reads (backpressure)
    /// - If we made this init async and awaited rendering inline, `send()` would
    ///   suspend waiting for a consumer that can't start until init completes
    /// - Result: DEADLOCK
    ///
    /// With `Task.detached`:
    /// - init returns immediately with the channel
    /// - Producer runs concurrently in background
    /// - Consumer can start iterating while producer is still rendering
    /// - Backpressure works: `send()` suspends producer when consumer is slow
    ///
    /// - Parameters:
    ///   - renderable: The content to render and stream.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 1024.
    public convenience init<T: Rendering.Async.`Protocol` & Sendable>(
        rendering renderable: T,
        chunkSize: Int = 1024
    ) where T.Context == Void {
        self.init()
        let channel = self
        Task.detached {
            let sink = Rendering.Async.Sink.Buffered(channel: channel, chunkSize: chunkSize)
            var context: Void = ()
            await T._renderAsync(renderable, into: sink, context: &context)
            await sink.finish()
        }
    }

    /// Stream rendered content with custom context.
    ///
    /// Use this overload when your renderable requires a custom context type.
    /// The context is passed by value and cannot be mutated after rendering begins.
    ///
    /// - Parameters:
    ///   - renderable: The content to render and stream.
    ///   - context: The rendering context (passed by value).
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 1024.
    public convenience init<T: Rendering.Async.`Protocol` & Sendable>(
        rendering renderable: T,
        context: T.Context,
        chunkSize: Int = 1024
    ) where T.Context: Sendable {
        self.init()
        let channel = self
        var context = context
        Task.detached {
            let sink = Rendering.Async.Sink.Buffered(channel: channel, chunkSize: chunkSize)
            await T._renderAsync(renderable, into: sink, context: &context)
            await sink.finish()
        }
    }
}
