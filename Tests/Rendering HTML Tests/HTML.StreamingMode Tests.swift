//
//  HTML.StreamingMode Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering_HTML
import Testing

@Suite
struct `HTML.StreamingMode Tests` {

    // MARK: - Enum Cases

    @Test
    func `StreamingMode has batch case`() {
        let mode: HTML.StreamingMode = .batch
        switch mode {
        case .batch:
            #expect(true)
        case .progressive:
            Issue.record("Expected batch")
        }
    }

    @Test
    func `StreamingMode has progressive case`() {
        let mode: HTML.StreamingMode = .progressive
        switch mode {
        case .batch:
            Issue.record("Expected progressive")
        case .progressive:
            #expect(true)
        }
    }

    // MARK: - Sendable

    @Test
    func `StreamingMode is Sendable`() {
        let mode: HTML.StreamingMode = .batch
        Task {
            _ = mode
        }
        #expect(true) // Compile-time check
    }

    // MARK: - Equality

    @Test
    func `StreamingMode cases are distinct`() {
        let batch: HTML.StreamingMode = .batch
        let progressive: HTML.StreamingMode = .progressive

        switch (batch, progressive) {
        case (.batch, .progressive):
            #expect(true)
        default:
            Issue.record("Cases should be distinct")
        }
    }
}
