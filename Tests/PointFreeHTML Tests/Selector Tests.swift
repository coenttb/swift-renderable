//
//  SelectorTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("Selector Tests")
struct SelectorTests {

    // MARK: - Basic Creation Tests

    @Test("Basic selector creation")
    func basicSelectorCreation() {
        let selector = HTML.Selector(rawValue: "div")
        #expect(selector.rawValue == "div")

        let stringLiteralSelector: HTML.Selector = "span"
        #expect(stringLiteralSelector.rawValue == "span")
    }

    @Test("Selector equality")
    func selectorEquality() {
        let selector1: HTML.Selector = "div"
        let selector2: HTML.Selector = "div"
        let selector3: HTML.Selector = "span"

        #expect(selector1 == selector2)
        #expect(selector1 != selector3)
    }

    // MARK: - HTML Element Tests

    @Test("Document structure elements")
    func documentStructureElements() {
        let html: HTML.Selector = "html"
        let head: HTML.Selector = "head"
        let body: HTML.Selector = "body"
        let title: HTML.Selector = "title"
        let meta: HTML.Selector = "meta"
        let link: HTML.Selector = "link"
        let style: HTML.Selector = "style"
        let script: HTML.Selector = "script"

        #expect(html.rawValue == "html")
        #expect(head.rawValue == "head")
        #expect(body.rawValue == "body")
        #expect(title.rawValue == "title")
        #expect(meta.rawValue == "meta")
        #expect(link.rawValue == "link")
        #expect(style.rawValue == "style")
        #expect(script.rawValue == "script")
    }

    @Test("Content sectioning elements")
    func contentSectioningElements() {
        let header: HTML.Selector = "header"
        let nav: HTML.Selector = "nav"
        let main: HTML.Selector = "main"
        let section: HTML.Selector = "section"
        let article: HTML.Selector = "article"
        let aside: HTML.Selector = "aside"
        let footer: HTML.Selector = "footer"
        let h1: HTML.Selector = "h1"
        let h2: HTML.Selector = "h2"
        let h3: HTML.Selector = "h3"
        let h4: HTML.Selector = "h4"
        let h5: HTML.Selector = "h5"
        let h6: HTML.Selector = "h6"

        #expect(header.rawValue == "header")
        #expect(nav.rawValue == "nav")
        #expect(main.rawValue == "main")
        #expect(section.rawValue == "section")
        #expect(article.rawValue == "article")
        #expect(aside.rawValue == "aside")
        #expect(footer.rawValue == "footer")
        #expect(h1.rawValue == "h1")
        #expect(h2.rawValue == "h2")
        #expect(h3.rawValue == "h3")
        #expect(h4.rawValue == "h4")
        #expect(h5.rawValue == "h5")
        #expect(h6.rawValue == "h6")
    }

    @Test("Text content elements")
    func textContentElements() {
        let div: HTML.Selector = "div"
        let p: HTML.Selector = "p"
        let span: HTML.Selector = "span"
        let a: HTML.Selector = "a"
        let strong: HTML.Selector = "strong"
        let em: HTML.Selector = "em"
        let code: HTML.Selector = "code"
        let pre: HTML.Selector = "pre"

        #expect(div.rawValue == "div")
        #expect(p.rawValue == "p")
        #expect(span.rawValue == "span")
        #expect(a.rawValue == "a")
        #expect(strong.rawValue == "strong")
        #expect(em.rawValue == "em")
        #expect(code.rawValue == "code")
        #expect(pre.rawValue == "pre")
    }

    @Test("Form elements")
    func formElements() {
        let form: HTML.Selector = "form"
        let input: HTML.Selector = "input"
        let textarea: HTML.Selector = "textarea"
        let button: HTML.Selector = "button"
        let select: HTML.Selector = "select"
        let option: HTML.Selector = "option"
        let label: HTML.Selector = "label"

        #expect(form.rawValue == "form")
        #expect(input.rawValue == "input")
        #expect(textarea.rawValue == "textarea")
        #expect(button.rawValue == "button")
        #expect(select.rawValue == "select")
        #expect(option.rawValue == "option")
        #expect(label.rawValue == "label")
    }

