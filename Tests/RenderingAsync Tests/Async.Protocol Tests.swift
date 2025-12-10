//
//  Async.Protocol Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing
@testable import Rendering
@testable import RenderingAsync

@Suite
struct `Async_Protocol Tests` {

    // MARK: - Basic Async Rendering

    @Test
    func `_renderAsync writes bytes to sink`() async {
        let renderable = AsyncTestRenderable("hello")
        let result = await renderAsync(renderable)
        #expect(result == "hello")
    }

    @Test
    func `_renderAsync handles empty content`() async {
        let renderable = AsyncTestRenderable("")
        let result = await renderAsync(renderable)
        #expect(result == "")
    }

    @Test
    func `_renderAsync handles unicode content`() async {
        let renderable = AsyncTestRenderable("héllo 世界 🎉")
        let result = await renderAsync(renderable)
        #expect(result == "héllo 世界 🎉")
    }

    // MARK: - Context Propagation

    @Test
    func `_renderAsync receives mutable context`() async {
        let renderable = AsyncContextualRenderable("item-")
        var context = AsyncTestContext()
        let result = await renderAsync(renderable, context: &context)
        #expect(result == "item-1")
        #expect(context.renderCount == 1)
    }

    @Test
    func `context mutations persist across async renders`() async {
        let renderable1 = AsyncContextualRenderable("a")
        let renderable2 = AsyncContextualRenderable("b")
        var context = AsyncTestContext()

        let result1 = await renderAsync(renderable1, context: &context)
        let result2 = await renderAsync(renderable2, context: &context)

        #expect(result1 == "a1")
        #expect(result2 == "b2")
        #expect(context.renderCount == 2)
    }

    // MARK: - Sink Integration

    @Test
    func `_renderAsync works with Sink.Buffered`() async {
        let sink = Rendering.Async.Sink.Buffered(chunkSize: 100)
        let renderable = AsyncTestRenderable("test")

        // Producer and consumer must run concurrently due to backpressure
        let producerTask = Task {
            var context: Void = ()
            await AsyncTestRenderable._renderAsync(renderable, into: sink, context: &context)
            await sink.finish()
        }

        var bytes: [UInt8] = []
        for await chunk in sink.chunks {
            bytes.append(contentsOf: chunk)
        }

        await producerTask.value
        #expect(String(decoding: bytes, as: UTF8.self) == "test")
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [
        ("simple", "simple"),
        ("with spaces", "with spaces"),
        ("special: <>&\"'", "special: <>&\"'"),
        ("unicode: café", "unicode: café"),
        ("emoji: 🚀", "emoji: 🚀")
    ])
    func `_renderAsync preserves content`(input: String, expected: String) async {
        let renderable = AsyncTestRenderable(input)
        let result = await renderAsync(renderable)
        #expect(result == expected)
    }

    // MARK: - Large Content

    @Test
    func `_renderAsync handles large content`() async {
        let largeContent = String(repeating: "x", count: 10_000)
        let renderable = AsyncTestRenderable(largeContent)
        let result = await renderAsync(renderable)
        #expect(result.count == 10_000)
    }

    // MARK: - Concurrent Safety

    @Test
    func `_renderAsync is safe for concurrent use`() async {
        let renderable = AsyncTestRenderable("concurrent")

        await withTaskGroup(of: String.self) { group in
            for i in 0..<10 {
                group.addTask {
                    await renderAsync(AsyncTestRenderable("task-\(i)"))
                }
            }

            var results: [String] = []
            for await result in group {
                results.append(result)
            }

            #expect(results.count == 10)
        }
    }
}
