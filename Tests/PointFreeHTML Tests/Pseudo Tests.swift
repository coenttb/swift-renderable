//
//  PseudoTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite(
    "Pseudo Tests",
    .snapshots(record: .missing)
)
struct PseudoTests {

    @Test("Pseudo class creation")
    func pseudoClassCreation() throws {
        let hover = Pseudo.hover
        let active = Pseudo.active
        let focus = Pseudo.focus

        // Test that pseudo classes can be created
        #expect(hover.rawValue == ":hover")
        #expect(active.rawValue == ":active")
        #expect(focus.rawValue == ":focus")
    }

    @Test("Pseudo element creation")
    func pseudoElementCreation() throws {
        let before = Pseudo.before
        let after = Pseudo.after
        let firstLine = Pseudo.firstLine

        #expect(before.rawValue == "::before")
        #expect(after.rawValue == "::after")
        #expect(firstLine.rawValue == "::first-line")
    }

    @Test("Structural pseudo classes")
    func structuralPseudoClasses() throws {
        let firstChild = Pseudo.firstChild
        let lastChild = Pseudo.lastChild
        let nthChild = Pseudo.nthChild(2)

        #expect(firstChild.rawValue == ":first-child")
        #expect(lastChild.rawValue == ":last-child")
        #expect(nthChild.rawValue == ":nth-child(2)")
    }

    @Test("Form pseudo classes")
    func formPseudoClasses() throws {
        let checked = Pseudo.checked
        let disabled = Pseudo.disabled
        let enabled = Pseudo.enabled
        let required = Pseudo.required

        #expect(checked.rawValue == ":checked")
        #expect(disabled.rawValue == ":disabled")
        #expect(enabled.rawValue == ":enabled")
        #expect(required.rawValue == ":required")
    }

    @Test("Custom pseudo selector")
    func customPseudoSelector() throws {
        let custom = Pseudo(":not(.hidden)")

        #expect(custom.rawValue == ":not(.hidden)")
    }

    @Test("Pseudo with nth functions")
    func pseudoWithNthFunctions() throws {
        let nthOfType = Pseudo.nthOfType(3)
        let nthLastChild = Pseudo.nthLastChild(1)

        #expect(nthOfType.rawValue == ":nth-of-type(3)")
        #expect(nthLastChild.rawValue == ":nth-last-child(1)")
    }

    @Test("Pseudo equality")
    func pseudoEquality() throws {
        let hover1 = Pseudo.hover
        let hover2 = Pseudo.hover
        let active = Pseudo.active

        #expect(hover1.rawValue == hover2.rawValue)
        #expect(hover1.rawValue != active.rawValue)
    }

    @Test("Pseudo + operator - combining pseudo-classes")
    func pseudoCombiningClasses() throws {
        let hoverFocus = Pseudo.hover + Pseudo.focus
        let activeVisited = Pseudo.active + Pseudo.visited

        #expect(hoverFocus.rawValue == ":hover:focus")
        #expect(activeVisited.rawValue == ":active:visited")
    }

    @Test("Pseudo + operator - combining pseudo-elements")
    func pseudoCombiningElements() throws {
        let beforeAfter = Pseudo.before + Pseudo.after

        // Note: This creates an invalid CSS selector, but tests the operator
        #expect(beforeAfter.rawValue == "::before::after")
    }

    @Test("Pseudo + operator - mixing classes and elements")
    func pseudoMixingClassesAndElements() throws {
        let hoverBefore = Pseudo.hover + Pseudo.before
        let focusAfter = Pseudo.focus + Pseudo.after

        #expect(hoverBefore.rawValue == ":hover::before")
        #expect(focusAfter.rawValue == ":focus::after")
    }

    @Test("Pseudo + operator - chaining multiple")
    func pseudoChainingMultiple() throws {
        let complex = Pseudo.hover + Pseudo.focus + Pseudo.active

        #expect(complex.rawValue == ":hover:focus:active")
    }

    @Test("Pseudo + operator - with nth functions")
    func pseudoCombiningWithNthFunctions() throws {
        let nthChildHover = Pseudo.nthChild(2) + Pseudo.hover
        let firstChildFocus = Pseudo.firstChild + Pseudo.focus

        #expect(nthChildHover.rawValue == ":nth-child(2):hover")
        #expect(firstChildFocus.rawValue == ":first-child:focus")
    }

    @Test("Pseudo + operator - with custom pseudo")
    func pseudoCombiningWithCustom() throws {
        let customPseudo = Pseudo(rawValue: ":not(.hidden)")
        let customHover = customPseudo + Pseudo.hover
        let hoverCustom = Pseudo.hover + customPseudo

        #expect(customHover.rawValue == ":not(.hidden):hover")
        #expect(hoverCustom.rawValue == ":hover:not(.hidden)")
    }

    @Test("HTML align-content with prefix renders properly")
    func htmlAlignContentWithPrefixRendersCorrectly() {
        assertInlineSnapshot(
            of: HTMLDocument {
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
            .align-content-QxtfK3::after{align-content:space-between}

                </style>
              </head>
              <body>
            <div class="align-content-QxtfK3">
            </div>
              </body>
            </html>
            """
        }
    }
}
