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
            TestElement(id: item)
        }
        #expect(forEach.content.elements.count == 3)
        #expect(forEach.content.elements[0].id == "a")
        #expect(forEach.content.elements[1].id == "b")
        #expect(forEach.content.elements[2].id == "c")
    }

    @Test
    func `ForEach with empty collection`() {
        let items: [String] = []
        let forEach = ForEach(items) { item in
            TestElement(id: item)
        }
        #expect(forEach.content.elements.isEmpty)
    }

    // MARK: - With Different Collection Types

    @Test
    func `ForEach with range`() {
        let forEach = ForEach(1...3) { num in
            TestElement(id: "\(num)")
        }
        #expect(forEach.content.elements.count == 3)
        #expect(forEach.content.elements[0].id == "1")
        #expect(forEach.content.elements[1].id == "2")
        #expect(forEach.content.elements[2].id == "3")
    }

    // MARK: - Content Access

    @Test
    func `ForEach content returns _Array`() {
        let forEach = ForEach(["x"]) { item in
            TestElement(id: item)
        }
        #expect(forEach.content.elements.count == 1)
    }

    // MARK: - Sendable

    @Test
    func `ForEach is Sendable when content is Sendable`() {
        let forEach = ForEach(["test"]) { item in
            TestElement(id: item)
        }
        Task {
            _ = forEach.content
        }
        #expect(Bool(true)) // Compile-time check
    }
}

// MARK: - Test Helpers

private struct TestElement: Rendering, Sendable {
    let id: String
    typealias Context = Void
    typealias Content = Never

    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}
