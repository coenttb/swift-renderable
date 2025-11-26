//
//  AsyncThrowingStream Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Foundation
@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AsyncThrowingStream Tests` {

    // MARK: - Basic Streaming

    @Test
    func `AsyncThrowingStream streams HTML content`() async throws {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Hello, World!")
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { TestHTML() } {
            chunks.append(chunk)
        }

        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Hello, World!"))
    }

    @Test
    func `AsyncThrowingStream yields complete content`() async throws {
        struct MultiParagraphHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Group {
                    tag("p") { HTML.Text("First") }
                    tag("p") { HTML.Text("Second") }
                    tag("p") { HTML.Text("Third") }
                }
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { MultiParagraphHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("First"))
        #expect(result.contains("Second"))
        #expect(result.contains("Third"))
    }

    // MARK: - Chunk Size

    @Test
    func `AsyncThrowingStream respects chunk size`() async throws {
        struct LongContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 1000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 100) { LongContentHTML() } {
            chunks.append(chunk)
            // Each chunk should be at most 100 bytes
            #expect(chunk.count <= 100)
        }

        // Should have multiple chunks
        #expect(chunks.count > 1)
    }

    @Test
    func `AsyncThrowingStream with default chunk size`() async throws {
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        var chunkCount = 0
        for try await _ in AsyncThrowingStream { SimpleHTML() } {
            chunkCount += 1
        }

        // Small content should be in one chunk with default size of 4096
        #expect(chunkCount >= 1)
    }

    // MARK: - Configuration

    @Test
    func `AsyncThrowingStream with custom configuration`() async throws {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
                .inlineStyle("color", "red")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(configuration: .email) { HTML.Document { StyledHTML() } } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("!important"))
    }

    @Test
    func `AsyncThrowingStream with nil configuration uses default`() async throws {
        struct SpanHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("span") {
                    HTML.Text("Test")
                }
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(configuration: nil) { SpanHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<span>"))
    }

    // MARK: - Document Streaming

    @Test
    func `AsyncThrowingStream streams HTML document`() async throws {
        let document = HTML.Document {
            tag("main") {
                HTML.Text("Main content")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { document } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("Main content"))
    }

    @Test
    func `AsyncThrowingStream document with styles`() async throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Styled")
            }
            .inlineStyle("color", "blue")
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { document } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<style>"))
        #expect(result.contains("color:blue"))
    }

    // MARK: - Empty Content

    @Test
    func `AsyncThrowingStream with empty content`() async throws {
        struct EmptyHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { EmptyHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        #expect(allBytes.isEmpty)
    }

    // MARK: - Complex Content

    @Test
    func `AsyncThrowingStream with nested elements`() async throws {
        struct NestedHTML: HTML.View, Sendable {
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
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { NestedHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<ul>"))
        #expect(result.contains("<li>"))
        #expect(result.contains("Item 1"))
        #expect(result.contains("Item 2"))
    }

    @Test
    func `AsyncThrowingStream with attributes`() async throws {
        struct AttributedHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("a") {
                    HTML.Text("Click me")
                }
                .attribute("href", "https://example.com")
                .attribute("class", "link")
            }
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 4096) { AttributedHTML() } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("href=\"https://example.com\""))
        #expect(result.contains("class=\"link\""))
    }

    // MARK: - Task Cancellation

    @Test
    func `AsyncThrowingStream handles cancellation`() async {
        struct LongContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "x", count: 100_000))
                }
            }
        }

        let task = Task {
            var count = 0
            for try await _ in AsyncThrowingStream(chunkSize: 100) { LongContentHTML() } {
                count += 1
                if count > 5 {
                    throw CancellationError()
                }
            }
        }

        // Allow the task to start
        await Task.yield()
        task.cancel()

        // The task should complete (either by cancellation or finishing)
        _ = await task.result
        #expect(true) // Task completed without hanging
    }
}

// MARK: - Cancellation Tests

@Suite
struct `AsyncThrowingStream Cancellation Tests` {

    /// Actor to safely track state across Task boundaries
    actor CancellationTestState {
        var chunksReceived = 0
        var wasCancelled = false
        var didComplete = false

        func incrementChunks() { chunksReceived += 1 }
        func markCancelled() { wasCancelled = true }
        func markCompleted() { didComplete = true }

        func getChunksReceived() -> Int { chunksReceived }
        func getWasCancelled() -> Bool { wasCancelled }
        func getDidComplete() -> Bool { didComplete }
    }

    @Test
    func `Consumer can stop iteration early by throwing`() async {
        // Note: In buffered mode, the content is rendered synchronously first,
        // then streamed. Cancellation during the streaming phase is tested here.
        struct LargeHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "x", count: 100_000))
                }
            }
        }

        var chunksReceived = 0
        let stopAfter = 5

        do {
            for try await _ in AsyncThrowingStream(chunkSize: 100) { LargeHTML() } {
                chunksReceived += 1
                if chunksReceived >= stopAfter {
                    throw CancellationError()
                }
            }
            #expect(Bool(false), "Should have thrown")
        } catch is CancellationError {
            #expect(chunksReceived == stopAfter, "Should stop at specified chunk count")
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test
    func `Cancellation during chunk iteration stops cleanly`() async {
        struct ContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("ul") {
                    for i in 0..<1000 {
                        tag("li") { HTML.Text("Item \(i)") }
                    }
                }
            }
        }

        var receivedChunks = 0
        let maxChunksToReceive = 5

        do {
            for try await _ in AsyncThrowingStream(chunkSize: 50) { ContentHTML() } {
                receivedChunks += 1
                if receivedChunks >= maxChunksToReceive {
                    throw CancellationError()
                }
            }
            #expect(Bool(false), "Should have thrown")
        } catch is CancellationError {
            #expect(receivedChunks == maxChunksToReceive, "Should stop at specified chunk count")
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test
    func `Task completes normally even after cancel is called`() async {
        // Note: In buffered mode, content renders synchronously before streaming.
        // By the time we call cancel, the task may have already completed.
        // This test verifies graceful handling of that scenario.
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "x", count: 1000))
                }
            }
        }

        let state = CancellationTestState()
        let taskStarted = AsyncStream.makeStream(of: Void.self)

        let task = Task {
            taskStarted.continuation.yield()
            do {
                for try await _ in AsyncThrowingStream(chunkSize: 100) { SimpleHTML() } {
                    await Task.yield()
                }
            } catch is CancellationError {
                // Expected if cancelled
            }
            await state.markCompleted()
        }

        // Wait for task to start
        for await _ in taskStarted.stream {
            break
        }

        // Cancel the task (may or may not have effect depending on timing)
        task.cancel()

        // Wait for completion
        _ = await task.result

        // Task should complete one way or another
        let completed = await state.getDidComplete()
        #expect(completed, "Task should complete after cancellation")
    }

    @Test
    func `Streaming mode handles early termination gracefully`() async {
        struct StreamHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "stream", count: 50_000))
                }
            }
        }

        var totalBytes = 0

        do {
            for try await chunk in AsyncThrowingStream(mode: .streaming, chunkSize: 100) { StreamHTML() } {
                totalBytes += chunk.count
                if totalBytes > 1000 {
                    throw CancellationError()
                }
            }
        } catch is CancellationError {
            #expect(totalBytes > 1000, "Should have accumulated bytes before cancellation")
        } catch {
            #expect(Bool(false), "Unexpected error: \(error)")
        }
    }

    @Test
    func `Breaking out of iteration works`() async throws {
        struct ContentHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 10_000))
                }
            }
        }

        var chunksReceived = 0

        for try await _ in AsyncThrowingStream(chunkSize: 100) { ContentHTML() } {
            chunksReceived += 1
            if chunksReceived >= 3 {
                break
            }
        }

        #expect(chunksReceived == 3, "Should receive exactly 3 chunks before break")
    }
}

// MARK: - Progressive Streaming Tests

@Suite
struct `Progressive Streaming Tests` {

    @Test
    func `Progressive stream yields chunks during rendering`() async throws {
        struct LargeHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text(String(repeating: "a", count: 10_000))
                }
            }
        }

        var chunks: [ArraySlice<UInt8>] = []
        for try await chunk in AsyncThrowingStream(mode: .streaming, chunkSize: 1000) { LargeHTML() } {
            chunks.append(chunk)
        }

        // Should have multiple chunks due to small chunk size
        #expect(chunks.count > 1)

        // Verify complete content
        let result = String(decoding: chunks.flatMap { $0 }, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("</div>"))
    }

    @Test
    func `Progressive document stream puts styles at end of body`() async throws {
        let document = HTML.Document {
            tag("div") {
                HTML.Text("Content")
            }
            .inlineStyle("color", "red")
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(mode: .streaming, chunkSize: 4096) { document } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)

        // Should have complete document structure
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<html>"))
        #expect(result.contains("<head>"))
        #expect(result.contains("<body>"))
        #expect(result.contains("Content"))

        // Style should be present (at end of body)
        #expect(result.contains("<style>"))
        #expect(result.contains("color:red"))

        // Verify style comes after content (styles at end of body)
        if let contentIndex = result.range(of: "Content"),
           let styleIndex = result.range(of: "<style>") {
            #expect(contentIndex.lowerBound < styleIndex.lowerBound)
        }
    }

    @Test
    func `Progressive fragment stream convenience method`() async throws {
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("p") { HTML.Text("Hello") }
            }
        }

        let html = SimpleHTML()
        var allBytes: [UInt8] = []
        for try await chunk in html.asyncThrowingStream(mode: .streaming, chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<p>"))
        #expect(result.contains("Hello"))
    }

    @Test
    func `Progressive document stream convenience method`() async throws {
        let document = HTML.Document {
            tag("main") { HTML.Text("Main") }
        }

        var allBytes: [UInt8] = []
        for try await chunk in document.asyncThrowingStream(mode: .streaming, chunkSize: 4096) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<main>"))
        #expect(result.contains("Main"))
    }

    @Test
    func `Non-throwing progressive stream`() async {
        struct SimpleHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") { HTML.Text("Test") }
            }
        }

        var allBytes: [UInt8] = []
        for await chunk in AsyncStream(chunkSize: 4096, SimpleHTML.init) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<div>"))
        #expect(result.contains("Test"))
    }
}

// MARK: - Performance Tests

extension `Performance Tests` {
    @Suite
    struct AsyncThrowingStreamPerformance {
        @Test(.disabled("Performance test - enable manually"))
        func largeContentStreaming() async throws {
            struct ListHTML: HTML.View, Sendable {
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

            let items = (0..<1000).map { "Item \($0)" }
            let html = ListHTML(items: items)

            var totalBytes = 0
            for try await chunk in AsyncThrowingStream(chunkSize: 4096) { html } {
                totalBytes += chunk.count
            }

            #expect(totalBytes > 0)
        }
    }
}
