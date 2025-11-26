//
//  Async Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//
//  Cross-cutting tests for async rendering, streaming, and concurrency.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Async Tests` {

    // MARK: - Async Rendering Consistency

    @Test
    func `Async and sync rendering produce same output`() async throws {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    tag("h1") { HTML.Text("Title") }
                    tag("p") { HTML.Text("Content") }
                }
            }
        }

        let html = TestHTML()
        let syncResult = String(decoding: html.bytes, as: UTF8.self)
        let asyncResult = await html.asyncString()

        #expect(syncResult == asyncResult)
    }

    @Test
    func `Async bytes matches sync bytes`() async {
        let html = tag("p") { HTML.Text("Test content") }
        let syncBytes = html.bytes
        let asyncBytes = await html.asyncBytes()

        #expect(syncBytes == asyncBytes)
    }

    // MARK: - Concurrent Rendering

    @Test
    func `Concurrent renders are isolated`() async throws {
        let results = await withTaskGroup(of: String.self) { group in
            for i in 0..<10 {
                group.addTask {
                    let html = HTML.Document {
                        tag("div") {
                            HTML.Text("Item \(i)")
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

    @Test
    func `TaskLocal configuration isolation`() async {
        let results = await withTaskGroup(of: Bool.self) { group in
            group.addTask {
                HTML.Context.Configuration.$current.withValue(.email) {
                    HTML.Context.Configuration.current.forceImportant
                }
            }
            group.addTask {
                HTML.Context.Configuration.$current.withValue(.default) {
                    HTML.Context.Configuration.current.forceImportant
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

    @Test
    func `Async stream produces complete content`() async throws {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("ul") {
                    for i in 1...5 {
                        tag("li") { HTML.Text("Item \(i)") }
                    }
                }
            }
        }

        let html = TestHTML()
        var allBytes: [UInt8] = []

        for try await chunk in AsyncThrowingStream(chunkSize: 50) { html } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        for i in 1...5 {
            #expect(result.contains("Item \(i)"))
        }
    }

    @Test
    func `Non-throwing stream produces complete content`() async {
        struct TestHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Content")
                }
            }
        }

        let html = TestHTML()
        var allBytes: [UInt8] = []

        for await chunk in AsyncStream(chunkSize: 10) { html } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("Content"))
    }

    // MARK: - Document Streaming

    @Test
    func `Document async stream includes all parts`() async throws {
        struct StyledMainHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("main") {
                    HTML.Text("Body content")
                }
                .inlineStyle("color", "blue")
            }
        }

        let document = HTML.Document {
            StyledMainHTML()
        }

        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 100) { document } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("<!doctype html>"))
        #expect(result.contains("<style>"))
        #expect(result.contains("color:blue"))
        #expect(result.contains("Body content"))
    }

    // MARK: - Task Cancellation

    @Test
    func `Stream handles task cancellation gracefully`() async {
        struct LargeHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    for i in 0..<10000 {
                        tag("p") { HTML.Text("Item \(i)") }
                    }
                }
            }
        }

        let html = LargeHTML()
        let task = Task {
            var chunks = 0
            for try await _ in AsyncThrowingStream(chunkSize: 100) { html } {
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

    @Test
    func `Async rendering preserves styles`() async throws {
        struct StyledHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("div") {
                    HTML.Text("Styled")
                }
                .inlineStyle("color", "red")
                .inlineStyle("font-size", "16px")
            }
        }

        let html = StyledHTML()
        var allBytes: [UInt8] = []
        for try await chunk in AsyncThrowingStream(chunkSize: 1024) { html } {
            allBytes.append(contentsOf: chunk)
        }

        let result = String(decoding: allBytes, as: UTF8.self)
        #expect(result.contains("color"))
        #expect(result.contains("font-size"))
    }

    // MARK: - Async with Attributes

    @Test
    func `Async rendering preserves attributes`() async {
        struct AttributedHTML: HTML.View, Sendable {
            var body: some HTML.View {
                tag("a") {
                    HTML.Text("Link")
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

    @Test
    func `Async with empty content`() async {
        struct EmptyHTML: HTML.View, Sendable {
            var body: some HTML.View {
                Empty()
            }
        }

        let html = EmptyHTML()
        let result = await html.asyncBytes()

        #expect(result.isEmpty)
    }

    // MARK: - Multiple Async Operations

    @Test
    func `Multiple sequential async operations`() async throws {
        struct TestHTML: HTML.View, Sendable {
            let id: Int
            var body: some HTML.View {
                tag("div") { HTML.Text("ID: \(id)") }
            }
        }

        for i in 1...5 {
            let html = TestHTML(id: i)
            let result = await html.asyncString()
            #expect(result.contains("ID: \(i)"))
        }
    }

    @Test
    func `Parallel async rendering`() async {
        let htmls = (1...10).map { i in
            tag("p") { HTML.Text("Parallel \(i)") }
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
