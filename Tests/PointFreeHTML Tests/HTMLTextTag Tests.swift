//
//  HTMLTextTag Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTMLTextTag Tests")
struct HTMLTextTagTests {

    // MARK: - Initialization

    @Test("HTMLTextTag string initialization")
    func stringInitialization() throws {
        let textTag = HTMLTextTag("title")
        #expect(textTag.rawValue == "title")
    }

    @Test("HTMLTextTag string literal initialization")
    func stringLiteralInitialization() throws {
        let textTag: HTMLTextTag = "option"
        #expect(textTag.rawValue == "option")
    }

    // MARK: - Call As Function

    @Test("HTMLTextTag with empty content")
    func emptyContent() throws {
        let textTag = HTMLTextTag("title")
        let element = textTag()
        let rendered = try String(element)
        #expect(rendered == "<title></title>")
    }

    @Test("HTMLTextTag with string content")
    func stringContent() throws {
        let textTag = HTMLTextTag("title")
        let element = textTag("Page Title")
        let rendered = try String(element)
        #expect(rendered == "<title>Page Title</title>")
    }

    @Test("HTMLTextTag with closure content")
    func closureContent() throws {
        let textTag = HTMLTextTag("option")
        let value = "Dynamic Value"
        let element = textTag { value }
        let rendered = try String(element)
        #expect(rendered == "<option>Dynamic Value</option>")
    }

    // MARK: - Common Text Tags

    @Test("HTMLTextTag for title element")
    func titleElement() throws {
        let title = HTMLTextTag("title")
        let element = title("My Website")
        let rendered = try String(element)
        #expect(rendered.contains("<title>"))
        #expect(rendered.contains("My Website"))
        #expect(rendered.contains("</title>"))
    }

    @Test("HTMLTextTag for option element")
    func optionElement() throws {
        let option = HTMLTextTag("option")
        let element = option("Select me")
        let rendered = try String(element)
        #expect(rendered == "<option>Select me</option>")
    }

    @Test("HTMLTextTag for textarea element")
    func textareaElement() throws {
        let textarea = HTMLTextTag("textarea")
        let element = textarea("Default text")
        let rendered = try String(element)
        #expect(rendered == "<textarea>Default text</textarea>")
    }

    @Test("HTMLTextTag for label element")
    func labelElement() throws {
        let label = HTMLTextTag("label")
        let element = label("Username:")
        let rendered = try String(element)
        #expect(rendered == "<label>Username:</label>")
    }

    // MARK: - Escaping

    @Test("HTMLTextTag escapes special characters")
    func escapesSpecialCharacters() throws {
        let textTag = HTMLTextTag("title")
        let element = textTag("Page <Title> & More")
        let rendered = try String(element)
        #expect(rendered.contains("&lt;Title&gt;"))
        #expect(rendered.contains("&amp;"))
    }

    // MARK: - Attributes

    @Test("HTMLTextTag with attributes")
    func withAttributes() throws {
        let option = HTMLTextTag("option")
        let element = option("First")
            .attribute("value", "1")
            .attribute("selected", "")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("value=\"1\""))
        #expect(rendered.contains("selected"))
        #expect(rendered.contains("First"))
    }

    // MARK: - In Document Context

    @Test("HTMLTextTag in head")
    func inHead() throws {
        let document = HTMLDocument {
            Empty()
        } head: {
            HTMLTextTag("title")("Document Title")
            tag("meta")
                .attribute("charset", "utf-8")
        }

        let rendered = try String(document)
        #expect(rendered.contains("<title>Document Title</title>"))
    }

    @Test("HTMLTextTag in select element")
    func inSelectElement() throws {
        let option = HTMLTextTag("option")
        let html = tag("select") {
            option("Option 1").attribute("value", "1")
            option("Option 2").attribute("value", "2")
            option("Option 3").attribute("value", "3")
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("<select>"))
        #expect(rendered.contains("<option value=\"1\">Option 1</option>"))
        #expect(rendered.contains("<option value=\"2\">Option 2</option>"))
        #expect(rendered.contains("<option value=\"3\">Option 3</option>"))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLTextTagSnapshotTests {
        @Test("HTMLTextTag in form snapshot")
        func inFormSnapshot() {
            let option = HTMLTextTag("option")
            let label = HTMLTextTag("label")

            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("form") {
                        tag("div") {
                            label("Country:")
                                .attribute("for", "country")
                            tag("select") {
                                option("USA").attribute("value", "us")
                                option("UK").attribute("value", "uk")
                                option("Canada").attribute("value", "ca")
                            }
                            .attribute("id", "country")
                            .attribute("name", "country")
                        }
                    }
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>

                    </style>
                  </head>
                  <body>
                <form>
                  <div><label for="country">Country:</label><select id="country" name="country">
                    <option value="us">USA
                    </option>
                    <option value="uk">UK
                    </option>
                    <option value="ca">Canada
                    </option></select>
                  </div>
                </form>
                  </body>
                </html>
                """
            }
        }
    }
}
