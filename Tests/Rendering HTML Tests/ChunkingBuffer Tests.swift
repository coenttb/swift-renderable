//
//  ChunkingBuffer Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
@testable import Rendering_HTML
import Testing

@Suite
struct `ChunkingBuffer Tests` {

    // MARK: - Initialization

    @Test
    func `ChunkingBuffer initializes with chunkSize`() {
        let buffer = ChunkingBuffer(chunkSize: 10) { _ in }
        #expect(buffer.isEmpty)
        #expect(buffer.chunkSize == 10)
    }

    @Test
    func `ChunkingBuffer default initializer`() {
        let buffer = ChunkingBuffer()
        #expect(buffer.isEmpty)
        #expect(buffer.chunkSize == 4096)
    }

    // MARK: - Basic Appending

    @Test
    func `Appending single bytes does not flush below chunk size`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 5) { _ in
            counter.withValue { $0 += 1 }
        }

        buffer.append(1)
        buffer.append(2)
        buffer.append(3)

        #expect(buffer.count == 3)
        #expect(counter.value == 0) // Not yet at chunk size
    }

    @Test
    func `Appending triggers flush at chunk size`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 5) { _ in
            counter.withValue { $0 += 1 }
        }

        for i: UInt8 in 1...5 {
            buffer.append(i)
        }

        #expect(counter.value == 1)
        #expect(buffer.isEmpty)
    }

    @Test
    func `Appending sequence triggers multiple flushes`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 3) { _ in
            counter.withValue { $0 += 1 }
        }

        buffer.append(contentsOf: [1, 2, 3, 4, 5, 6, 7])

        #expect(counter.value == 2) // Two chunks of 3
        #expect(buffer.count == 1) // One byte remaining
    }

    // MARK: - Flush Remaining

    @Test
    func `FlushRemaining sends remaining bytes`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 10) { _ in
            counter.withValue { $0 += 1 }
        }

        buffer.append(contentsOf: [1, 2, 3])
        #expect(counter.value == 0)

        buffer.flushRemaining()
        #expect(counter.value == 1)
        #expect(buffer.isEmpty)
    }

    @Test
    func `FlushRemaining with empty buffer does not flush`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 10) { _ in
            counter.withValue { $0 += 1 }
        }

        buffer.flushRemaining()
        #expect(counter.value == 0)
    }

    // MARK: - RangeReplaceableCollection Conformance

    @Test
    func `ChunkingBuffer is a Collection`() {
        var buffer = ChunkingBuffer(chunkSize: 10) { _ in }
        buffer.append(contentsOf: [1, 2, 3])

        #expect(buffer.startIndex == 0)
        #expect(buffer.endIndex == 3)
        #expect(buffer[0] == 1)
        #expect(buffer[1] == 2)
        #expect(buffer[2] == 3)
    }

    @Test
    func `ChunkingBuffer replaceSubrange`() {
        var buffer = ChunkingBuffer(chunkSize: 20) { _ in }

        buffer.append(contentsOf: [1, 2, 3, 4, 5])
        buffer.replaceSubrange(1..<3, with: [9, 8, 7])

        #expect(Array(buffer) == [1, 9, 8, 7, 4, 5])
    }

    // MARK: - Multiple Chunk Flushes

    @Test
    func `Large append triggers multiple flushes`() {
        let counter = LockIsolated(0)
        var buffer = ChunkingBuffer(chunkSize: 3) { _ in
            counter.withValue { $0 += 1 }
        }

        buffer.append(contentsOf: Array(1...10))

        #expect(counter.value == 3) // Three chunks of 3 bytes each
        #expect(Array(buffer) == [10]) // One byte remaining
    }

    @Test
    func `Index after increments correctly`() {
        var buffer = ChunkingBuffer(chunkSize: 10) { _ in }
        buffer.append(contentsOf: [1, 2, 3])

        #expect(buffer.index(after: 0) == 1)
        #expect(buffer.index(after: 1) == 2)
        #expect(buffer.index(after: 2) == 3)
    }
}

/// A thread-safe value container for tests.
private final class LockIsolated<Value: Sendable>: @unchecked Sendable {
    private var _value: Value
    private let lock = NSLock()

    init(_ value: Value) {
        self._value = value
    }

    var value: Value {
        lock.lock()
        defer { lock.unlock() }
        return _value
    }

    func withValue<T>(_ operation: (inout Value) -> T) -> T {
        lock.lock()
        defer { lock.unlock() }
        return operation(&_value)
    }
}
