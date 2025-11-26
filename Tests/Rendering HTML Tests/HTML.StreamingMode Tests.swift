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
    func `StreamingMode has buffered case`() {
        let mode: HTML.StreamingMode = .buffered
        #expect(mode == .buffered)
    }

    @Test
    func `StreamingMode has streaming case`() {
        let mode: HTML.StreamingMode = .streaming
        #expect(mode == .streaming)
    }

    // MARK: - Sendable

    @Test
    func `StreamingMode is Sendable`() {
        let mode: HTML.StreamingMode = .buffered
        Task {
            _ = mode
        }
        #expect(Bool(true)) // Compile-time check
    }

    // MARK: - Equality

    @Test
    func `StreamingMode cases are distinct`() {
        let buffered: HTML.StreamingMode = .buffered
        let streaming: HTML.StreamingMode = .streaming

        #expect(buffered != streaming)
    }
}
