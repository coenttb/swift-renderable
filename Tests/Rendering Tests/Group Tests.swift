//
//  Group Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `Group Tests` {

    // MARK: - Initialization

    @Test
    func `Group wraps content`() {
        let group = Group {
            Raw("content")
        }
        #expect(group.content.bytes == Array("content".utf8))
    }

    @Test
    func `Group with multiple items via tuple`() {
        let group = Group {
            Raw("a")
            Raw("b")
        }
        // Group content is a tuple
        #expect(group.content.value.0.bytes == Array("a".utf8))
        #expect(group.content.value.1.bytes == Array("b".utf8))
    }

    // MARK: - Sendable

    @Test
    func `Group is Sendable when content is Sendable`() {
        let group = Group { Raw("test") }
        Task {
            _ = group.content
        }
        #expect(true) // Compile-time check
    }
}
