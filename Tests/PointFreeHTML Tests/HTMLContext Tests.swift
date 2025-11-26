//
//  HTML.Context Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("HTML.Context Tests")
struct HTMLContextTests {

    // MARK: - Initialization

    @Test("HTML.Context default initialization")
    func defaultInitialization() {
        let context = HTML.Context()
        #expect(context.attributes.isEmpty)
        #expect(context.styles.isEmpty)
        #expect(context.currentIndentation.isEmpty)
    }

    @Test("HTML.Context with custom configuration")
    func customConfigurationInitialization() {
        let config = HTML.Context.Configuration.pretty
        let context = HTML.Context(config)
        #expect(context.configuration.indentation == config.indentation)
        #expect(context.configuration.newline == config.newline)
    }

    // MARK: - Class Name Generation

    @Test("HTML.Context generates deterministic class names")
    func deterministicClassNames() {
        var context = HTML.Context()
        let style1 = HTML.Style(property: "color", value: "red", atRule: nil, selector: nil, pseudo: nil)
        let style2 = HTML.Style(property: "margin", value: "10px", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context.className(for: style1)
        let name2 = context.className(for: style2)

        #expect(name1 == "color-0")
        #expect(name2 == "margin-1")
    }

    @Test("HTML.Context returns same name for same style")
    func sameNameForSameStyle() {
        var context = HTML.Context()
        let style = HTML.Style(property: "color", value: "blue", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context.className(for: style)
        let name2 = context.className(for: style)

        #expect(name1 == name2)
    }

    @Test("HTML.Context different contexts generate independent names")
    func independentContexts() {
        var context1 = HTML.Context()
        var context2 = HTML.Context()
        let style = HTML.Style(property: "color", value: "green", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context1.className(for: style)
        let name2 = context2.className(for: style)

        // Both should be color-0 since they're independent contexts
        #expect(name1 == "color-0")
        #expect(name2 == "color-0")
    }

    @Test("HTML.Context classNames batch method")
    func classNamesBatch() {
        var context = HTML.Context()
        let styles = [
            HTML.Style(property: "color", value: "red", atRule: nil, selector: nil, pseudo: nil),
            HTML.Style(property: "font-size", value: "16px", atRule: nil, selector: nil, pseudo: nil),
            HTML.Style(property: "padding", value: "10px", atRule: nil, selector: nil, pseudo: nil)
        ]

        let names = context.classNames(for: styles)

        #expect(names.count == 3)
        #expect(names[0] == "color-0")
        #expect(names[1] == "font-size-1")
        #expect(names[2] == "padding-2")
    }

    // MARK: - Stylesheet Generation

    @Test("HTML.Context empty stylesheet")
    func emptyStylesheet() {
        let context = HTML.Context()
        let stylesheet = context.stylesheet
        // Empty stylesheet is empty
        #expect(stylesheet.isEmpty)
    }

    @Test("HTML.Context stylesheet with styles")
    func stylesheetWithStyles() {
        var context = HTML.Context()
        let styleKey = HTML.StyleKey(nil, ".test-class")
        context.styles[styleKey] = "color: red"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains(".test-class{color: red}"))
    }

    @Test("HTML.Context stylesheet with media query")
    func stylesheetWithMediaQuery() {
        var context = HTML.Context()
        let atRule = HTML.AtRule(rawValue: "@media (max-width: 768px)")
        let styleKey = HTML.StyleKey(atRule, ".mobile-class")
        context.styles[styleKey] = "display: none"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains("@media (max-width: 768px)"))
        #expect(stylesheet.contains(".mobile-class{display: none}"))
    }

    @Test("HTML.Context stylesheet with forceImportant")
    func stylesheetWithForceImportant() {
        var config = HTML.Context.Configuration.default
        config = HTML.Context.Configuration(
            forceImportant: true,
            indentation: config.indentation,
            newline: config.newline,
            reservedCapacity: config.reservedCapacity
        )
        var context = HTML.Context(config)
        let styleKey = HTML.StyleKey(nil, ".important-class")
        context.styles[styleKey] = "color: blue"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains("!important"))
    }

    // MARK: - Attributes

    @Test("HTML.Context attribute storage")
    func attributeStorage() {
        var context = HTML.Context()
        context.attributes["class"] = "test-class"
        context.attributes["id"] = "test-id"

        #expect(context.attributes["class"] == "test-class")
        #expect(context.attributes["id"] == "test-id")
        #expect(context.attributes.count == 2)
    }

    @Test("HTML.Context attributes preserve order")
    func attributesPreserveOrder() {
        var context = HTML.Context()
        context.attributes["a"] = "first"
        context.attributes["b"] = "second"
        context.attributes["c"] = "third"

        let keys = Array(context.attributes.keys)
        #expect(keys == ["a", "b", "c"])
    }

    // MARK: - Indentation

    @Test("HTML.Context indentation tracking")
    func indentationTracking() {
        var context = HTML.Context(.pretty)
        #expect(context.currentIndentation.isEmpty)

        context.currentIndentation.append(contentsOf: context.configuration.indentation)
        #expect(!context.currentIndentation.isEmpty)
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLContextSnapshotTests {
        @Test("HTML.Context stylesheet rendering snapshot")
        func stylesheetRenderingSnapshot() {
            // This tests the stylesheet generation through actual rendering
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div") {
                        HTML.Text("Styled content")
                    }
                    .inlineStyle("color", "red")
                    .inlineStyle("padding", "10px")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      .color-0{color:red}
                      .padding-1{padding:10px}
                    </style>
                  </head>
                  <body>
                    <div class="color-0 padding-1">Styled content
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}
