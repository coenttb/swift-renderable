//
//  Raw Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Testing
@testable import Rendering

@Suite
struct `Raw Tests` {

    // MARK: - String Initialization

    @Test
    func `Raw can be created from String`() {
        let raw = Rendering.Raw("hello")
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "hello")
    }

    @Test
    func `Raw from empty String`() {
        let raw = Rendering.Raw("")
        #expect(raw.bytes.isEmpty)
    }

    @Test
    func `Raw preserves unicode content`() {
        let raw = Rendering.Raw("héllo 世界 🎉")
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "héllo 世界 🎉")
    }

    @Test
    func `Raw preserves special characters`() {
        let raw = Rendering.Raw("<script>alert('xss')</script>")
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "<script>alert('xss')</script>")
    }

    // MARK: - Byte Initialization

    @Test
    func `Raw can be created from byte array`() {
        let bytes: [UInt8] = [72, 101, 108, 108, 111]  // "Hello"
        let raw = Rendering.Raw(bytes)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "Hello")
    }

    @Test
    func `Raw from empty byte array`() {
        let raw = Rendering.Raw([UInt8]())
        #expect(raw.bytes.isEmpty)
    }

    @Test
    func `Raw from UTF8 view`() {
        let raw = Rendering.Raw("test".utf8)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "test")
    }

    // MARK: - Bytes Property

    @Test
    func `bytes property returns ContiguousArray`() {
        let raw = Rendering.Raw("test")
        let bytes: ContiguousArray<UInt8> = raw.bytes
        #expect(bytes.count == 4)
    }

    @Test
    func `bytes are stored contiguously`() {
        let raw = Rendering.Raw("abcdef")
        #expect(raw.bytes.count == 6)
        #expect(raw.bytes[0] == UInt8(ascii: "a"))
        #expect(raw.bytes[5] == UInt8(ascii: "f"))
    }

    // MARK: - Sendable

    @Test
    func `Raw is Sendable`() {
        let raw = Rendering.Raw("test")
        Task {
            _ = raw.bytes
        }
        #expect(Bool(true))
    }

    @Test
    func `Raw can be passed across actor boundaries`() async {
        let raw = Rendering.Raw("concurrent")
        await Task.detached {
            _ = raw.bytes
        }.value
        #expect(Bool(true))
    }

    // MARK: - Typealias

    @Test
    func `Raw typealias works`() {
        let raw: Raw = Raw("alias")
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "alias")
    }

    // MARK: - Content Preservation

    @Test(arguments: [
        ("simple text", "simple text"),
        ("with\nnewline", "with\nnewline"),
        ("with\ttab", "with\ttab"),
        ("with   spaces", "with   spaces"),
        ("<html>tags</html>", "<html>tags</html>"),
        ("&amp; entities", "&amp; entities"),
        ("\"quotes\"", "\"quotes\""),
        ("'apostrophe'", "'apostrophe'"),
        ("back\\slash", "back\\slash")
    ])
    func `Raw preserves content exactly`(input: String, expected: String) {
        let raw = Rendering.Raw(input)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == expected)
    }

    // MARK: - Large Content

    @Test
    func `Raw handles large content`() {
        let largeString = String(repeating: "x", count: 10_000)
        let raw = Rendering.Raw(largeString)
        #expect(raw.bytes.count == 10_000)
    }

    @Test
    func `Raw handles very large content`() {
        let veryLargeString = String(repeating: "y", count: 100_000)
        let raw = Rendering.Raw(veryLargeString)
        #expect(raw.bytes.count == 100_000)
    }

    // MARK: - Binary Content

    @Test
    func `Raw handles binary data`() {
        let binaryData: [UInt8] = [0x00, 0x01, 0xFF, 0xFE, 0x80]
        let raw = Rendering.Raw(binaryData)
        #expect(raw.bytes.count == 5)
        #expect(raw.bytes[0] == 0x00)
        #expect(raw.bytes[2] == 0xFF)
    }

    @Test
    func `Raw handles null bytes`() {
        let withNull: [UInt8] = [65, 0, 66, 0, 67]  // A\0B\0C
        let raw = Rendering.Raw(withNull)
        #expect(raw.bytes.count == 5)
    }

    // MARK: - Multiline Content

    @Test
    func `Raw handles multiline content`() {
        let multiline = """
        Line 1
        Line 2
        Line 3
        """
        let raw = Rendering.Raw(multiline)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == multiline)
    }

    // MARK: - Edge Cases

    @Test
    func `Raw handles single character`() {
        let raw = Rendering.Raw("x")
        #expect(raw.bytes.count == 1)
        #expect(raw.bytes[0] == UInt8(ascii: "x"))
    }

    @Test
    func `Raw handles single byte`() {
        let raw = Rendering.Raw([UInt8(65)])
        #expect(raw.bytes.count == 1)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "A")
    }

    @Test
    func `Raw handles emoji`() {
        let raw = Rendering.Raw("🎉🎊🎁")
        // Each emoji is 4 bytes in UTF-8
        #expect(raw.bytes.count == 12)
        #expect(String(decoding: raw.bytes, as: UTF8.self) == "🎉🎊🎁")
    }
}
