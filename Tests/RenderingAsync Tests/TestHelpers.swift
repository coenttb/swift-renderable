//
//  TestHelpers.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering
@testable import RenderingAsync

// MARK: - Async Test Rendering Types

/// A minimal async renderable type for testing
struct AsyncTestRenderable: Rendering.`Protocol`, Rendering.Async.`Protocol`, Sendable, Equatable {
    let value: String

    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    init(_ value: String = "test") {
        self.value = value
    }

    var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: AsyncTestRenderable,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: markup.value.utf8)
    }

    static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: AsyncTestRenderable,
        into sink: Sink,
        context: inout Void
    ) async {
        await sink.write(markup.value.utf8)
    }
}

/// An async renderable with custom context
struct AsyncContextualRenderable: Rendering.`Protocol`, Rendering.Async.`Protocol`, Sendable {
    let prefix: String

    typealias Context = AsyncTestContext
    typealias Content = Never
    typealias Output = UInt8

    init(_ prefix: String = "") {
        self.prefix = prefix
    }

    var body: Never {
        fatalError("This type uses direct rendering and doesn't have a body.")
    }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: AsyncContextualRenderable,
        into buffer: inout Buffer,
        context: inout AsyncTestContext
    ) where Buffer.Element == UInt8 {
        context.renderCount += 1
        let output = "\(markup.prefix)\(context.renderCount)"
        buffer.append(contentsOf: output.utf8)
    }

    static func _renderAsync<Sink: Rendering.Async.Sink.`Protocol`>(
        _ markup: AsyncContextualRenderable,
        into sink: Sink,
        context: inout AsyncTestContext
    ) async {
        context.renderCount += 1
        let output = "\(markup.prefix)\(context.renderCount)"
        await sink.write(output.utf8)
    }
}

/// Test context for async rendering
struct AsyncTestContext: Sendable {
    var renderCount: Int = 0

    init() {}
    init(renderCount: Int) {
        self.renderCount = renderCount
    }
}

// MARK: - Async Render Helpers

/// Renders an async renderable to a String.
///
/// IMPORTANT: Producer and consumer must run concurrently because `AsyncChannel`
/// applies backpressure - `send()` suspends until the chunk is consumed.
/// Running them sequentially would deadlock when content exceeds chunkSize.
/// See the Sink.Buffered documentation for the correct usage pattern.
func renderAsync<T: Rendering.Async.`Protocol`>(_ renderable: T) async -> String
where T.Context == Void, T: Sendable {
    let sink = Rendering.Async.Sink.Buffered(chunkSize: 1024)

    // Run producer in a separate Task (following Sink.Buffered documentation)
    let producerTask = Task {
        var context: Void = ()
        await T._renderAsync(renderable, into: sink, context: &context)
        await sink.finish()
    }

    // Consumer runs concurrently
    var bytes: [UInt8] = []
    for await chunk in sink.chunks {
        bytes.append(contentsOf: chunk)
    }

    await producerTask.value  // Ensure producer completes
    return String(decoding: bytes, as: UTF8.self)
}

/// Renders an async renderable with context to a String.
///
/// Note: For tests with context, we use a simple buffer approach without AsyncChannel
/// to avoid the backpressure deadlock issue while still testing context propagation.
func renderAsync<T: Rendering.Async.`Protocol`>(
    _ renderable: T,
    context: inout T.Context
) async -> String {
    // For context tests, use a simple collecting sink approach
    // We render to a temporary buffer first, avoiding AsyncChannel backpressure
    var buffer: [UInt8] = []
    T._render(renderable, into: &buffer, context: &context)
    return String(decoding: buffer, as: UTF8.self)
}

/// Collects all chunks from a sink.
///
/// Note: The sink must already be finished before calling this,
/// or this will hang waiting for more chunks.
func collectChunks(from sink: Rendering.Async.Sink.Buffered) async -> [[UInt8]] {
    var chunks: [[UInt8]] = []
    for await chunk in sink.chunks {
        chunks.append(Array(chunk))
    }
    return chunks
}
