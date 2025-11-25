//
//  Optional Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("Optional Tests")
struct OptionalTests {

    // MARK: - Optional HTML Rendering

    @Test("Optional some renders content")
    func someRendersContent() throws {
        let optionalHTML: HTMLText? = HTMLText("Present")
        let rendered = try String(HTMLGroup { optionalHTML })
        #expect(rendered == "Present")
    }

    @Test("Optional none renders nothing")
    func noneRendersNothing() throws {
        let optionalHTML: HTMLText? = nil
        let rendered = try String(HTMLGroup { optionalHTML })
        #expect(rendered.isEmpty)
    }

    // MARK: - Optional Elements

    @Test("Optional element renders when present")
    func optionalElementPresent() throws {
        let optionalElement: HTMLElement<HTMLText>? = tag("div") {
            HTMLText("Content")
        }

        let rendered = try String(HTMLGroup { optionalElement })
        #expect(rendered.contains("<div>"))
        #expect(rendered.contains("Content"))
    }

    @Test("Optional element renders nothing when nil")
    func optionalElementNil() throws {
        let optionalElement: HTMLElement<HTMLText>? = nil

        let rendered = try String(HTMLGroup { optionalElement })
        #expect(rendered.isEmpty)
    }

    // MARK: - In Builder Context

    @Test("Optional in builder with some value")
    func inBuilderSome() throws {
        struct ConditionalContent: HTML {
            let showOptional: Bool

            var body: some HTML {
                let optionalContent: HTMLText? = showOptional ? HTMLText("Optional present") : nil
                HTMLGroup {
                    tag("div") {
                        HTMLText("Always present")
                    }
                    optionalContent
                }
            }
        }

        let rendered = try String(ConditionalContent(showOptional: true))
        #expect(rendered.contains("Always present"))
        #expect(rendered.contains("Optional present"))
    }

    @Test("Optional in builder with none value")
    func inBuilderNone() throws {
        struct ConditionalContent: HTML {
            let showOptional: Bool

            var body: some HTML {
                let optionalContent: HTMLText? = showOptional ? HTMLText("Optional present") : nil
                HTMLGroup {
                    tag("div") {
                        HTMLText("Always present")
                    }
                    optionalContent
                }
            }
        }

        let rendered = try String(ConditionalContent(showOptional: false))
        #expect(rendered.contains("Always present"))
        #expect(!rendered.contains("Optional present"))
    }

    // MARK: - Optional Chaining

    @Test("Optional with attributes when present")
    func optionalWithAttributesPresent() throws {
        let optionalElement: HTMLElement<HTMLText>? = tag("span") {
            HTMLText("Styled")
        }

        // Since Optional<HTML> conforms to HTML but doesn't chain .attribute,
        // we test by rendering the base element with attributes first
        if let element = optionalElement?.attribute("class", "highlight") {
            let rendered = try String(HTMLDocument { element })
            #expect(rendered.contains("class=\"highlight\""))
        }
    }

    // MARK: - Nested Optionals

    @Test("Nested optional HTML")
    func nestedOptional() throws {
        let inner: HTMLText? = HTMLText("Inner")
        let outer: HTMLText?? = inner

        // Both levels resolve to the value
        if let unwrapped = outer, let content = unwrapped {
            let rendered = try String(HTMLGroup { content })
            #expect(rendered == "Inner")
        }
    }

    // MARK: - Optional with Complex Types

    @Test("Optional HTMLGroup")
    func optionalHTMLGroup() throws {
        let group: HTMLGroup<HTMLText>? = HTMLGroup {
            HTMLText("Grouped content")
        }

        let rendered = try String(HTMLGroup { group })
        #expect(rendered == "Grouped content")
    }

    @Test("Optional array element")
    func optionalArrayElement() throws {
        let items = ["Item 1", "Item 2", nil, "Item 4"]

        let html = HTMLGroup {
            for item in items {
                let content: HTMLText? = item.map { HTMLText($0) }
                content
            }
        }

        let rendered = try String(html)
        #expect(rendered.contains("Item 1"))
        #expect(rendered.contains("Item 2"))
        #expect(rendered.contains("Item 4"))
        #expect(!rendered.contains("Item 3"))
    }

    // MARK: - Context Propagation

    @Test("Optional propagates context when present")
    func propagatesContext() throws {
        // Use AnyHTML to type-erase the styled element into an optional
        let optionalElement: AnyHTML? = AnyHTML(
            tag("div") {
                HTMLText("Styled")
            }
            .inlineStyle("color", "blue")
        )

        if let element = optionalElement {
            let rendered = try String(HTMLDocument { element })
            #expect(rendered.contains("color:blue"))
        } else {
            Issue.record("Optional should not be nil")
        }
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct OptionalSnapshotTests {
        @Test("Optional content snapshot")
        func optionalContentSnapshot() {
            struct OptionalList: HTML {
                let items: [String?]

                var body: some HTML {
                    tag("ul") {
                        for item in items {
                            if let text = item {
                                tag("li") {
                                    HTMLText(text)
                                }
                            }
                        }
                    }
                }
            }

            assertInlineSnapshot(
                of: HTMLDocument {
                    OptionalList(items: ["First", nil, "Third", "Fourth", nil])
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
                <ul>
                  <li>First
                  </li>
                  <li>Third
                  </li>
                  <li>Fourth
                  </li>
                </ul>
                  </body>
                </html>
                """
            }
        }
    }
}
