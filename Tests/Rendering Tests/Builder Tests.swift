//
//  Builder Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

// Note: Builder tests that require @Builder usage are in domain-specific
// test modules (e.g., Rendering HTML Tests) since @Builder requires Rendering conformance.

@Suite
struct `Builder Tests` {

    // MARK: - Builder Structure Tests

    @Test
    func `Builder exists and can be referenced`() {
        // Verify the Builder type exists
        let _: Builder.Type = Builder.self
        #expect(Bool(true))
    }

    // MARK: - _Conditional Structure

    @Test
    func `_Conditional first branch structure`() {
        let conditional = _Conditional<TestElement, TestElement>.first(TestElement(id: "first"))
        switch conditional {
        case .first(let element):
            #expect(element.id == "first")
        case .second:
            Issue.record("Expected first branch")
        }
    }

    @Test
    func `_Conditional second branch structure`() {
        let conditional = _Conditional<TestElement, TestElement>.second(TestElement(id: "second"))
        switch conditional {
        case .first:
            Issue.record("Expected second branch")
        case .second(let element):
            #expect(element.id == "second")
        }
    }

    // MARK: - _Array Structure

    @Test
    func `_Array structure with elements`() {
        let array = _Array([TestElement(id: "a"), TestElement(id: "b"), TestElement(id: "c")])
        #expect(array.elements.count == 3)
        #expect(array.elements[0].id == "a")
        #expect(array.elements[1].id == "b")
        #expect(array.elements[2].id == "c")
    }

    @Test
    func `_Array structure with empty array`() {
        let array = _Array<TestElement>([])
        #expect(array.elements.isEmpty)
    }
}

// MARK: - Test Helpers

private struct TestElement: Renderable, Sendable {
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
