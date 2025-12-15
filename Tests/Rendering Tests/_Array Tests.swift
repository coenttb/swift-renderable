//
//  _Array Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing

@testable import Rendering

@Suite
struct `_Array Tests` {

    // MARK: - Initialization

    @Test
    func `_Array can be created with elements`() {
        let array = Rendering._Array([TestRenderable("a"), TestRenderable("b")])
        #expect(array.elements.count == 2)
    }

    @Test
    func `_Array can be empty`() {
        let array = Rendering._Array<TestRenderable>([])
        #expect(array.elements.isEmpty)
    }

    @Test
    func `elements property returns underlying array`() {
        let elements = [TestRenderable("x"), TestRenderable("y"), TestRenderable("z")]
        let array = Rendering._Array(elements)
        #expect(array.elements.count == 3)
        #expect(array.elements[0].value == "x")
        #expect(array.elements[1].value == "y")
        #expect(array.elements[2].value == "z")
    }

    // MARK: - Rendering

    @Test
    func `renders all elements in order`() {
        let array = Rendering._Array([
            TestRenderable("one"),
            TestRenderable("two"),
            TestRenderable("three"),
        ])
        let result = render(array)
        #expect(result == "onetwothree")
    }

    @Test
    func `renders empty array as empty string`() {
        let array = Rendering._Array<TestRenderable>([])
        let result = render(array)
        #expect(result.isEmpty)
    }

    @Test
    func `renders single element`() {
        let array = Rendering._Array([TestRenderable("only")])
        let result = render(array)
        #expect(result == "only")
    }

    @Test(arguments: [1, 5, 10, 50, 100])
    func `renders many elements`(count: Int) {
        let elements = (0..<count).map { TestRenderable("\($0)") }
        let array = Rendering._Array(elements)
        let result = render(array)
        let expected = (0..<count).map { "\($0)" }.joined()
        #expect(result == expected)
    }

    // MARK: - Protocol Conformance

    @Test
    func `_Array conforms to Rendering.Protocol when Element does`() {
        let array = Rendering._Array([TestRenderable("test")])
        let _: any Rendering.`Protocol` = array
        #expect(Bool(true))
    }

    @Test
    func `body property is Never`() {
        let array = Rendering._Array([TestRenderable("test")])
        _ = type(of: array).Content.self
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test
    func `_Array is Equatable when Element is Equatable`() {
        let a = Rendering._Array([TestRenderable("x"), TestRenderable("y")])
        let b = Rendering._Array([TestRenderable("x"), TestRenderable("y")])
        let c = Rendering._Array([TestRenderable("x"), TestRenderable("z")])
        let d = Rendering._Array([TestRenderable("x")])

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test
    func `empty arrays are equal`() {
        let a = Rendering._Array<TestRenderable>([])
        let b = Rendering._Array<TestRenderable>([])
        #expect(a == b)
    }

    // MARK: - Hashable

    @Test
    func `_Array is Hashable when Element is Hashable`() {
        let a = Rendering._Array([TestRenderable("x")])
        let b = Rendering._Array([TestRenderable("x")])

        var set: Set<Rendering._Array<TestRenderable>> = []
        set.insert(a)

        #expect(set.contains(b))
        #expect(set.count == 1)
    }

    // MARK: - Sendable

    @Test
    func `_Array is Sendable when Element is Sendable`() {
        let array = Rendering._Array([TestRenderable("test")])
        Task {
            _ = array.elements
        }
        #expect(Bool(true))
    }

    // MARK: - Codable

    @Test
    func `_Array is Codable when Element is Codable`() throws {
        let original = Rendering._Array([TestRenderable("a"), TestRenderable("b")])

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering._Array<TestRenderable>.self, from: data)

        #expect(original == decoded)
    }

    @Test
    func `Codable round-trip preserves order`() throws {
        let original = Rendering._Array([
            TestRenderable("first"),
            TestRenderable("second"),
            TestRenderable("third"),
        ])

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering._Array<TestRenderable>.self, from: data)

        #expect(decoded.elements[0].value == "first")
        #expect(decoded.elements[1].value == "second")
        #expect(decoded.elements[2].value == "third")
    }

    // MARK: - Typealias

    @Test
    func `_Array typealias works`() {
        let array: _Array<TestRenderable> = _Array([TestRenderable("alias")])
        #expect(render(array) == "alias")
    }

    // MARK: - Context Propagation

    @Test
    func `context is passed to each element`() {
        let array = Rendering._Array([
            ContextualRenderable("a"),
            ContextualRenderable("b"),
            ContextualRenderable("c"),
        ])
        var context = TestContext()
        let result = render(array, context: &context)

        #expect(result == "a1b2c3")
        #expect(context.renderCount == 3)
    }

    // MARK: - Nested Arrays

    @Test
    func `nested arrays render correctly`() {
        let inner1 = Rendering._Array([TestRenderable("a"), TestRenderable("b")])
        let inner2 = Rendering._Array([TestRenderable("c"), TestRenderable("d")])
        let outer = Rendering._Array([inner1, inner2])

        let result = render(outer)
        #expect(result == "abcd")
    }
}
