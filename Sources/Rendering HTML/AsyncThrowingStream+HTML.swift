//
//  AsyncThrowingStream.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Rendering

extension AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
    /// Stream HTML as async byte chunks (throwing).
    ///
    /// ## Streaming Modes
    ///
    /// - **Buffered**: Renders entire HTML first, then streams chunks. Simple and predictable.
    /// - **Streaming**: For true backpressure, use `asyncChannel()` instead.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Buffered mode (default)
    /// for try await chunk in AsyncThrowingStream(chunkSize: 4096) {
    ///     div { "Hello" }
    /// } {
    ///     try await response.write(chunk)
    /// }
    ///
    /// // For true streaming with backpressure, use asyncChannel:
    /// for await chunk in myView.asyncChannel(chunkSize: 4096) {
    ///     await response.write(chunk)
    /// }
    /// ```
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.buffered`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - view: The HTML content to stream.
    @inlinable
    public init<View: HTML.View & Sendable>(
        mode: HTML.StreamingMode = .buffered,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ view: () -> View
    ) {
        let view = view()
        let config = configuration ?? .default

        switch mode {
        case .buffered:
            self.init { continuation in
                Task { @Sendable in
                    do {
                        var buffer: [UInt8] = []
                        var context = HTML.Context(config)
                        View._render(view, into: &buffer, context: &context)

                        var offset = 0
                        while offset < buffer.count {
                            await Task.yield()
                            try Task.checkCancellation()

                            let end = Swift.min(offset + chunkSize, buffer.count)
                            continuation.yield(buffer[offset..<end])
                            offset = end
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }

        case .streaming:
            // Note: AsyncThrowingStream cannot provide true backpressure.
            // For true streaming with backpressure, use asyncChannel() instead.
            // This falls back to chunked buffered mode.
            self.init { continuation in
                Task { @Sendable in
                    var context = HTML.Context(config)
                    var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                        continuation.yield(chunk)
                    }

                    View._render(view, into: &buffer, context: &context)
                    buffer.flushRemaining()
                    continuation.finish()
                }
            }
        }
    }
}

extension AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
    /// Stream an HTML document as async byte chunks (throwing).
    ///
    /// ## Streaming Modes
    ///
    /// - **Buffered**: Renders entire document first (styles in `<head>`), then streams chunks.
    /// - **Streaming**: For true backpressure, use `asyncChannel()` instead.
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.buffered`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    ///   - document: The HTML document to stream.
    @inlinable
    public init<Document: HTML.DocumentProtocol & Sendable>(
        mode: HTML.StreamingMode = .buffered,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil,
        @HTML.Builder _ document: () -> Document
    ) {
        let document = document()
        let config = configuration ?? .default

        switch mode {
        case .buffered:
            self.init { continuation in
                Task { @Sendable in
                    do {
                        var buffer: [UInt8] = []
                        var context = HTML.Context(config)
                        Document._render(document, into: &buffer, context: &context)

                        var offset = 0
                        while offset < buffer.count {
                            await Task.yield()
                            try Task.checkCancellation()

                            let end = Swift.min(offset + chunkSize, buffer.count)
                            continuation.yield(buffer[offset..<end])
                            offset = end
                        }
                        continuation.finish()
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }

        case .streaming:
            // Note: AsyncThrowingStream cannot provide true backpressure.
            // For true streaming with backpressure, use asyncChannel() instead.
            // This falls back to chunked buffered mode with progressive style emission.
            self.init { continuation in
                Task { @Sendable in
                    var context = HTML.Context(config)
                    var buffer = ChunkingBuffer(chunkSize: chunkSize) { chunk in
                        continuation.yield(chunk)
                    }

                    // Stream doctype and opening tags
                    buffer.append(contentsOf: [UInt8].html.tag.doctype)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.open)
                    buffer.append(contentsOf: config.newline)

                    // Stream head
                    buffer.append(contentsOf: [UInt8].html.tag.headOpen)
                    buffer.append(contentsOf: config.newline)
                    Document.Head._render(document.head, into: &buffer, context: &context)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.headClose)
                    buffer.append(contentsOf: config.newline)

                    // Stream body opening
                    buffer.append(contentsOf: [UInt8].html.tag.bodyOpen)

                    // Stream body content progressively, collecting styles
                    Document.Content._render(document.body, into: &buffer, context: &context)

                    // Emit collected styles at end of body
                    if !context.styles.isEmpty {
                        buffer.append(contentsOf: config.newline)
                        buffer.append(contentsOf: [UInt8].html.tag.styleOpen)
                        let stylesheetBytes = context.stylesheetBytes
                        buffer.append(contentsOf: stylesheetBytes)
                        buffer.append(contentsOf: [UInt8].html.tag.styleClose)
                    }

                    // Close body and html
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.bodyClose)
                    buffer.append(contentsOf: config.newline)
                    buffer.append(contentsOf: [UInt8].html.tag.close)

                    buffer.flushRemaining()
                    continuation.finish()
                }
            }
        }
    }
}

extension HTML.View where Self: Sendable {
    /// Stream this HTML as async byte chunks (throwing).
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.buffered`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncThrowingStream(
        mode: HTML.StreamingMode = .buffered,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(mode: mode, chunkSize: chunkSize, configuration: configuration) {
            self
        }
    }
}

extension HTML.DocumentProtocol where Self: Sendable {
    /// Stream this document as async byte chunks (throwing).
    ///
    /// - Parameters:
    ///   - mode: Streaming mode. Default is `.buffered`.
    ///   - chunkSize: Size of each yielded chunk in bytes. Default is 4096.
    ///   - configuration: Rendering configuration. Uses default if nil.
    /// - Returns: An AsyncThrowingStream yielding byte chunks.
    @inlinable
    public func asyncThrowingStream(
        mode: HTML.StreamingMode = .buffered,
        chunkSize: Int = 4096,
        configuration: HTML.Context.Configuration? = nil
    ) -> AsyncThrowingStream<ArraySlice<UInt8>, any Error> {
        AsyncThrowingStream(mode: mode, chunkSize: chunkSize, configuration: configuration) {
            self
        }
    }
}
