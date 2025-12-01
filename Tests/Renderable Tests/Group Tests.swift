//
//  Group Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing

@testable import Renderable

// Note: Group tests that use @Builder require Rendering conformance.
// Those tests are in domain-specific test modules (e.g., Rendering HTML Tests).
// This file tests the Group struct itself without rendering behavior.

@Suite
struct `Group Tests` {

    // MARK: - Structure

    @Test
    func `Group struct exists`() {
        // Group requires a Builder closure, which requires Rendering conformance
        // So we just verify the type exists
        let _: Group<Raw>.Type = Group<Raw>.self
        #expect(Bool(true))
    }

    // MARK: - Sendable

    @Test
    func `Group type is Sendable when content is Sendable`() {
        // Compile-time check - Group<Raw> should be Sendable since Raw is Sendable
        func requiresSendable<T: Sendable>(_ type: T.Type) {}
        requiresSendable(Group<Raw>.self)
        #expect(Bool(true))
    }
}
