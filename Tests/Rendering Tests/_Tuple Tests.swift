//
//  _Tuple Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering

@Suite
struct `_Tuple Tests` {

    // MARK: - Initialization

    @Test
    func `_Tuple can be created with two elements`() {
        let tuple = Rendering._Tuple(TestRenderable("a"), TestRenderable("b"))
        #expect(tuple.content.0.value == "a")
        #expect(tuple.content.1.value == "b")
    }

    @Test
    func `_Tuple can be created with three elements`() {
        let tuple = Rendering._Tuple(
            TestRenderable("a"),
            TestRenderable("b"),
            TestRenderable("c")
        )
        #expect(tuple.content.0.value == "a")
        #expect(tuple.content.1.value == "b")
        #expect(tuple.content.2.value == "c")
    }

    @Test
    func `_Tuple can be created with four elements`() {
        let tuple = Rendering._Tuple(
            TestRenderable("a"),
            TestRenderable("b"),
            TestRenderable("c"),
            TestRenderable("d")
        )
        #expect(tuple.content.0.value == "a")
        #expect(tuple.content.1.value == "b")
        #expect(tuple.content.2.value == "c")
        #expect(tuple.content.3.value == "d")
    }

    @Test
    func `_Tuple can be created with five elements`() {
        let tuple = Rendering._Tuple(
            TestRenderable("1"),
            TestRenderable("2"),
            TestRenderable("3"),
            TestRenderable("4"),
            TestRenderable("5")
        )
        #expect(tuple.content.0.value == "1")
        #expect(tuple.content.4.value == "5")
    }

    // MARK: - Mixed Types

    @Test
    func `_Tuple can hold mixed renderable types`() {
        let tuple = Rendering._Tuple(
            TestRenderable("test"),
            OtherRenderable()
        )
        #expect(tuple.content.0.value == "test")
        // OtherRenderable has no value property but exists
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `_Tuple is Sendable when all elements are Sendable`() {
        let tuple = Rendering._Tuple(
            TestRenderable("a"),
            TestRenderable("b")
        )
        Task {
            _ = tuple.content
        }
        #expect(Bool(true))
    }

    // MARK: - Typealias

    @Test
    func `_Tuple typealias works`() {
        let tuple: _Tuple<TestRenderable, TestRenderable> = _Tuple(
            TestRenderable("x"),
            TestRenderable("y")
        )
        #expect(tuple.content.0.value == "x")
        #expect(tuple.content.1.value == "y")
    }

    // MARK: - Content Property

    @Test
    func `content property returns tuple of elements`() {
        let tuple = Rendering._Tuple(
            TestRenderable("first"),
            TestRenderable("second"),
            TestRenderable("third")
        )

        let (a, b, c) = tuple.content
        #expect(a.value == "first")
        #expect(b.value == "second")
        #expect(c.value == "third")
    }

    // Note: Single element tuples are not idiomatic for _Tuple usage.
    // The builder passes single elements through directly via buildBlock.

    // MARK: - Empty Content

    @Test
    func `_Tuple elements can have empty content`() {
        let tuple = Rendering._Tuple(
            TestRenderable(""),
            TestRenderable(""),
            TestRenderable("")
        )
        #expect(tuple.content.0.value == "")
        #expect(tuple.content.1.value == "")
        #expect(tuple.content.2.value == "")
    }

    // MARK: - Nested Tuples

    @Test
    func `_Tuple can contain nested tuples`() {
        let inner = Rendering._Tuple(TestRenderable("a"), TestRenderable("b"))
        let outer = Rendering._Tuple(inner, TestRenderable("c"))

        #expect(outer.content.0.content.0.value == "a")
        #expect(outer.content.0.content.1.value == "b")
        #expect(outer.content.1.value == "c")
    }
}

// MARK: - Test Helpers

private struct OtherRenderable: Rendering.`Protocol`, Sendable {
    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    var body: Never { fatalError() }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherRenderable,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: "OTHER".utf8)
    }
}
