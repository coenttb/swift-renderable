//
//  HTMLContext Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("HTMLContext Tests")
struct HTMLContextTests {

    // MARK: - Initialization

    @Test("HTMLContext default initialization")
    func defaultInitialization() {
        let context = HTMLContext()
        #expect(context.attributes.isEmpty)
        #expect(context.styles.isEmpty)
        #expect(context.currentIndentation.isEmpty)
    }

    @Test("HTMLContext with custom configuration")
    func customConfigurationInitialization() {
        let config = HTMLPrinter.Configuration.pretty
        let context = HTMLContext(config)
        #expect(context.configuration.indentation == config.indentation)
        #expect(context.configuration.newline == config.newline)
    }

    // MARK: - Class Name Generation

    @Test("HTMLContext generates deterministic class names")
    func deterministicClassNames() {
        var context = HTMLContext()
        let style1 = Style(property: "color", value: "red", atRule: nil, selector: nil, pseudo: nil)
        let style2 = Style(property: "margin", value: "10px", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context.className(for: style1)
        let name2 = context.className(for: style2)

        #expect(name1 == "color-0")
        #expect(name2 == "margin-1")
    }

    @Test("HTMLContext returns same name for same style")
    func sameNameForSameStyle() {
        var context = HTMLContext()
        let style = Style(property: "color", value: "blue", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context.className(for: style)
        let name2 = context.className(for: style)

        #expect(name1 == name2)
    }

    @Test("HTMLContext different contexts generate independent names")
    func independentContexts() {
        var context1 = HTMLContext()
        var context2 = HTMLContext()
        let style = Style(property: "color", value: "green", atRule: nil, selector: nil, pseudo: nil)

        let name1 = context1.className(for: style)
        let name2 = context2.className(for: style)

        // Both should be color-0 since they're independent contexts
        #expect(name1 == "color-0")
        #expect(name2 == "color-0")
    }

    @Test("HTMLContext classNames batch method")
    func classNamesBatch() {
        var context = HTMLContext()
        let styles = [
            Style(property: "color", value: "red", atRule: nil, selector: nil, pseudo: nil),
            Style(property: "font-size", value: "16px", atRule: nil, selector: nil, pseudo: nil),
            Style(property: "padding", value: "10px", atRule: nil, selector: nil, pseudo: nil)
        ]

        let names = context.classNames(for: styles)

        #expect(names.count == 3)
        #expect(names[0] == "color-0")
        #expect(names[1] == "font-size-1")
        #expect(names[2] == "padding-2")
    }

    // MARK: - Stylesheet Generation

    @Test("HTMLContext empty stylesheet")
    func emptyStylesheet() {
        let context = HTMLContext()
        let stylesheet = context.stylesheet
        // Empty stylesheet is empty
        #expect(stylesheet.isEmpty)
    }

    @Test("HTMLContext stylesheet with styles")
    func stylesheetWithStyles() {
        var context = HTMLContext()
        let styleKey = StyleKey(nil, ".test-class")
        context.styles[styleKey] = "color: red"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains(".test-class{color: red}"))
    }

    @Test("HTMLContext stylesheet with media query")
    func stylesheetWithMediaQuery() {
        var context = HTMLContext()
        let atRule = AtRule(rawValue: "@media (max-width: 768px)")
        let styleKey = StyleKey(atRule, ".mobile-class")
        context.styles[styleKey] = "display: none"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains("@media (max-width: 768px)"))
        #expect(stylesheet.contains(".mobile-class{display: none}"))
    }

    @Test("HTMLContext stylesheet with forceImportant")
    func stylesheetWithForceImportant() {
        var config = HTMLPrinter.Configuration.default
        config = HTMLPrinter.Configuration(
            forceImportant: true,
            indentation: config.indentation,
            newline: config.newline,
            reservedCapacity: config.reservedCapacity
        )
        var context = HTMLContext(config)
        let styleKey = StyleKey(nil, ".important-class")
        context.styles[styleKey] = "color: blue"

        let stylesheet = context.stylesheet
        #expect(stylesheet.contains("!important"))
    }

    // MARK: - Attributes

    @Test("HTMLContext attribute storage")
    func attributeStorage() {
        var context = HTMLContext()
        context.attributes["class"] = "test-class"
        context.attributes["id"] = "test-id"

        #expect(context.attributes["class"] == "test-class")
        #expect(context.attributes["id"] == "test-id")
        #expect(context.attributes.count == 2)
    }

    @Test("HTMLContext attributes preserve order")
    func attributesPreserveOrder() {
        var context = HTMLContext()
        context.attributes["a"] = "first"
        context.attributes["b"] = "second"
        context.attributes["c"] = "third"

        let keys = Array(context.attributes.keys)
        #expect(keys == ["a", "b", "c"])
    }

    // MARK: - Indentation

    @Test("HTMLContext indentation tracking")
    func indentationTracking() {
        var context = HTMLContext(.pretty)
        #expect(context.currentIndentation.isEmpty)

        context.currentIndentation.append(contentsOf: context.configuration.indentation)
        #expect(!context.currentIndentation.isEmpty)
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct HTMLContextSnapshotTests {
        @Test("HTMLContext stylesheet rendering snapshot")
        func stylesheetRenderingSnapshot() {
            // This tests the stylesheet generation through actual rendering
            assertInlineSnapshot(
                of: HTMLDocument {
                    tag("div") {
                        HTMLText("Styled content")
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