    @Test("Table elements")
    func tableElements() {
        let table: HTML.Selector = "table"
        let thead: HTML.Selector = "thead"
        let tbody: HTML.Selector = "tbody"
        let tfoot: HTML.Selector = "tfoot"
        let tr: HTML.Selector = "tr"
        let td: HTML.Selector = "td"
        let th: HTML.Selector = "th"

        #expect(table.rawValue == "table")
        #expect(thead.rawValue == "thead")
        #expect(tbody.rawValue == "tbody")
        #expect(tfoot.rawValue == "tfoot")
        #expect(tr.rawValue == "tr")
        #expect(td.rawValue == "td")
        #expect(th.rawValue == "th")
    }

    // MARK: - Combinator Method Tests

    @Test("Descendant combinator method")
    func descendantCombinatorMethod() {
        let span: HTML.Selector = "span"
        let div: HTML.Selector = "div"
        let result = span.descendant(of: div)
        #expect(result.rawValue == "div span")
    }

    @Test("Child combinator method")
    func childCombinatorMethod() {
        let p: HTML.Selector = "p"
        let div: HTML.Selector = "div"
        let result = p.child(of: div)
        #expect(result.rawValue == "div > p")
    }

    @Test("Next sibling combinator method")
    func nextSiblingCombinatorMethod() {
        let p: HTML.Selector = "p"
        let h1: HTML.Selector = "h1"
        let result = p.nextSibling(of: h1)
        #expect(result.rawValue == "h1 + p")

        // Test alias
        let aliasResult = p.adjacent(to: h1)
        #expect(aliasResult.rawValue == "h1 + p")
    }

    @Test("Subsequent sibling combinator method")
    func subsequentSiblingCombinatorMethod() {
        let li: HTML.Selector = "li"
        let result = li.subsequentSibling(of: li)
        #expect(result.rawValue == "li ~ li")

        // Test alias
        let aliasResult = li.sibling(of: li)
        #expect(aliasResult.rawValue == "li ~ li")
    }

    @Test("Column combinator method")
    func columnCombinatorMethod() {
        let td: HTML.Selector = "td"
        let col: HTML.Selector = "col"
        let result = td.column(of: col)
        #expect(result.rawValue == "col || td")
    }

    // MARK: - Method-Based API Tests

    @Test("Child combinator method")
    func childCombinatorMethodAPI() {
        let div: HTML.Selector = "div"
        let p: HTML.Selector = "p"
        let result = p.child(of: div)
        #expect(result.rawValue == "div > p")
    }

    @Test("Next sibling combinator method")
    func nextSiblingCombinatorMethodAPI() {
        let h1: HTML.Selector = "h1"
        let p: HTML.Selector = "p"
        let result = p.nextSibling(of: h1)
        #expect(result.rawValue == "h1 + p")
    }

    @Test("Subsequent sibling combinator method")
    func subsequentSiblingCombinatorMethodAPI() {
        let li: HTML.Selector = "li"
        let result = li.subsequentSibling(of: li)
        #expect(result.rawValue == "li ~ li")
    }

    @Test("Column combinator method")
    func columnCombinatorMethodAPI() {
        let col: HTML.Selector = "col"
        let td: HTML.Selector = "td"
        let result = td.column(of: col)
        #expect(result.rawValue == "col || td")
    }

    @Test("Selector list method")
    func selectorListMethod() {
        let h1: HTML.Selector = "h1"
        let h2: HTML.Selector = "h2"
        let result = h1.or(h2)
        #expect(result.rawValue == "h1, h2")
    }

