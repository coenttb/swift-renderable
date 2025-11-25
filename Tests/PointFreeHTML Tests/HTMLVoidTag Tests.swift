//
//  HTMLVoidTag Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("HTMLVoidTag Tests")
struct HTMLVoidTagTests {

    // MARK: - Initialization

    @Test("HTMLVoidTag string initialization")
    func stringInitialization() throws {
        let voidTag = HTMLVoidTag("br")
        #expect(voidTag.rawValue == "br")
    }

    @Test("HTMLVoidTag string literal initialization")
    func stringLiteralInitialization() throws {
        let voidTag: HTMLVoidTag = "hr"
        #expect(voidTag.rawValue == "hr")
    }

    // MARK: - All Tags

    @Test("HTMLVoidTag.allTags contains expected tags")
    func allTagsContainsExpectedTags() {
        let allTags = HTMLVoidTag.allTags
        #expect(allTags.contains("area"))
        #expect(allTags.contains("base"))
        #expect(allTags.contains("br"))
        #expect(allTags.contains("col"))
        #expect(allTags.contains("embed"))
        #expect(allTags.contains("hr"))
        #expect(allTags.contains("img"))
        #expect(allTags.contains("input"))
        #expect(allTags.contains("link"))
        #expect(allTags.contains("meta"))
        #expect(allTags.contains("param"))
        #expect(allTags.contains("source"))
        #expect(allTags.contains("track"))
        #expect(allTags.contains("wbr"))
    }

    @Test("HTMLVoidTag.allTags has correct count")
    func allTagsHasCorrectCount() {
        #expect(HTMLVoidTag.allTags.count == 16)
    }

    // MARK: - Call As Function

    @Test("HTMLVoidTag creates self-closing element")
    func createsSelfClosingElement() throws {
        let br = HTMLVoidTag("br")
        let element = br()
        let rendered = try String(element)
        #expect(rendered.contains("<br"))
        #expect(!rendered.contains("</br>"))
    }

    // MARK: - Common Void Tags

    @Test("HTMLVoidTag br element")
    func brElement() throws {
        let br = HTMLVoidTag("br")
        let rendered = try String(br())
        #expect(rendered.contains("<br>"))
    }

    @Test("HTMLVoidTag hr element")
    func hrElement() throws {
        let hr = HTMLVoidTag("hr")
        let rendered = try String(hr())
        #expect(rendered.contains("<hr>"))
    }

    @Test("HTMLVoidTag img element")
    func imgElement() throws {
        let img = HTMLVoidTag("img")
        let element = img()
            .attribute("src", "/image.jpg")
            .attribute("alt", "Description")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<img"))
        #expect(rendered.contains("src=\"/image.jpg\""))
        #expect(rendered.contains("alt=\"Description\""))
        #expect(!rendered.contains("</img>"))
    }

    @Test("HTMLVoidTag input element")
    func inputElement() throws {
        let input = HTMLVoidTag("input")
        let element = input()
            .attribute("type", "text")
            .attribute("name", "username")
            .attribute("placeholder", "Enter username")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<input"))
        #expect(rendered.contains("type=\"text\""))
        #expect(rendered.contains("name=\"username\""))
    }

    @Test("HTMLVoidTag meta element")
    func metaElement() throws {
        let meta = HTMLVoidTag("meta")
        let element = meta()
            .attribute("charset", "utf-8")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<meta"))
        #expect(rendered.contains("charset=\"utf-8\""))
    }

    @Test("HTMLVoidTag link element")
    func linkElement() throws {
        let link = HTMLVoidTag("link")
        let element = link()
            .attribute("rel", "stylesheet")
            .attribute("href", "/styles.css")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("<link"))
        #expect(rendered.contains("rel=\"stylesheet\""))
        #expect(rendered.contains("href=\"/styles.css\""))
    }

    // MARK: - Attributes

    @Test("HTMLVoidTag with multiple attributes")
    func multipleAttributes() throws {
        let input = HTMLVoidTag("input")
        let element = input()
            .attribute("type", "email")
            .attribute("name", "email")
            .attribute("id", "email-field")
            .attribute("required", "")
            .attribute("placeholder", "your@email.com")

        let rendered = try String(HTMLDocument { element })
        #expect(rendered.contains("type=\"email\""))
        #expect(rendered.contains("name=\"email\""))
        #expect(rendered.contains("id=\"email-field\""))
        #expect(rendered.contains("required"))
        #expect(rendered.contains("placeholder=\"your@email.com\""))
    }

    // MARK: - In Context

    @Test("HTMLVoidTag in form")
    func inForm() throws {
        let input = HTMLVoidTag("input")
        let br = HTMLVoidTag("br")

        let html = tag("form") {
            tag("label") { HTMLText("Name:") }
            br()
            input().attribute("type", "text").attribute("name", "name")
            br()
            tag("label") { HTMLText("Email:") }
            br()
            input().attribute("type", "email").attribute("name", "email")
        }

        let rendered = try String(HTMLDocument { html })
        #expect(rendered.contains("<form>"))
        #expect(rendered.contains("<br>"))
        #expect(rendered.contains("<input"))
    }

    @Test("HTMLVoidTag in head")
    func inHead() throws {
        let meta = HTMLVoidTag("meta")
        let link = HTMLVoidTag("link")

        let document = HTMLDocument {
            HTMLEmpty()
        } head: {
            meta().attribute("charset", "utf-8")
            meta().attribute("name", "viewport").attribute("content", "width=device-width")
            link().attribute("rel", "stylesheet").attribute("href", "/styles.css")
        }

        let rendered = try String(document)
        #expect(rendered.contains("charset=\"utf-8\""))
        #expect(rendered.contains("name=\"viewport\""))
        #expect(rendered.contains("rel=\"stylesheet\""))
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLVoidTagSnapshotTests {
        @Test("HTMLVoidTag form elements snapshot")
        func formElementsSnapshot() {
            let input = HTMLVoidTag("input")
            let br = HTMLVoidTag("br")

            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("form") {
                        tag("fieldset") {
                            tag("legend") { HTMLText("Contact Form") }
                            tag("label") { HTMLText("Name:") }
                            br()
                            input()
                                .attribute("type", "text")
                                .attribute("name", "name")
                            br()
                            br()
                            tag("label") { HTMLText("Email:") }
                            br()
                            input()
                                .attribute("type", "email")
                                .attribute("name", "email")
                        }
                    }
                    .attribute("method", "post")
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
                <form method="post">
                  <fieldset>
                    <legend>Contact Form
                    </legend><label>Name:</label><br><input type="text" name="name"><br><br><label>Email:</label><br><input type="email" name="email">
                  </fieldset>
                </form>
                  </body>
                </html>
                """
            }
        }
    }
}
