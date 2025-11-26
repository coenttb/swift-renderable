//
//  Async Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting tests for async rendering, streaming, and concurrency.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Async Tests")
struct AsyncTests {

    // MARK: - Async Rendering Consistency

    @Test("Async and sync rendering produce same output")
    func asyncSyncConsistency() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    tag("h1") { HTMLText("Title") }
                    tag("p") { HTMLText("Content") }
                }
            }
        }

        let html = TestHTML()
        let syncResult = String(decoding: html.bytes, as: UTF8.self)
        let asyncResult = await html.asyncString()

        #expect(syncResult == asyncResult)
    }

    @Test("Async bytes matches sync bytes")
    func asyncBytesMatchSync() async {
        let html = tag("p") { HTMLText("Test content") }
        let syncBytes = html.bytes
        let asyncBytes = await html.asyncBytes()

        #expect(syncBytes == asyncBytes)
    }

    // MARK: - Concurrent Rendering

    @Test("Concurrent renders are isolated")
    func concurrentRendersIsolated() async throws {
        let results = await withTaskGroup(of: String.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let html = Document {
                        tag("div") {
                            HTMLText("Item \(i)")
                        }
                        .inlineStyle("order", "\(i)")
                    }
                    return (try? String(html)) ?? ""
                }
            }

            var collected: [String] = []
            for await result in group {
                collected.append(result)
            }
            return collected
        }

        #expect(results.count == 10)
        for result in results {
            #expect(result.contains("<div"))
        }
    }

    @Test("TaskLocal configuration isolation")
    func taskLocalIsolation() async {
        let results = await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                HTMLContext.Rendering.$current.withValue(.email) {
                    HTMLContext.Rendering.current.forceImportant
                }
            }
            group.addTask {
                HTMLContext.Rendering.$current.withValue(.default) {
                    HTMLContext.Rendering.current.forceImportant
                }
            }

            var bools: [Bool] = []
            for await result in group {
                bools.append(result)
            }
            return bools
        }

        // One should be true (.email), one should be false (.default)
        #expect(results.contains(true))
        #expect(results.contains(false))
    }

    // MARK: - Streaming Integration

    @Test("Async stream produces complete content")
    func asyncStreamComplete() async throws {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("ul") {
                    for i in 1...5 {
                        tag("li") { HTMLText("Item \(i)") }
                    }
                }
            }
        }

        let html = TestHTML()
        var allBytes: [UInt8] = []

        for try await chunk in AsyncThrowingStream(html, chunkSize: 50) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        for i in 1...5 {
            #expect(result.contains("Item \(i)"))
        }
    }

    @Test("Non-throwing stream produces complete content")
    func nonThrowingStreamComplete() async {
        struct TestHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText("Content")
                }
            }
        }

        let html = TestHTML()
        var allBytes: [UInt8] = []

        for await chunk in AsyncStream(html, chunkSize: 10) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("Content"))
    }

    // MARK: - Document Streaming

    @Test("Document async stream includes all parts")
    func documentAsyncStream() async throws {
        struct StyledMainHTML: HTML, Sendable {
            var body: some HTML {
                tag("main") {
                    HTMLText("Body content")
                }
                .inlineStyle("color", "blue")
            }
        }

        let document = Document {
            StyledMainHTML()
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(document: document, chunkSize: 100) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<style>"))
        #expect(result.contains("color:blue"))
        #expect(result.contains("Body content"))
    }

    // MARK: - Task Cancellation

    @Test("Stream handles task cancellation gracefully")
    func streamCancellation() async {
        struct LargeHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    for i in 0..<10000 {
                        tag("p") { HTMLText("Item \(i)") }
                    }
                }
            }
        }

        let html = LargeHTML()
        let task = Task {
            var chunks = 0
            for try await _ in AsyncThrowingStream(html, chunkSize: 100) {
                chunks += 1
                if chunks > 10 {
                    throw CancellationError()
                }
            }
        }

        _ = await task.result
        // Test passes if no crash/hang
        #expect(true)
    }

    // MARK: - Async with Styles

    @Test("Async rendering preserves styles")
    func asyncPreservesStyles() async throws {
        struct StyledHTML: HTML, Sendable {
            var body: some HTML {
                tag("div") {
                    HTMLText("Styled")
                }
                .inlineStyle("color", "red")
                .inlineStyle("font-size", "16px")
            }
        }

        let html = StyledHTML()
        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(html, chunkSize: 1024) {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("color"))
        #expect(result.contains("font-size"))
    }

    // MARK: - Async with Attributes

    @Test("Async rendering preserves attributes")
    func asyncPreservesAttributes() async {
        struct AttributedHTML: HTML, Sendable {
            var body: some HTML {
                tag("a") {
                    HTMLText("Link")
                }
                .attribute("href", "https://example.com")
                .attribute("class", "link")
            }
        }

        let html = AttributedHTML()
        let result = await html.asyncString()

        #expect(result.contains("href=\"https://example.com\""))
        #expect(result.contains("class=\"link\""))
    }

    // MARK: - Async Empty Content

    @Test("Async with empty content")
    func asyncEmptyContent() async {
        struct EmptyHTML: HTML, Sendable {
            var body: some HTML {
                Empty()
            }
        }

        let html = EmptyHTML()
        let result = await html.asyncBytes()

        #expect(result.isEmpty)
    }

    // MARK: - Multiple Async Operations

    @Test("Multiple sequential async operations")
    func multipleSequentialAsync() async throws {
        struct TestHTML: HTML, Sendable {
            let id: Int
            var body: some HTML {
                tag("div") { HTMLText("ID: \(id)") }
            }
        }

        for i in 1...5 {
            let html = TestHTML(id: i)
            let result = await html.asyncString()
            #expect(result.contains("ID: \(i)"))
        }
    }

    @Test("Parallel async rendering")
    func parallelAsyncRendering() async {
        let htmls = (1...10).map { i in
            tag("p") { HTMLText("Parallel \(i)") }
        }

        await withTaskGroup(of: (Int, String).self) { group in
            for (index, html) in htmls.enumerated() {
                group.addTask {
                    let result = await html.asyncString()
                    return (index, result)
                }
            }

            for await (index, result) in group {
                #expect(result.contains("Parallel \(index + 1)"))
            }
        }
    }
}
