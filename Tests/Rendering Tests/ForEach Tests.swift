//
//  ForEach Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `ForEach Tests` {

    // MARK: - Basic Usage

    @Test
    func `ForEach iterates over array`() {
        let items = ["a", "b", "c"]
        let forEach = ForEach(items) { item in
            Raw(item)
        }
        #expect(forEach.content.value.count == 3)
        #expect(forEach.content.value[0].bytes == Array("a".utf8))
        #expect(forEach.content.value[1].bytes == Array("b".utf8))
        #expect(forEach.content.value[2].bytes == Array("c".utf8))
    }

    @Test
    func `ForEach with empty collection`() {
        let items: [String] = []
        let forEach = ForEach(items) { item in
            Raw(item)
        }
        #expect(forEach.content.value.isEmpty)
    }

    // MARK: - With Different Collection Types

    @Test
    func `ForEach with range`() {
        let forEach = ForEach(Array(1...3)) { num in
            Raw("\(num)")
        }
        #expect(forEach.content.value.count == 3)
        #expect(forEach.content.value[0].bytes == Array("1".utf8))
        #expect(forEach.content.value[1].bytes == Array("2".utf8))
        #expect(forEach.content.value[2].bytes == Array("3".utf8))
    }

    // MARK: - Sendable

    @Test
    func `ForEach is Sendable when content is Sendable`() {
        let forEach = ForEach(["test"]) { Raw($0) }
        Task {
            _ = forEach.content
        }
        #expect(true) // Compile-time check
    }
}
