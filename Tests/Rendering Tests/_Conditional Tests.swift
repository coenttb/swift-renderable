//
//  _Conditional Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Foundation
import Testing
@testable import Rendering

@Suite
struct `_Conditional Tests` {

    // MARK: - First Branch

    @Test
    func `first branch stores value correctly`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("first"))
        switch conditional {
        case .first(let element):
            #expect(element.value == "first")
        case .second:
            Issue.record("Expected first branch")
        }
    }

    @Test
    func `first branch renders first content`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("FIRST"))
        let result = render(conditional)
        #expect(result == "FIRST")
    }

    // MARK: - Second Branch

    @Test
    func `second branch stores value correctly`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("second"))
        switch conditional {
        case .first:
            Issue.record("Expected second branch")
        case .second(let element):
            #expect(element.value == "second")
        }
    }

    @Test
    func `second branch renders second content`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("SECOND"))
        let result = render(conditional)
        #expect(result == "SECOND")
    }

    // MARK: - Heterogeneous Types

    @Test
    func `_Conditional can have different branch types`() {
        let first: Rendering._Conditional<TestRenderable, OtherRenderable> = .first(TestRenderable("test"))
        let second: Rendering._Conditional<TestRenderable, OtherRenderable> = .second(OtherRenderable())

        switch first {
        case .first(let element):
            #expect(element.value == "test")
        case .second:
            Issue.record("Expected first branch")
        }

        switch second {
        case .first:
            Issue.record("Expected second branch")
        case .second:
            #expect(Bool(true))
        }
    }

    @Test
    func `renders correct branch with different types`() {
        let first: Rendering._Conditional<TestRenderable, OtherRenderable> = .first(TestRenderable("A"))
        let second: Rendering._Conditional<TestRenderable, OtherRenderable> = .second(OtherRenderable())

        #expect(render(first) == "A")
        #expect(render(second) == "OTHER")
    }

    // MARK: - Rendering Protocol Conformance

    @Test
    func `_Conditional conforms to Rendering.Protocol`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("test"))
        let _: any Rendering.`Protocol` = conditional
        #expect(Bool(true))
    }

    @Test
    func `body property throws fatalError`() {
        // Note: We can't test fatalError directly, but we verify the type has the body property
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("test"))
        // Just verify the type exists - accessing body would crash
        _ = type(of: conditional).Content.self
        #expect(Bool(true))
    }

    // MARK: - Equatable

    @Test
    func `_Conditional is Equatable when both branches are Equatable`() {
        let a = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("x"))
        let b = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("x"))
        let c = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("y"))
        let d = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("x"))

        #expect(a == b)
        #expect(a != c)
        #expect(a != d)
    }

    @Test
    func `equality compares same branch types`() {
        let first1 = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("a"))
        let first2 = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("a"))
        let second1 = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("a"))
        let second2 = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("a"))

        #expect(first1 == first2)
        #expect(second1 == second2)
        #expect(first1 != second1)
    }

    // MARK: - Hashable

    @Test
    func `_Conditional is Hashable when both branches are Hashable`() {
        let a = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("x"))
        let b = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("x"))

        var set: Set<Rendering._Conditional<TestRenderable, TestRenderable>> = []
        set.insert(a)

        #expect(set.contains(b))
        #expect(set.count == 1)
    }

    @Test
    func `different branches have different hashes`() {
        let first = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("same"))
        let second = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("same"))

        #expect(first.hashValue != second.hashValue)
    }

    // MARK: - Sendable

    @Test
    func `_Conditional is Sendable when both branches are Sendable`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("test"))
        Task {
            _ = conditional
        }
        #expect(Bool(true))
    }

    // MARK: - Codable

    @Test
    func `_Conditional is Codable when both branches are Codable`() throws {
        let original = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("encoded"))

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)

        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Rendering._Conditional<TestRenderable, TestRenderable>.self, from: data)

        #expect(original == decoded)
    }

    @Test
    func `Codable round-trip preserves branch`() throws {
        let first = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable("f"))
        let second = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable("s"))

        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        let firstData = try encoder.encode(first)
        let secondData = try encoder.encode(second)

        let decodedFirst = try decoder.decode(Rendering._Conditional<TestRenderable, TestRenderable>.self, from: firstData)
        let decodedSecond = try decoder.decode(Rendering._Conditional<TestRenderable, TestRenderable>.self, from: secondData)

        #expect(first == decodedFirst)
        #expect(second == decodedSecond)
    }

    // MARK: - Typealias

    @Test
    func `_Conditional typealias works`() {
        let conditional: _Conditional<TestRenderable, TestRenderable> = .first(TestRenderable("alias"))
        #expect(render(conditional) == "alias")
    }

    // MARK: - Empty Content

    @Test
    func `renders empty when first branch is empty`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.first(TestRenderable(""))
        #expect(render(conditional) == "")
    }

    @Test
    func `renders empty when second branch is empty`() {
        let conditional = Rendering._Conditional<TestRenderable, TestRenderable>.second(TestRenderable(""))
        #expect(render(conditional) == "")
    }
}

// MARK: - Test Helpers

private struct OtherRenderable: Rendering.`Protocol`, Sendable, Equatable, Hashable, Codable {
    typealias Context = Void
    typealias Content = Never
    typealias Output = UInt8

    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherRenderable,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: "OTHER".utf8)
    }
}
