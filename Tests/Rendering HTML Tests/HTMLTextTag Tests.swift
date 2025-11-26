//
//  HTML.Tag.Text Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `HTML.Tag.Text Tests` {

    // MARK: - Initialization

    @Test
    func `HTML.Tag.Text string initialization`() throws {
        let textTag = HTML.Tag.Text("title")
        #expect(textTag.rawValue == "title")
    }

    @Test
    func `HTML.Tag.Text string literal initialization`() throws {
        let textTag: HTML.Tag.Text = "option"
        #expect(textTag.rawValue == "option")
    }

    // MARK: - Call As Function

    @Test
    func `HTML.Tag.Text with empty content`() throws {
        let textTag = HTML.Tag.Text("title")
        let element = textTag()
        let rendered = try String(element)
        #expect(rendered == "<title></title>")
    }

    @Test
    func `HTML.Tag.Text with string content`() throws {
        let textTag = HTML.Tag.Text("title")
        let element = textTag("Page Title")
        let rendered = try String(element)
        #expect(rendered == "<title>Page Title</title>")
    }

    @Test
    func `HTML.Tag.Text with closure content`() throws {
        let textTag = HTML.Tag.Text("option")
        let value = "Dynamic Value"
        let element = textTag { value }
        let rendered = try String(element)
        #expect(rendered == "<option>Dynamic Value</option>")
    }

    // MARK: - Common Text Tags

    @Test
    func `HTML.Tag.Text for title element`() throws {
        let title = HTML.Tag.Text("title")
        let element = title("My Website")
        let rendered = try String(element)
        #expect(rendered.contains("<title>"))
        #expect(rendered.contains("My Website"))
        #expect(rendered.contains("</title>"))
    }

    @Test
    func `HTML.Tag.Text for option element`() throws {
        let option = HTML.Tag.Text("option")
        let element = option("Select me")
        let rendered = try String(element)
        #expect(rendered == "<option>Select me</option>")
    }

    @Test
    func `HTML.Tag.Text for textarea element`() throws {
        let textarea = HTML.Tag.Text("textarea")
        let element = textarea("Default text")
        let rendered = try String(element)
        #expect(rendered == "<textarea>Default text</textarea>")
    }

    @Test
    func `HTML.Tag.Text for label element`() throws {
        let label = HTML.Tag.Text("label")
        let element = label("Username:")
        let rendered = try String(element)
        #expect(rendered == "<label>Username:</label>")
    }

    // MARK: - Escaping

    @Test
    func `HTML.Tag.Text escapes special characters`() throws {
        let textTag = HTML.Tag.Text("title")
        let element = textTag("Page <Title> & More")
        let rendered = try String(element)
        #expect(rendered.contains("&lt;Title&gt;"))
        #expect(rendered.contains("&amp;"))
    }

    // MARK: - Attributes

    @Test
    func `HTML.Tag.Text with attributes`() throws {
        let option = HTML.Tag.Text("option")
        let element = option("First")
            .attribute("value", "1")
            .attribute("selected", "")

        let rendered = try String(HTML.Document { element })
        #expect(rendered.contains("value=\"1\""))
        #expect(rendered.contains("selected"))
        #expect(rendered.contains("First"))
    }

    // MARK: - In Document Context

    @Test
    func `HTML.Tag.Text in head`() throws {
        let document = HTML.Document {
            Empty()
        } head: {
            HTML.Tag.Text("title")("Document Title")
            tag("meta")
                .attribute("charset", "utf-8")
        }

        let rendered = try String(document)
        #expect(rendered.contains("<title>Document Title</title>"))
    }

    @Test
    func `HTML.Tag.Text in select element`() throws {
        let option = HTML.Tag.Text("option")
        let html = tag("select") {
            option("Option 1").attribute("value", "1")
            option("Option 2").attribute("value", "2")
            option("Option 3").attribute("value", "3")
        }

        let rendered = try String(HTML.Document { html })
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
        @Test
        func `HTML.Tag.Text in form snapshot`() {
            let option = HTML.Tag.Text("option")
            let label = HTML.Tag.Text("label")

            assertInlineSnapshot(
                of: HTML.Document {
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
