//
//  AsyncRenderableStream.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

public import AsyncAlgorithms

/// An actor-based stream that accepts bytes and sends chunks with backpressure.
///
/// This stream wraps `AsyncChannel` to provide bounded memory streaming.
/// When a chunk is ready, `send()` suspends until the consumer processes it,
/// ensuring memory usage is bounded to O(chunkSize).
///
/// ## Backpressure
///
/// Unlike `AsyncStream` which can buffer unbounded data when the consumer
/// is slow, `AsyncRenderableStream` applies backpressure by suspending the
/// producer until chunks are consumed. This ensures memory is bounded.
///
/// ## Usage
///
/// ```swift
/// let stream = AsyncRenderableStream(chunkSize: 4096)
///
/// // Producer task
/// Task {
///     await stream.write("<html>".utf8)
///     await stream.write("<body>".utf8)
///     // ... more writes ...
///     await stream.finish()
/// }
///
/// // Consumer
/// for await chunk in stream.chunks {
///     await response.write(chunk)
/// }
/// ```
public actor AsyncRenderingStream: AsyncRenderingStreamProtocol {
    private let channel: AsyncChannel<ArraySlice<UInt8>>
    private var buffer: [UInt8]
    private let chunkSize: Int

    /// Creates a new async rendering stream with its own channel.
    ///
    /// - Parameter chunkSize: The size of chunks to yield (default 4096).
    public init(chunkSize: Int = 4096) {
        self.channel = AsyncChannel()
        self.buffer = []
        self.buffer.reserveCapacity(chunkSize)
        self.chunkSize = chunkSize
    }

    /// Creates a new async rendering stream using an external channel.
    ///
    /// - Parameters:
    ///   - channel: The external channel to send chunks to.
    ///   - chunkSize: The size of chunks to yield (default 4096).
    public init(channel: AsyncChannel<ArraySlice<UInt8>>, chunkSize: Int = 4096) {
        self.channel = channel
        self.buffer = []
        self.buffer.reserveCapacity(chunkSize)
        self.chunkSize = chunkSize
    }

    /// Write bytes to the stream, sending full chunks with backpressure.
    ///
    /// When the buffer fills to `chunkSize`, a chunk is sent to the channel.
    /// The `send()` call suspends until the consumer reads the chunk,
    /// providing backpressure.
    ///
    /// - Parameter bytes: The bytes to write.
    public func write(_ bytes: some Sequence<UInt8> & Sendable) async {
        buffer.append(contentsOf: bytes)
        await flushFullChunks()
    }

    /// Write a single byte to the stream.
    ///
    /// - Parameter byte: The byte to write.
    public func write(_ byte: UInt8) async {
        buffer.append(byte)
        if buffer.count >= chunkSize {
            await flushFullChunks()
        }
    }

    /// Flush any full chunks to the channel.
    ///
    /// Uses offset-based iteration to avoid O(n²) behavior from repeated
    /// `removeFirst()` calls. Only performs a single `removeFirst()` at the end.
    private func flushFullChunks() async {
        var offset = 0
        while buffer.count - offset >= chunkSize {
            let end = offset + chunkSize
            await channel.send(ArraySlice(buffer[offset..<end]))  // Backpressure: suspends until consumed
            offset = end
        }
        if offset > 0 {
            buffer.removeFirst(offset)
        }
    }

    /// Flush remaining bytes and finish the stream.
    ///
    /// Call this when rendering is complete to send any remaining buffered
    /// bytes and signal to consumers that the stream is finished.
    public func finish() async {
        if !buffer.isEmpty {
            await channel.send(ArraySlice(buffer))
            buffer.removeAll()
        }
        channel.finish()
    }

    /// The underlying async sequence for consumers.
    ///
    /// Iterate over this sequence to receive chunks as they become available.
    /// The sequence completes when `finish()` is called.
    public nonisolated var chunks: AsyncChannel<ArraySlice<UInt8>> {
        channel
    }
}
