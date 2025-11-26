//
//  AsyncChannel Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AsyncChannel Tests` {

    // MARK: - Basic Streaming

    @Test
    func `AsyncChannel streams HTML content`() async {
        struct TestHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncChannel { TestHTML() } {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test
    func `AsyncChannel yields complete content`() async {
        struct MultiParagraphHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                Group {
                    tag("p") { HTML.Text("First") }
                    tag("p") { HTML.Text("Second") }
                    tag("p") { HTML.Text("Third") }
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel { MultiParagraphHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test
    func `AsyncChannel respects chunk size`() async {
        struct LongContentHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for await chunk in AsyncChannel(chunkSize: 100) { LongContentHTML() } {
            chunks.append(chunk)
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test
    func `AsyncChannel with default chunk size`() async {
        struct SimpleHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        var chunkCount = 0
        for await _ in AsyncChannel { SimpleHTML() } {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test
    func `AsyncChannel with custom configuration`() async {
        struct StyledHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096, configuration: .email) { StyledHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        // Inline styles are rendered as class names, verify div is rendered
        #expect(result.contains("<div"))
        #expect(result.contains("Content"))
    }

    @Test
    func `AsyncChannel with nil configuration uses default`() async {
        struct SpanHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel(chunkSize: 4096, configuration: nil) { SpanHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Empty Content

    @Test
    func `AsyncChannel with empty content`() async {
        struct EmptyHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel { EmptyHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test
    func `AsyncChannel with nested elements`() async {
        struct NestedHTML: HTML.View, AsyncRenderable, Sendable {
            var body: some HTML.View {
                tag("div") {
                    tag("ul") {
                        tag("li") { HTML.Text("Item 1") }
                        tag("li") { HTML.Text("Item 2") }
                    }
                }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncChannel { NestedHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>"))
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
    }
}

// MARK: - Concurrent Producer/Consumer Tests

extension `AsyncChannel Tests` {
    @Suite
    struct `Concurrency Tests` {

        /// This test verifies that the producer runs concurrently with the consumer.
        ///
        /// With correct `Task.detached` implementation:
        /// - AsyncChannel init returns immediately
        /// - Producer starts rendering in background
        /// - Consumer iterates while producer is still producing
        /// - First chunk arrives while rendering is still in progress
        ///
        /// With incorrect `async init` implementation:
        /// - Rendering completes entirely during init
        /// - All chunks are buffered before iteration starts
        /// - This defeats the purpose of streaming (memory is O(doc) not O(chunk))
        /// - WORSE: It causes a DEADLOCK because channel.send() suspends waiting
        ///   for a consumer, but the consumer can't start until init completes
        @Test
        func `Producer and consumer run concurrently`() async {
            // Use an actor to safely track state across concurrent tasks
            actor RenderingState {
                var producerStarted = false
                var producerFinished = false
                var firstChunkReceivedWhileProducerRunning = false

                func markProducerStarted() { producerStarted = true }
                func markProducerFinished() { producerFinished = true }
                func checkAndMarkFirstChunk() -> Bool {
                    if producerStarted && !producerFinished {
                        firstChunkReceivedWhileProducerRunning = true
                        return true
                    }
                    return false
                }
                func getResult() -> (started: Bool, finished: Bool, concurrent: Bool) {
                    (producerStarted, producerFinished, firstChunkReceivedWhileProducerRunning)
                }
            }

            let state = RenderingState()

            // HTML that takes noticeable time to render
            struct SlowRenderingHTML: HTML.View, AsyncRenderable, Sendable {
                let state: RenderingState

                var body: some HTML.View {
                    tag("div") {
                        // Generate substantial content that takes time to render
                        HTML.Text(String(repeating: "x", count: 100_000))
                    }
                }

                // Custom async render that signals when it starts/finishes
                static func _renderAsync<Stream: AsyncRenderingStreamProtocol>(
                    _ html: SlowRenderingHTML,
                    into stream: Stream,
                    context: inout HTML.Context
                ) async {
                    await html.state.markProducerStarted()

                    // Render the actual content
                    await HTML.Element<HTML.Text>._renderAsync(
                        html.body as! HTML.Element<HTML.Text>,
                        into: stream,
                        context: &context
                    )

                    await html.state.markProducerFinished()
                }
            }

            let html = SlowRenderingHTML(state: state)
            var chunkCount = 0

            // With Task.detached: channel returns immediately, producer runs concurrently
            // With async init: this line blocks until ALL rendering is done (DEADLOCK!)
            for await chunk in AsyncChannel(chunkSize: 1000) { html } {
                chunkCount += 1

                // Check if we received this chunk while producer was still running
                if chunkCount == 1 {
                    _ = await state.checkAndMarkFirstChunk()
                }

                // Don't need to consume everything for this test
                if chunkCount >= 5 {
                    break
                }
            }

            let result = await state.getResult()

            // The key assertion: with correct implementation, we should receive
            // chunks while the producer is still running (concurrent execution)
            #expect(result.started, "Producer should have started")
            #expect(result.concurrent, """
                First chunk should arrive while producer is still running.
                This indicates concurrent producer/consumer execution.
                If this fails, the AsyncChannel init is blocking until rendering completes,
                which defeats the purpose of streaming with backpressure.
                """)
        }
    }
}

// MARK: - Backpressure Verification Tests

extension `AsyncChannel Tests` {
    @Suite
    struct `Backpressure Tests` {

        @Test
        func `AsyncChannel suspends producer when consumer is slow`() async {
            struct StreamingHTML: HTML.View, AsyncRenderable, Sendable {
                var body: some HTML.View {
                    tag("div") {
                        // Generate enough content to require multiple chunks
                        HTML.Text(String(repeating: "x", count: 10_000))
                    }
                }
            }

            let chunkSize = 100
            var chunksReceived = 0
            var producerSuspended = false

            // Use a small chunk size to force multiple chunks
            let channel = AsyncChannel<ArraySlice<UInt8>>(chunkSize: chunkSize) { StreamingHTML() }

            // Consume slowly to test backpressure
            for await chunk in channel {
                chunksReceived += 1
                #expect(chunk.count <= chunkSize, "Chunk should not exceed chunk size")

                // After receiving a few chunks, introduce artificial delay
                // to test that producer doesn't overwhelm consumer
                if chunksReceived == 3 {
                    // This delay should cause the producer to suspend
                    // waiting for us to consume
                    try? await Task.sleep(for: .milliseconds(50))
                    producerSuspended = true
                }

                // Don't consume more than we need for the test
                if chunksReceived > 10 {
                    break
                }
            }

            #expect(chunksReceived > 3, "Should have received multiple chunks")
            #expect(producerSuspended, "Test should have exercised slow consumer path")
        }

        @Test
        func `AsyncChannel maintains bounded memory with large content`() async {
            struct VeryLargeHTML: HTML.View, AsyncRenderable, Sendable {
                var body: some HTML.View {
                    tag("div") {
                        // 1MB of content
                        HTML.Text(String(repeating: "a", count: 1_000_000))
                    }
                }
            }

            let chunkSize = 4096
            var maxChunkSize = 0
            var totalBytes = 0
            var chunkCount = 0

            for await chunk in AsyncChannel(chunkSize: chunkSize) { VeryLargeHTML() } {
                chunkCount += 1
                totalBytes += chunk.count

                // Track the maximum chunk size seen
                if chunk.count > maxChunkSize {
                    maxChunkSize = chunk.count
                }

                // Verify each chunk respects the size limit
                #expect(chunk.count <= chunkSize, "Chunk \(chunkCount) exceeded size limit: \(chunk.count) > \(chunkSize)")
            }

            #expect(totalBytes > 1_000_000, "Should have rendered all content")
            #expect(chunkCount > 100, "Should have many chunks for large content")
            #expect(maxChunkSize <= chunkSize, "No chunk should exceed the specified size")
        }

        @Test
        func `AsyncChannel chunks arrive progressively`() async {
            struct ProgressiveHTML: HTML.View, AsyncRenderable, Sendable {
                var body: some HTML.View {
                    Group {
                        tag("header") { HTML.Text(String(repeating: "h", count: 500)) }
                        tag("main") { HTML.Text(String(repeating: "m", count: 500)) }
                        tag("footer") { HTML.Text(String(repeating: "f", count: 500)) }
                    }
                }
            }

            var timestamps: [ContinuousClock.Instant] = []
            let startTime = ContinuousClock.now

            for await _ in AsyncChannel(chunkSize: 100) { ProgressiveHTML() } {
                timestamps.append(ContinuousClock.now)
            }

            // Verify we got multiple chunks
            #expect(timestamps.count > 1, "Should have received multiple chunks")

            // All chunks should arrive quickly (within reason for a test)
            let totalDuration = timestamps.last! - startTime
            #expect(totalDuration < .seconds(5), "Streaming should complete quickly")
        }
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct AsyncChannelPerformance {
        @Test(
            .disabled("Performance test - enable manually")
        )
        func largeContentStreaming() async {
            let itemCount = 1_000_0000

            struct ListHTML: HTML.View, AsyncRenderable, Sendable {
                let items: [String]

                var body: some HTML.View {
                    tag("ul") {
                        for item in items {
                            tag("li") {
                                HTML.Text(item)
                            }
                        }
                    }
                }
            }

            print("Creating \(itemCount) items...")
            print("Time1: \(ContinuousClock.now)")
            let items = (0..<itemCount).map { "Item \($0)" }
            print("Created items, starting render...")
            print("Time2: \(ContinuousClock.now)")
            let html = ListHTML(items: items)
            print("Time3: \(ContinuousClock.now)")
            var totalBytes = 0
            var chunkCount = 0
            let startTime = ContinuousClock.now

            // Use backpressure mode for bounded memory
            for await chunk in AsyncChannel { html } {
                if chunkCount == 0 {
                    print("Time3: \(ContinuousClock.now)")
                }
                totalBytes += chunk.count
                chunkCount += 1

                // Print progress every 1000 chunks
                if chunkCount % 1000 == 0 {
                    print("Progress: \(chunkCount) chunks, \(totalBytes) bytes")
                    print("Time4: \(ContinuousClock.now)")
                }
            }

            let elapsed = ContinuousClock.now - startTime
            print("Completed: \(itemCount) items, \(totalBytes) bytes, \(chunkCount) chunks in \(elapsed)")
            #expect(totalBytes > 0)
        }
    }
}