    @Test("Multiple selector list method")
    func multipleSelectorListMethod() {
        let h1: HTML.Selector = "h1"
        let h2: HTML.Selector = "h2"
        let h3: HTML.Selector = "h3"
        let result = h1.or(h2, h3)
        #expect(result.rawValue == "h1, h2, h3")
    }

    @Test("Compound selector method")
    func compoundSelectorMethod() {
        let div: HTML.Selector = "div"
        let result = div.and(HTML.Selector.class("header"))
        #expect(result.rawValue == "div.header")
    }

    // MARK: - Complex Combinator Tests

    @Test("Complex combinator chains using methods")
    func complexCombinatorChainsUsingMethods() {
        let div: HTML.Selector = "div"
        let h1: HTML.Selector = "h1"
        let p: HTML.Selector = "p"
        let nav: HTML.Selector = "nav"
        let li: HTML.Selector = "li"
        let a: HTML.Selector = "a"
        let table: HTML.Selector = "table"
        let tbody: HTML.Selector = "tbody"
        let tr: HTML.Selector = "tr"

        // div > h1 + p (using methods)
        let nextSiblingPart = p.nextSibling(of: h1)  // h1 + p
        let result1 = nextSiblingPart.child(of: div)  // div > (h1 + p)
        #expect(result1.rawValue == "div > h1 + p")

        // nav li a (using descendant)
        let liPart = li.descendant(of: nav)  // nav li
        let result2 = a.descendant(of: liPart)  // nav li a
        #expect(result2.rawValue == "nav li a")

        // table > tbody > tr ~ tr (using methods)
        let tbodyPart = tbody.child(of: table)  // table > tbody
        let trPart = tr.child(of: tbodyPart)  // table > tbody > tr
        let result3 = tr.subsequentSibling(of: trPart)  // table > tbody > tr ~ tr
        #expect(result3.rawValue == "table > tbody > tr ~ tr")
    }

    // MARK: - Attribute Selector Tests

    @Test("Attribute exists selector")
    func attributeExistsSelector() {
        let result = HTML.Selector.hasAttribute("disabled")
        #expect(result.rawValue == "[disabled]")
    }

    @Test("Attribute equals selector")
    func attributeEqualsSelector() {
        let result = HTML.Selector.attribute("type", equals: "submit")
        #expect(result.rawValue == "[type=\"submit\"]")
    }

    @Test("Attribute contains word selector")
    func attributeContainsWordSelector() {
        let result = HTML.Selector.attribute("class", containsWord: "active")
        #expect(result.rawValue == "[class~=\"active\"]")
    }

    @Test("Attribute starts with selector")
    func attributeStartsWithSelector() {
        let result = HTML.Selector.attribute("href", startsWith: "https")
        #expect(result.rawValue == "[href^=\"https\"]")
    }

    @Test("Attribute ends with selector")
    func attributeEndsWithSelector() {
        let result = HTML.Selector.attribute("src", endsWith: ".jpg")
        #expect(result.rawValue == "[src$=\".jpg\"]")
    }

    @Test("Attribute contains substring selector")
    func attributeContainsSubstringSelector() {
        let result = HTML.Selector.attribute("title", contains: "example")
        #expect(result.rawValue == "[title*=\"example\"]")
    }

    @Test("Attribute starts with or hyphen selector")
    func attributeStartsWithOrHyphenSelector() {
        let result = HTML.Selector.attribute("lang", startsWithOrHyphen: "en")
        #expect(result.rawValue == "[lang|=\"en\"]")
    }

    // MARK: - Class and ID Selector Tests

    @Test("Class selector")
    func classSelector() {
        let result = HTML.Selector.class("header")
        #expect(result.rawValue == ".header")
    }

    @Test("ID selector")
    func idSelector() {
        let result = HTML.Selector.id("main")
        #expect(result.rawValue == "#main")
    }

    // MARK: - Input Type Tests

