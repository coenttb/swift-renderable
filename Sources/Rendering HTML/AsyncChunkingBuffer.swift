//
//  AsyncChunkingBuffer.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

/// An actor-based buffer that yields chunks asynchronously during rendering.
///
/// This enables true progressive streaming where chunks are delivered to consumers
/// as content is rendered, rather than waiting for the entire render to complete.
@usableFromInline
actor AsyncChunkingBuffer {
    @usableFromInline
    var buffer: [UInt8]

    @usableFromInline
    let chunkSize: Int

    @usableFromInline
    let continuation: AsyncStream<ArraySlice<UInt8>>.Continuation

    /// Number of bytes written since last yield point.
    @usableFromInline
    var bytesSinceYield: Int = 0

    /// Yield to consumer after this many bytes to ensure responsiveness.
    @usableFromInline
    let yieldInterval: Int

    @usableFromInline
    init(
        chunkSize: Int,
        yieldInterval: Int = 4096,
        continuation: AsyncStream<ArraySlice<UInt8>>.Continuation
    ) {
        self.buffer = []
        self.buffer.reserveCapacity(chunkSize)
        self.chunkSize = chunkSize
        self.yieldInterval = yieldInterval
        self.continuation = continuation
    }

    /// Append bytes and flush chunks as needed.
    @usableFromInline
    func append<S: Sequence>(contentsOf bytes: S) async where S.Element == UInt8 {
        buffer.append(contentsOf: bytes)
        bytesSinceYield += buffer.count

        await flushFullChunks()
    }

    /// Append a single byte.
    @usableFromInline
    func append(_ byte: UInt8) async {
        buffer.append(byte)
        bytesSinceYield += 1

        if buffer.count >= chunkSize {
            await flushFullChunks()
        }
    }

    /// Flush all complete chunks and yield to allow consumer to process.
    @usableFromInline
    func flushFullChunks() async {
        var offset = 0
        while buffer.count - offset >= chunkSize {
            let end = offset + chunkSize
            continuation.yield(buffer[offset..<end])
            offset = end
        }
        if offset > 0 {
            buffer.removeFirst(offset)
        }

        // Yield control to allow consumer to receive chunks
        if bytesSinceYield >= yieldInterval {
            bytesSinceYield = 0
            await Task.yield()
        }
    }

    /// Flush any remaining bytes and finish the stream.
    @usableFromInline
    func finish() {
        if !buffer.isEmpty {
            continuation.yield(ArraySlice(buffer))
            buffer.removeAll(keepingCapacity: false)
        }
        continuation.finish()
    }
}
