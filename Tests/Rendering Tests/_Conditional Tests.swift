//
//  _Conditional Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `_Conditional Tests` {

    // MARK: - First Branch

    @Test
    func `_Conditional first branch`() {
        let conditional = _Conditional<Raw, Raw>(.first(Raw("first")))
        switch conditional.value {
        case .first(let raw):
            #expect(raw.bytes == Array("first".utf8))
        case .second:
            Issue.record("Expected first branch")
        }
    }

    // MARK: - Second Branch

    @Test
    func `_Conditional second branch`() {
        let conditional = _Conditional<Raw, Raw>(.second(Raw("second")))
        switch conditional.value {
        case .first:
            Issue.record("Expected second branch")
        case .second(let raw):
            #expect(raw.bytes == Array("second".utf8))
        }
    }

    // MARK: - Type Safety

    @Test
    func `_Conditional with different types`() {
        struct TypeA: Rendering {
            typealias Context = Never
            typealias Content = Never
            var body: Never { fatalError() }
        }
        struct TypeB: Rendering {
            typealias Context = Never
            typealias Content = Never
            var body: Never { fatalError() }
        }

        let conditional = _Conditional<TypeA, TypeB>(.first(TypeA()))
        switch conditional.value {
        case .first:
            #expect(true)
        case .second:
            Issue.record("Expected first branch")
        }
    }

    // MARK: - Sendable

    @Test
    func `_Conditional is Sendable when both types are Sendable`() {
        let conditional = _Conditional<Raw, Raw>(.first(Raw("test")))
        Task {
            _ = conditional.value
        }
        #expect(true) // Compile-time check
    }
}
