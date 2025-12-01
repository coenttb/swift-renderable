//
//  _Tuple Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Renderable

@Suite
struct `_Tuple Tests` {

    // MARK: - Creation

    @Test
    func `_Tuple can be created with two elements`() {
        let tuple = _Tuple(Raw("a"), Raw("b"))
        _ = tuple  // Verify it compiles
        #expect(Bool(true))
    }

    @Test
    func `_Tuple can be created with three elements`() {
        let tuple = _Tuple(Raw("a"), Raw("b"), Raw("c"))
        _ = tuple  // Verify it compiles
        #expect(Bool(true))
    }

    // MARK: - Mixed Types

    @Test
    func `_Tuple can hold mixed types`() {
        struct CustomType: Sendable {
            let name: String
        }

        let tuple = _Tuple(Raw("raw"), CustomType(name: "custom"))
        _ = tuple  // Verify it compiles with mixed types
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `_Tuple is Sendable when all elements are Sendable`() {
        let tuple = _Tuple(Raw("a"), Raw("b"))
        Task {
            _ = tuple
        }
        #expect(Bool(true))  // Compile-time check
    }
}
