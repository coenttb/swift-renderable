//
//  Raw Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Renderable
import Testing

@Suite
struct `Raw Tests` {

    // MARK: - Initialization

    @Test
    func `Raw init from String`() {
        let raw = Raw("hello")
        #expect(Array(raw.bytes) == Array("hello".utf8))
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
        #expect(Array(raw.bytes) == bytes)
    }

    @Test
    func `Raw init from StaticString`() {
        let raw = Raw("static")
        #expect(Array(raw.bytes) == Array("static".utf8))
    }

    // MARK: - Bytes Access

    @Test
    func `Raw bytes returns ContiguousArray`() {
        let raw = Raw("test")
        let bytes = raw.bytes
        #expect(bytes is ContiguousArray<UInt8>)
        #expect(Array(bytes) == Array("test".utf8))
    }

    // MARK: - Unicode

    @Test
    func `Raw preserves unicode content`() {
        let raw = Raw("Hello 世界 🌍")
        #expect(Array(raw.bytes) == Array("Hello 世界 🌍".utf8))
    }

    @Test
    func `Raw preserves special characters`() {
        let raw = Raw("<script>alert('xss')</script>")
        #expect(Array(raw.bytes) == Array("<script>alert('xss')</script>".utf8))
    }

    // MARK: - Sendable

    @Test
    func `Raw is Sendable`() {
        let raw = Raw("test")
        Task {
            _ = raw.bytes
        }
        #expect(Bool(true)) // Compile-time check
    }
}
