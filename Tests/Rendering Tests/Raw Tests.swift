//
//  Raw Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering
import Testing

@Suite
struct `Raw Tests` {

    // MARK: - Initialization

    @Test
    func `Raw init from String`() {
        let raw = Raw("hello")
        #expect(raw.bytes == Array("hello".utf8))
    }

    @Test
    func `Raw init from empty String`() {
        let raw = Raw("")
        #expect(raw.bytes.isEmpty)
    }

    @Test
    func `Raw init from UInt8 array`() {
        let bytes: [UInt8] = [72, 105] // "Hi"
        let raw = Raw(bytes)
        #expect(raw.bytes == bytes)
    }

    @Test
    func `Raw init from StaticString`() {
        let raw = Raw("static")
        #expect(raw.bytes == Array("static".utf8))
    }

    // MARK: - Unicode Support

    @Test
    func `Raw preserves unicode`() {
        let raw = Raw("Hello 世界 🌍")
        let expected = Array("Hello 世界 🌍".utf8)
        #expect(raw.bytes == expected)
    }

    @Test
    func `Raw preserves emoji`() {
        let raw = Raw("🎉🎊🎈")
        let expected = Array("🎉🎊🎈".utf8)
        #expect(raw.bytes == expected)
    }

    // MARK: - Special Characters

    @Test
    func `Raw preserves HTML characters unescaped`() {
        let raw = Raw("<div>&amp;</div>")
        let expected = Array("<div>&amp;</div>".utf8)
        #expect(raw.bytes == expected)
    }

    @Test
    func `Raw preserves newlines and whitespace`() {
        let raw = Raw("line1\nline2\ttab")
        let expected = Array("line1\nline2\ttab".utf8)
        #expect(raw.bytes == expected)
    }

    // MARK: - Sendable

    @Test
    func `Raw is Sendable`() {
        let raw = Raw("test")
        Task {
            _ = raw.bytes
        }
        #expect(true) // Compile-time check
    }
}
