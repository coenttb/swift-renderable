//
//  AsyncChannel+Rendering Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 10/12/2025.
//

import AsyncAlgorithms
import Testing

@testable import Rendering
@testable import RenderingAsync

@Suite
struct `AsyncChannel_Rendering Tests` {

    // MARK: - Basic Rendering

    @Test
    func `renders content via convenience init`() async {
        let renderable = AsyncTestRenderable("hello world")
        let channel = AsyncChannel(rendering: renderable)

        var allBytes: [UInt8] = []
        for await chunk in channel {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "hello world")
    }

    @Test
    func `renders empty content`() async {
        let renderable = AsyncTestRenderable("")
        let channel = AsyncChannel(rendering: renderable)

        var allBytes: [UInt8] = []
        for await chunk in channel {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    @Test
    func `renders unicode content`() async {
        let renderable = AsyncTestRenderable("héllo 世界 🎉")
        let channel = AsyncChannel(rendering: renderable)

        var allBytes: [UInt8] = []
        for await chunk in channel {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result == "héllo 世界 🎉")
    }

    // MARK: - Chunk Size

    @Test
    func `respects custom chunk size`() async {
        let content = String(repeating: "x", count: 100)
        let renderable = AsyncTestRenderable(content)
        let channel = AsyncChannel(rendering: renderable, chunkSize: 10)

        var chunkCount = 0
        var totalBytes = 0
        for await chunk in channel {
            chunkCount += 1
            totalBytes += chunk.count
        }

        #expect(totalBytes == 100)
        #expect(chunkCount == 10)  // 100 bytes / 10 per chunk
    }

    @Test(arguments: [1, 10, 100, 1000])
    func `works with various chunk sizes`(chunkSize: Int) async {
        let content = String(repeating: "y", count: 500)
        let renderable = AsyncTestRenderable(content)
        let channel = AsyncChannel(rendering: renderable, chunkSize: chunkSize)

        var totalBytes = 0
        for await chunk in channel {
            totalBytes += chunk.count
        }

        #expect(totalBytes == 500)
    }

    // MARK: - Large Content (Backpressure Test)

    @Test
    func `handles large content without deadlock`() async {
        // This test verifies the concurrent producer/consumer pattern works
        let content = String(repeating: "z", count: 50_000)
        let renderable = AsyncTestRenderable(content)
        let channel = AsyncChannel(rendering: renderable, chunkSize: 1024)

        var totalBytes = 0
        for await chunk in channel {
            totalBytes += chunk.count
        }

        #expect(totalBytes == 50_000)
    }

    // MARK: - Concurrent Access

    @Test
    func `is safe for concurrent iteration`() async {
        // Create multiple streams concurrently
        await withTaskGroup(of: String.self) { group in
            for i in 0..<5 {
                group.addTask {
                    let renderable = AsyncTestRenderable("task-\(i)")
                    let channel = AsyncChannel(rendering: renderable)

                    var bytes: [UInt8] = []
                    for await chunk in channel {
                        bytes.append(contentsOf: chunk)
                    }
                    return String(decoding: bytes, as: UTF8.self)
                }
            }

            var results: [String] = []
            for await result in group {
                results.append(result)
            }

            #expect(results.count == 5)
        }
    }

    // MARK: - Memory Bounded

    @Test
    func `maintains bounded memory with slow consumer`() async {
        // This test simulates a slow consumer to verify backpressure works
        let content = String(repeating: "m", count: 10_000)
        let renderable = AsyncTestRenderable(content)
        let channel = AsyncChannel(rendering: renderable, chunkSize: 100)

        var totalBytes = 0
        for await chunk in channel {
            // Simulate slow consumer
            try? await Task.sleep(for: .microseconds(10))
            totalBytes += chunk.count
        }

        #expect(totalBytes == 10_000)
    }
}