    @Test("Generic input type selector")
    func genericInputTypeSelector() {
        let result = HTML.Selector.inputType("email")
        #expect(result.rawValue == "input[type=\"email\"]")
    }

    @Test("Predefined input type selectors")
    func predefinedInputTypeSelectors() {
        let inputText = HTML.Selector.inputText
        let inputPassword = HTML.Selector.inputPassword
        let inputEmail = HTML.Selector.inputEmail
        let inputSubmit = HTML.Selector.inputSubmit
        let inputCheckbox = HTML.Selector.inputCheckbox
        let inputRadio = HTML.Selector.inputRadio

        #expect(inputText.rawValue == "input[type=\"text\"]")
        #expect(inputPassword.rawValue == "input[type=\"password\"]")
        #expect(inputEmail.rawValue == "input[type=\"email\"]")
        #expect(inputSubmit.rawValue == "input[type=\"submit\"]")
        #expect(inputCheckbox.rawValue == "input[type=\"checkbox\"]")
        #expect(inputRadio.rawValue == "input[type=\"radio\"]")
    }

    // MARK: - Convenience Method Tests

    @Test("withClass convenience method")
    func withClassConvenienceMethod() {
        let div: HTML.Selector = "div"
        let result = div.withClass("container")
        #expect(result.rawValue == "div.container")
    }

    @Test("withId convenience method")
    func withIdConvenienceMethod() {
        let div: HTML.Selector = "div"
        let result = div.withId("main")
        #expect(result.rawValue == "div#main")
    }

    @Test("withAttribute convenience method")
    func withAttributeConvenienceMethod() {
        let input: HTML.Selector = "input"
        let result = input.withAttribute("type", equals: "submit")
        #expect(result.rawValue == "input[type=\"submit\"]")
    }

    @Test("withPseudo convenience method")
    func withPseudoConvenienceMethod() {
        let a: HTML.Selector = "a"
        let result = a.withPseudo(.hover)
        #expect(result.rawValue == "a:hover")
    }

    @Test("Chained convenience methods")
    func chainedConvenienceMethods() {
        let div: HTML.Selector = "div"
        let result = div.withClass("card").withId("header").withAttribute("role", equals: "banner")
        #expect(result.rawValue == "div.card#header[role=\"banner\"]")
    }

    // MARK: - Universal and Namespace Tests

    @Test("Universal selector")
    func universalSelector() {
        #expect(HTML.Selector.universal.rawValue == "*")
    }

    @Test("Namespace method")
    func namespaceMethod() {
        let circle: HTML.Selector = "circle"
        let result = circle.namespace("svg")
        #expect(result.rawValue == "svg|circle")
    }

    @Test("Namespace static method")
    func namespaceStaticMethod() {
        let circle: HTML.Selector = "circle"
        let result = HTML.Selector.namespace("svg", element: circle)
        #expect(result.rawValue == "svg|circle")
    }

    // MARK: - Complex Real-World Examples

    @Test("Complex attribute and pseudo combinations")
    func complexAttributeAndPseudoCombinations() {
        // input[type="text"]:not(:disabled):focus
        let focusedEnabledInput = HTML.Selector.inputText.withPseudo(.not(.disabled)).withPseudo(.focus)
        #expect(focusedEnabledInput.rawValue == "input[type=\"text\"]:not(:disabled):focus")
    }
}

// MARK: - Snapshot Tests

extension `Snapshot Tests` {
    @Suite
    struct SelectorSnapshotTests {
        @Test("HTML align-content with prefix renders properly")
        func htmlAlignContentWithPrefixRendersCorrectly() {
            assertInlineSnapshot(
                of: HTML.Document {
                    tag("div")
                        .inlineStyle("align-content", "space-between", selector: "my-component")
                },
                as: .html
            ) {
                """
                <!doctype html>
                <html>
                  <head>
                    <style>
                      my-component .align-content-0{align-content:space-between}
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
