//
//  AsyncChunkingBuffer Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `AsyncChunkingBuffer Tests` {

    // MARK: - Basic Functionality

    @Test
    func `AsyncChunkingBuffer chunks at specified size`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 5, continuation: continuation)

        Task {
            await buffer.append(contentsOf: "1234567890".utf8) // 10 bytes
            await buffer.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 5)
    }

    @Test
    func `AsyncChunkingBuffer handles partial final chunk`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 5, continuation: continuation)

        Task {
            await buffer.append(contentsOf: "1234567".utf8) // 7 bytes
            await buffer.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 2)
    }

    // MARK: - Single Byte Append

    @Test
    func `AsyncChunkingBuffer can append single bytes`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 3, continuation: continuation)

        Task {
            await buffer.append(UInt8(ascii: "A"))
            await buffer.append(UInt8(ascii: "B"))
            await buffer.append(UInt8(ascii: "C"))
            await buffer.append(UInt8(ascii: "D"))
            await buffer.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "ABCD")
    }

    // MARK: - Empty Buffer

    @Test
    func `AsyncChunkingBuffer handles empty content`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 10, continuation: continuation)

        Task {
            await buffer.finish()
        }

        var chunkCount = 0
        for await _ in stream {
            chunkCount += 1
        }

        #expect(chunkCount == 0)
    }

    // MARK: - Multiple Appends

    @Test
    func `AsyncChunkingBuffer handles multiple appends`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 100, continuation: continuation)

        Task {
            await buffer.append(contentsOf: "Hello ".utf8)
            await buffer.append(contentsOf: "World".utf8)
            await buffer.append(contentsOf: "!".utf8)
            await buffer.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello World!")
    }

    // MARK: - Yield Interval

    @Test
    func `AsyncChunkingBuffer respects yield interval`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        // Small yield interval to trigger yielding
        let buffer = AsyncChunkingBuffer(chunkSize: 10, yieldInterval: 5, continuation: continuation)

        Task {
            await buffer.append(contentsOf: "12345678901234567890".utf8)
            await buffer.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "12345678901234567890")
    }

    // MARK: - Large Content

    @Test
    func `AsyncChunkingBuffer handles large content`() async {
        let (stream, continuation) = AsyncStream<ArraySlice<UInt8>>.makeStream()
        let buffer = AsyncChunkingBuffer(chunkSize: 100, continuation: continuation)

        let content = String(repeating: "X", count: 1000)

        Task {
            await buffer.append(contentsOf: content.utf8)
            await buffer.finish()
        }

        var totalBytes = 0
        var chunkCount = 0
        for await chunk in stream {
            totalBytes += chunk.count
            chunkCount += 1
        }

        #expect(totalBytes == 1000)
        #expect(chunkCount == 10) // 1000 / 100 = 10 chunks
    }
}
