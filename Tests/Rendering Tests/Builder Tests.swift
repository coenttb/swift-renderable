//
//  Builder Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Rendering

@Suite
struct `Builder Tests` {

    // MARK: - Builder Existence

    @Test
    func `Builder type exists`() {
        let _: Rendering.Builder.Type = Rendering.Builder.self
        #expect(Bool(true))
    }

    @Test
    func `Builder typealias works`() {
        let _: Builder.Type = Builder.self
        #expect(Bool(true))
    }

    // MARK: - buildBlock

    @Test
    func `buildBlock with single element passes through`() {
        let result = Rendering.Builder.buildBlock(TestRenderable("single"))
        #expect(result.value == "single")
    }

    @Test
    func `buildBlock with two elements creates tuple`() {
        let result = Rendering.Builder.buildBlock(
            TestRenderable("a"),
            TestRenderable("b")
        )
        #expect(result.content.0.value == "a")
        #expect(result.content.1.value == "b")
    }

    @Test
    func `buildBlock with three elements creates tuple`() {
        let result = Rendering.Builder.buildBlock(
            TestRenderable("1"),
            TestRenderable("2"),
            TestRenderable("3")
        )
        #expect(result.content.0.value == "1")
        #expect(result.content.1.value == "2")
        #expect(result.content.2.value == "3")
    }

    // MARK: - buildArray

    @Test
    func `buildArray creates _Array from array`() {
        let elements = [TestRenderable("x"), TestRenderable("y")]
        let result = Rendering.Builder.buildArray(elements)
        #expect(result.elements.count == 2)
        #expect(result.elements[0].value == "x")
        #expect(result.elements[1].value == "y")
    }

    @Test
    func `buildArray with empty array creates empty _Array`() {
        let result = Rendering.Builder.buildArray([TestRenderable]())
        #expect(result.elements.isEmpty)
    }

    // MARK: - buildEither (first)

    @Test
    func `buildEither first creates first branch`() {
        let result: Rendering._Conditional<TestRenderable, TestRenderable> =
            Rendering.Builder.buildEither(first: TestRenderable("first"))

        switch result {
        case .first(let element):
            #expect(element.value == "first")
        case .second:
            Issue.record("Expected first branch")
        }
    }

    // MARK: - buildEither (second)

    @Test
    func `buildEither second creates second branch`() {
        let result: Rendering._Conditional<TestRenderable, TestRenderable> =
            Rendering.Builder.buildEither(second: TestRenderable("second"))

        switch result {
        case .first:
            Issue.record("Expected second branch")
        case .second(let element):
            #expect(element.value == "second")
        }
    }

    // MARK: - buildExpression

    @Test
    func `buildExpression passes through value`() {
        let result = Rendering.Builder.buildExpression(TestRenderable("expr"))
        #expect(result.value == "expr")
    }

    @Test
    func `buildExpression works with different types`() {
        let intResult = Rendering.Builder.buildExpression(42)
        let stringResult = Rendering.Builder.buildExpression("test")

        #expect(intResult == 42)
        #expect(stringResult == "test")
    }

    // MARK: - buildOptional

    @Test
    func `buildOptional with some value returns value`() {
        let result = Rendering.Builder.buildOptional(TestRenderable("present"))
        #expect(result?.value == "present")
    }

    @Test
    func `buildOptional with nil returns nil`() {
        let result = Rendering.Builder.buildOptional(nil as TestRenderable?)
        #expect(result == nil)
    }

    // MARK: - buildFinalResult

    @Test
    func `buildFinalResult passes through value`() {
        let result = Rendering.Builder.buildFinalResult(TestRenderable("final"))
        #expect(result.value == "final")
    }

    // MARK: - Integration: Group with Builder

    // Note: Tests for Group with multiple items require _Tuple to conform to Rendering.Protocol,
    // which is provided by domain-specific modules (e.g., HTML rendering).
    // The base Rendering module tests Builder structure only.

    @Test
    func `Group with single item`() {
        let group = Rendering.Group {
            TestRenderable("single")
        }
        let result = render(group)
        #expect(result == "single")
    }

    // MARK: - Integration: Conditionals

    @Test
    func `Builder handles if-else`() {
        let condition = true
        let group = Rendering.Group {
            if condition {
                TestRenderable("if")
            } else {
                TestRenderable("else")
            }
        }
        let result = render(group)
        #expect(result == "if")
    }

    @Test
    func `Builder handles else branch`() {
        let condition = false
        let group = Rendering.Group {
            if condition {
                TestRenderable("if")
            } else {
                TestRenderable("else")
            }
        }
        let result = render(group)
        #expect(result == "else")
    }

    // MARK: - Integration: Optional Binding

    @Test
    func `Builder handles if-let with some`() {
        let maybeValue: String? = "unwrapped"
        let group = Rendering.Group {
            if let value = maybeValue {
                TestRenderable(value)
            }
        }
        let result = render(group)
        #expect(result == "unwrapped")
    }

    @Test
    func `Builder handles if-let with nil`() {
        let maybeValue: String? = nil
        let group = Rendering.Group {
            if let value = maybeValue {
                TestRenderable(value)
            }
        }
        let result = render(group)
        #expect(result == "")
    }

    // MARK: - Integration: For Loops via ForEach

    @Test
    func `Builder handles ForEach`() {
        let items = ["a", "b", "c"]
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }
        let result = render(forEach)
        #expect(result == "abc")
    }

    @Test
    func `Builder handles empty ForEach`() {
        let items: [String] = []
        let forEach = Rendering.ForEach(items) { item in
            TestRenderable(item)
        }
        let result = render(forEach)
        #expect(result == "")
    }
}
