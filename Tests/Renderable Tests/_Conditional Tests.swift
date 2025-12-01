//
//  _Conditional Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Renderable
import Testing

@Suite
struct `_Conditional Tests` {

    // MARK: - First Branch

    @Test
    func `_Conditional first branch`() {
        let conditional = _Conditional<TestElement, TestElement>.first(TestElement(id: "first"))
        switch conditional {
        case .first(let element):
            #expect(element.id == "first")
        case .second:
            Issue.record("Expected first branch")
        }
    }

    // MARK: - Second Branch

    @Test
    func `_Conditional second branch`() {
        let conditional = _Conditional<TestElement, TestElement>.second(TestElement(id: "second"))
        switch conditional {
        case .first:
            Issue.record("Expected second branch")
        case .second(let element):
            #expect(element.id == "second")
        }
    }

    // MARK: - Type Safety

    @Test
    func `_Conditional can have different branch types`() {
        let conditional = _Conditional<TestElement, OtherElement>.first(TestElement(id: "test"))
        switch conditional {
        case .first(let element):
            #expect(element.id == "test")
        case .second:
            Issue.record("Expected first branch")
        }
    }

    // MARK: - Sendable

    @Test
    func `_Conditional is Sendable when both branches are Sendable`() {
        let conditional = _Conditional<TestElement, TestElement>.first(TestElement(id: "test"))
        Task {
            _ = conditional
        }
        #expect(Bool(true)) // Compile-time check
    }
}

// MARK: - Test Helpers

private struct TestElement: Renderable, Sendable {
    let id: String
    typealias Context = Void
    typealias Content = Never

    init(id: String = "") { self.id = id }
    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: TestElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}

private struct OtherElement: Renderable, Sendable {
    typealias Context = Void
    typealias Content = Never
    var body: Never { fatalError("This type uses direct rendering and doesn't have a body.") }

    static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: OtherElement,
        into buffer: inout Buffer,
        context: inout Void
    ) where Buffer.Element == UInt8 {}
}
