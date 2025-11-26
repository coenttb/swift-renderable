//
//  AsyncChannel+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

public import AsyncAlgorithms
import Rendering

extension AsyncChannel<ArraySlice<UInt8>> {
    /// Stream HTML with true progressive rendering and backpressure.
    ///
    /// This initializer provides memory-bounded streaming throughout the entire
    /// render-to-stream process using `AsyncChannel` for backpressure.
    /// The producer suspends when the consumer is slow, ensuring memory
    /// usage is bounded to O(chunkSize) at all times.
    ///
    /// ## Memory Bounds
    ///
    /// Unlike batch or progressive modes that may accumulate the entire document
    /// in memory before streaming, backpressure mode maintains bounded memory:
    ///
    /// | Mode | During Render | During Stream |
    /// |------|---------------|---------------|
    /// | batch | O(doc size) | O(chunkSize) |
    /// | progressive | O(doc size) | O(chunkSize) |
    /// | **backpressure** | **O(chunkSize)** | **O(chunkSize)** |
    ///
    /// ## Example
    ///
    /// ```swift
    /// for await chunk in AsyncChannel(chunkSize: 4096) {
    ///     div { "Hello" }
    /// } {
    ///     await response.write(chunk)
    /// }
    /// ```
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
    /// ## Example
    ///
    /// ```swift
    /// for await chunk in AsyncChannel(chunkSize: 4096) {
    ///     HTML.Document {
    ///         div { "Hello" }
    ///     }
    /// } {
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

        Task.detached {
            let stream = AsyncRenderingStream(channel: channel, chunkSize: chunkSize)
            var context = HTML.Context(config)
            await Document._renderAsync(document, into: stream, context: &context)
            await stream.finish()
        }
    }
}

// MARK: - Convenience Extensions

extension HTML.View where Self: AsyncRendering & Sendable {
    /// Stream this HTML with true progressive rendering and backpressure.
    ///
    /// This method provides memory-bounded streaming throughout the entire
    /// render-to-stream process.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// for await chunk in html.asyncChannel(chunkSize: 4096) {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - chunkSize: Size of chunks to yield (default 4096).
    ///   - configuration: Optional rendering configuration.
    /// - Returns: An async sequence of byte chunks with backpressure.
    public func asyncChannel(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncChannel<ArraySlice<UInt8>> {
        AsyncChannel(chunkSize: chunkSize, configuration: configuration) { self }
    }
}

extension HTML.DocumentProtocol where Self: AsyncRendering & Sendable {
    /// Stream this document with true progressive rendering and backpressure.
    ///
    /// - Parameters:
    ///   - chunkSize: Size of chunks to yield (default 4096).
    ///   - configuration: Optional rendering configuration.
    /// - Returns: An async sequence of byte chunks with backpressure.
    public func asyncChannel(
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncChannel<ArraySlice<UInt8>> {
        AsyncChannel(chunkSize: chunkSize, configuration: configuration) { self }
    }
}
