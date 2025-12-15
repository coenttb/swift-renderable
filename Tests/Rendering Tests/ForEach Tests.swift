//
//  ForEach Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing

@testable import Rendering

@Suite
struct `ForEach Tests` {

    // MARK: - Basic Iteration

    @Test
    func `ForEach iterates over array`() {
        let items = ["a", "b", "c"]
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }

        let result = render(forEach)
        #expect(result == "abc")
    }

    @Test
    func `ForEach with empty collection renders nothing`() {
        let items: [String] = []
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }

        let result = render(forEach)
        #expect(result.isEmpty)
    }

    @Test
    func `ForEach with single element`() {
        let items = ["only"]
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }

        let result = render(forEach)
        #expect(result == "only")
    }

    // MARK: - Collection Types

    @Test
    func `ForEach works with Array`() {
        let array = [1, 2, 3]
        let forEach = Rendering.ForEach(array) { num in
            TestRenderable("\(num)")
        }

        let result = render(forEach)
        #expect(result == "123")
    }

    @Test
    func `ForEach works with Range`() {
        let forEach = Rendering.ForEach(1...5) { num in
            TestRenderable("\(num)")
        }

        let result = render(forEach)
        #expect(result == "12345")
    }

    @Test
    func `ForEach works with ArraySlice`() {
        let array = [1, 2, 3, 4, 5]
        let slice = array[1...3]
        let forEach = Rendering.ForEach(slice) { num in
            TestRenderable("\(num)")
        }

        let result = render(forEach)
        #expect(result == "234")
    }

    // MARK: - Content Property

    @Test
    func `content property returns _Array`() {
        let items = ["x", "y"]
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }

        #expect(forEach.content.elements.count == 2)
    }

    @Test
    func `body property returns content`() {
        let items = ["test"]
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }

        #expect(forEach.body.elements.count == 1)
    }

    // MARK: - Protocol Conformance

    @Test
    func `ForEach conforms to Rendering.Protocol`() {
        let forEach = Rendering.ForEach(["a"]) { item in
            TestRenderable(item)
        }
        let _: any Rendering.`Protocol` = forEach
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test
    func `ForEach is Equatable when Content is Equatable`() {
        let forEach1 = Rendering.ForEach(["a", "b"]) { TestRenderable($0) }
        let forEach2 = Rendering.ForEach(["a", "b"]) { TestRenderable($0) }
        let forEach3 = Rendering.ForEach(["a", "c"]) { TestRenderable($0) }

        #expect(forEach1 == forEach2)
        #expect(forEach1 != forEach3)
    }

    // MARK: - Hashable

    @Test
    func `ForEach is Hashable when Content is Hashable`() {
        let forEach1 = Rendering.ForEach(["x"]) { TestRenderable($0) }
        let forEach2 = Rendering.ForEach(["x"]) { TestRenderable($0) }

        var set: Set<Rendering.ForEach<TestRenderable>> = []
        set.insert(forEach1)

        #expect(set.contains(forEach2))
    }

    // MARK: - Sendable

    @Test
    func `ForEach is Sendable when Content is Sendable`() {
        let forEach = Rendering.ForEach(["test"]) { item in
            TestRenderable(item)
        }
        Task {
            _ = forEach.content
        }
        #expect(Bool(true))
    }

    // MARK: - Codable

    @Test
    func `ForEach is Codable when Content is Codable`() throws {
        let original = Rendering.ForEach(["a", "b"]) { TestRenderable($0) }

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering.ForEach<TestRenderable>.self, from: data)

        #expect(original == decoded)
    }

    // MARK: - Typealias

    @Test
    func `ForEach typealias works`() {
        let forEach: ForEach<TestRenderable> = ForEach(["alias"]) { TestRenderable($0) }
        #expect(render(forEach) == "alias")
    }

    // MARK: - Transform Function

    @Test
    func `transform function receives correct elements`() {
        var received: [Int] = []
        let forEach = Rendering.ForEach([1, 2, 3]) { num in
            received.append(num)
            return TestRenderable("\(num)")
        }

        _ = render(forEach)
        #expect(received == [1, 2, 3])
    }

    @Test
    func `transform can access element index via enumerated`() {
        let items = ["a", "b", "c"]
        let forEach = Rendering.ForEach(Array(items.enumerated())) { index, item in
            TestRenderable("\(index):\(item)")
        }

        let result = render(forEach)
        #expect(result == "0:a1:b2:c")
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to each iteration`() {
        let items = ["x", "y", "z"]
        let forEach = Rendering.ForEach(items) { item in
            ContextualRenderable(item)
        }

        var context = TestContext()
        let result = render(forEach, context: &context)

        #expect(result == "x1y2z3")
        #expect(context.renderCount == 3)
    }

    // MARK: - Parameterized Tests

    @Test(arguments: [0, 1, 5, 10, 50])
    func `ForEach handles various collection sizes`(count: Int) {
        let items = (0..<count).map { "\($0)" }
        let forEach = Rendering.ForEach(items) { TestRenderable($0) }

        let result = render(forEach)
        let expected = items.joined()
        #expect(result == expected)
    }

    // MARK: - Nested ForEach

    @Test
    func `nested ForEach renders correctly`() {
        let outer = [[1, 2], [3, 4]]
        let forEach = Rendering.ForEach(outer) { inner in
            Rendering.ForEach(inner) { num in
                TestRenderable("\(num)")
            }
        }

        let result = render(forEach)
        #expect(result == "1234")
    }
}
