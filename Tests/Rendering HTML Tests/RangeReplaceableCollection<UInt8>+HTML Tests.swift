//
//  RangeReplaceableCollection<UInt8>+HTML Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `RangeReplaceableCollection<UInt8>+HTML Tests` {

    // MARK: - Array<UInt8>

    @Test
    func `Array<UInt8> renders HTML view`() {
        let html = tag("div") { HTML.Text("hello") }
        let bytes: [UInt8] = .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
        #expect(string.contains("hello"))
        #expect(string.contains("</div>"))
    }

    @Test
    func `Array<UInt8> renders empty HTML`() {
        let html = Empty()
        let bytes: [UInt8] = .init(html)
        #expect(bytes.isEmpty)
    }

    @Test
    func `Array<UInt8> renders nested HTML`() {
        let html = tag("div") {
            tag("p") {
                HTML.Text("nested")
            }
        }
        let bytes: [UInt8] = .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
        #expect(string.contains("<p>"))
        #expect(string.contains("nested"))
    }

    // MARK: - ContiguousArray<UInt8>

    @Test
    func `ContiguousArray<UInt8> renders HTML view`() {
        let html = tag("span") { HTML.Text("content") }
        let bytes: ContiguousArray<UInt8> = .init(html)
        let string = String(decoding: Array(bytes), as: UTF8.self)
        #expect(string.contains("<span>"))
        #expect(string.contains("content"))
        #expect(string.contains("</span>"))
    }

    // MARK: - Configuration

    @Test
    func `Renders with custom configuration`() {
        let html = tag("div") { HTML.Text("test") }
        let config = HTML.Context.Configuration(
            forceImportant: false,
            indentation: [],
            newline: [],
            reservedCapacity: 1024
        )
        let bytes: [UInt8] = .init(html, configuration: config)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<div>"))
    }

    // MARK: - Async Rendering

    @Test
    func `Async Array<UInt8> renders HTML view`() async {
        let html = tag("article") { HTML.Text("async content") }
        let bytes: [UInt8] = await .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<article>"))
        #expect(string.contains("async content"))
    }

    @Test
    func `Async ContiguousArray<UInt8> renders HTML view`() async {
        let html = tag("section") { HTML.Text("async section") }
        let bytes: ContiguousArray<UInt8> = await .init(html)
        let string = String(decoding: Array(bytes), as: UTF8.self)
        #expect(string.contains("<section>"))
    }

    // MARK: - Document Rendering

    @Test
    func `Array<UInt8> renders HTML document`() {
        let document = HTML.Document {
            tag("h1") { HTML.Text("Title") }
        }
        let bytes: [UInt8] = .init(document)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<!doctype html>"))
        #expect(string.contains("<html>"))
        #expect(string.contains("<h1>"))
        #expect(string.contains("Title"))
    }

    @Test
    func `Async Array<UInt8> renders HTML document`() async {
        let document = HTML.Document {
            tag("p") { HTML.Text("Async document") }
        }
        let bytes: [UInt8] = await .init(document)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<!doctype html>"))
        #expect(string.contains("Async document"))
    }

    // MARK: - Content Types

    @Test
    func `Renders Group`() {
        let html = Group {
            tag("span") { HTML.Text("a") }
            tag("span") { HTML.Text("b") }
        }
        let bytes: [UInt8] = .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<span>a</span>"))
        #expect(string.contains("<span>b</span>"))
    }

    @Test
    func `Renders ForEach`() {
        let items = ["one", "two", "three"]
        let html = HTML.ForEach(items) { item in
            tag("li") { HTML.Text(item) }
        }
        let bytes: [UInt8] = .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string.contains("<li>one</li>"))
        #expect(string.contains("<li>two</li>"))
        #expect(string.contains("<li>three</li>"))
    }

    @Test
    func `Renders HTML.Raw`() {
        let html = HTML.Raw("<custom-element>raw</custom-element>")
        let bytes: [UInt8] = .init(html)
        let string = String(decoding: bytes, as: UTF8.self)
        #expect(string == "<custom-element>raw</custom-element>")
    }
}
