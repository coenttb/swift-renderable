//
//  PseudoTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `Pseudo Tests` {

    @Test
    func `Pseudo class creation`() throws {
        let hover = HTML.Pseudo.hover
        let active = HTML.Pseudo.active
        let focus = HTML.Pseudo.focus

        // Test that pseudo classes can be created
        #expect(hover.rawValue == ":hover")
        #expect(active.rawValue == ":active")
        #expect(focus.rawValue == ":focus")
    }

    @Test
    func `Pseudo element creation`() throws {
        let before = HTML.Pseudo.before
        let after = HTML.Pseudo.after
        let firstLine = HTML.Pseudo.firstLine

        #expect(before.rawValue == "::before")
        #expect(after.rawValue == "::after")
        #expect(firstLine.rawValue == "::first-line")
    }

    @Test
    func `Structural pseudo classes`() throws {
        let firstChild = HTML.Pseudo.firstChild
        let lastChild = HTML.Pseudo.lastChild
        let nthChild = HTML.Pseudo.nthChild(2)

        #expect(firstChild.rawValue == ":first-child")
        #expect(lastChild.rawValue == ":last-child")
        #expect(nthChild.rawValue == ":nth-child(2)")
    }

    @Test
    func `Form pseudo classes`() throws {
        let checked = HTML.Pseudo.checked
        let disabled = HTML.Pseudo.disabled
        let enabled = HTML.Pseudo.enabled
        let required = HTML.Pseudo.required

        #expect(checked.rawValue == ":checked")
        #expect(disabled.rawValue == ":disabled")
        #expect(enabled.rawValue == ":enabled")
        #expect(required.rawValue == ":required")
    }

    @Test
    func `Custom pseudo selector`() throws {
        let custom = HTML.Pseudo(":not(.hidden)")

        #expect(custom.rawValue == ":not(.hidden)")
    }

    @Test
    func `Pseudo with nth functions`() throws {
        let nthOfType = HTML.Pseudo.nthOfType(3)
        let nthLastChild = HTML.Pseudo.nthLastChild(1)

        #expect(nthOfType.rawValue == ":nth-of-type(3)")
        #expect(nthLastChild.rawValue == ":nth-last-child(1)")
    }

    @Test
    func `Pseudo equality`() throws {
        let hover1 = HTML.Pseudo.hover
        let hover2 = HTML.Pseudo.hover
        let active = HTML.Pseudo.active

        #expect(hover1.rawValue == hover2.rawValue)
        #expect(hover1.rawValue != active.rawValue)
    }

    @Test
    func `Pseudo + operator - combining pseudo-classes`() throws {
        let hoverFocus = HTML.Pseudo.hover + HTML.Pseudo.focus
        let activeVisited = HTML.Pseudo.active + HTML.Pseudo.visited

        #expect(hoverFocus.rawValue == ":hover:focus")
        #expect(activeVisited.rawValue == ":active:visited")
    }

    @Test
    func `Pseudo + operator - combining pseudo-elements`() throws {
        let beforeAfter = HTML.Pseudo.before + HTML.Pseudo.after

        // Note: This creates an invalid CSS selector, but tests the operator
        #expect(beforeAfter.rawValue == "::before::after")
    }

    @Test
    func `Pseudo + operator - mixing classes and elements`() throws {
        let hoverBefore = HTML.Pseudo.hover + HTML.Pseudo.before
        let focusAfter = HTML.Pseudo.focus + HTML.Pseudo.after

        #expect(hoverBefore.rawValue == ":hover::before")
        #expect(focusAfter.rawValue == ":focus::after")
    }

    @Test
    func `Pseudo + operator - chaining multiple`() throws {
        let complex = HTML.Pseudo.hover + HTML.Pseudo.focus + HTML.Pseudo.active

        #expect(complex.rawValue == ":hover:focus:active")
    }

    @Test
    func `Pseudo + operator - with nth functions`() throws {
        let nthChildHover = HTML.Pseudo.nthChild(2) + HTML.Pseudo.hover
        let firstChildFocus = HTML.Pseudo.firstChild + HTML.Pseudo.focus

        #expect(nthChildHover.rawValue == ":nth-child(2):hover")
        #expect(firstChildFocus.rawValue == ":first-child:focus")
    }

    @Test
    func `Pseudo + operator - with custom pseudo`() throws {
        let customPseudo = HTML.Pseudo(rawValue: ":not(.hidden)")
        let customHover = customPseudo + HTML.Pseudo.hover
        let hoverCustom = HTML.Pseudo.hover + customPseudo

        #expect(customHover.rawValue == ":not(.hidden):hover")
        #expect(hoverCustom.rawValue == ":hover:not(.hidden)")
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct PseudoSnapshotTests {
        @Test
        func `HTML align-content with prefix renders properly`() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div")
                        .inlineStyle("align-content", "space-between", pseudo: .after)
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      .align-content-0::after{align-content:space-between}
                    </style>
                  </head>
                  <body>
                    <div class="align-content-0">
                    </div>
                  </body>
                </html>
                """
            }
        }
    }
}
