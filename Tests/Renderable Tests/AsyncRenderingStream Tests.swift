//
//  AsyncRenderableStream Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Renderable
import Testing
import AsyncAlgorithms

@Suite
struct `AsyncRenderableStream Tests` {

    // MARK: - Basic Functionality

    @Test
    func `AsyncRenderableStream can be created with default chunk size`() async {
        let stream = AsyncRenderingStream()
        _ = stream // Verify it compiles
        #expect(Bool(true))
    }

    @Test
    func `AsyncRenderableStream can be created with custom chunk size`() async {
        let stream = AsyncRenderingStream(chunkSize: 100)
        _ = stream // Verify it compiles
        #expect(Bool(true))
    }

    @Test
    func `AsyncRenderableStream can be created with external channel`() async {
        let channel = AsyncChannel<ArraySlice<UInt8>>()
        let stream = AsyncRenderingStream(channel: channel, chunkSize: 1024)
        _ = stream // Verify it compiles
        #expect(Bool(true))
    }

    // MARK: - Write and Consume

    @Test
    func `AsyncRenderableStream writes and finishes`() async {
        let stream = AsyncRenderingStream(chunkSize: 10)

        Task {
            await stream.write("Hello".utf8)
            await stream.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello")
    }

    @Test
    func `AsyncRenderableStream chunks at specified size`() async {
        let chunkSize = 5
        let stream = AsyncRenderingStream(chunkSize: chunkSize)

        Task {
            await stream.write("1234567890".utf8) // 10 bytes -> should produce 2 chunks of 5
            await stream.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream.chunks {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 5)
    }

    @Test
    func `AsyncRenderableStream handles partial final chunk`() async {
        let chunkSize = 5
        let stream = AsyncRenderingStream(chunkSize: chunkSize)

        Task {
            await stream.write("1234567".utf8) // 7 bytes -> 1 chunk of 5, 1 chunk of 2
            await stream.finish()
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in stream.chunks {
            chunks.append(chunk)
        }

        #expect(chunks.count == 2)
        #expect(chunks[0].count == 5)
        #expect(chunks[1].count == 2)
    }

    // MARK: - Single Byte Write

    @Test
    func `AsyncRenderableStream can write single bytes`() async {
        let stream = AsyncRenderingStream(chunkSize: 3)

        Task {
            await stream.write(UInt8(ascii: "A"))
            await stream.write(UInt8(ascii: "B"))
            await stream.write(UInt8(ascii: "C"))
            await stream.write(UInt8(ascii: "D"))
            await stream.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "ABCD")
    }

    // MARK: - Empty Stream

    @Test
    func `AsyncRenderableStream handles empty content`() async {
        let stream = AsyncRenderingStream(chunkSize: 10)

        Task {
            await stream.finish()
        }

        var chunkCount = 0
        for await _ in stream.chunks {
            chunkCount += 1
        }

        #expect(chunkCount == 0)
    }

    // MARK: - Multiple Writes

    @Test
    func `AsyncRenderableStream handles multiple writes`() async {
        let stream = AsyncRenderingStream(chunkSize: 100)

        Task {
            await stream.write("Hello ".utf8)
            await stream.write("World".utf8)
            await stream.write("!".utf8)
            await stream.finish()
        }

        var allBytes: [UInt8] = []
        for await chunk in stream.chunks {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "Hello World!")
    }

    // MARK: - Chunks Property

    @Test
    func `AsyncRenderableStream chunks property returns AsyncChannel`() async {
        let stream = AsyncRenderingStream()
        let _: AsyncChannel<ArraySlice<UInt8>> = stream.chunks
        #expect(Bool(true)) // Compile-time check
    }

    // MARK: - Sendable

    @Test
    func `AsyncRenderableStream is Sendable`() async {
        let stream = AsyncRenderingStream()
        Task {
            await stream.write("test".utf8)
            await stream.finish()
        }
        // Consume to prevent hanging
        for await _ in stream.chunks {}
        #expect(Bool(true)) // Compile-time check
    }
}
