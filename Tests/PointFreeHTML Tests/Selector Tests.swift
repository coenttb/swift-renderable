//
//  SelectorTests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 20/07/2025.
//

import PointFreeHTML
import Testing
import PointFreeHTMLTestSupport

@Suite(
    "Selector Tests",
    .snapshots(record: .missing)
)
struct SelectorTests {
    
    // MARK: - Basic Creation Tests
    
    @Test("Basic selector creation")
    func basicSelectorCreation() {
        let selector = Selector(rawValue: "div")
        #expect(selector.rawValue == "div")
        
        let stringLiteralSelector: Selector = "span"
        #expect(stringLiteralSelector.rawValue == "span")
    }
    
    @Test("Selector equality")
    func selectorEquality() {
        let selector1: Selector = "div"
        let selector2: Selector = "div"
        let selector3: Selector = "span"
        
        #expect(selector1 == selector2)
        #expect(selector1 != selector3)
    }
    
    // MARK: - HTML Element Tests
    
    @Test("Document structure elements")
    func documentStructureElements() {
        let html: Selector = "html"
        let head: Selector = "head"
        let body: Selector = "body"
        let title: Selector = "title"
        let meta: Selector = "meta"
        let link: Selector = "link"
        let style: Selector = "style"
        let script: Selector = "script"
        
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
        let header: Selector = "header"
        let nav: Selector = "nav"
        let main: Selector = "main"
        let section: Selector = "section"
        let article: Selector = "article"
        let aside: Selector = "aside"
        let footer: Selector = "footer"
        let h1: Selector = "h1"
        let h2: Selector = "h2"
        let h3: Selector = "h3"
        let h4: Selector = "h4"
        let h5: Selector = "h5"
        let h6: Selector = "h6"
        
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
        let div: Selector = "div"
        let p: Selector = "p"
        let span: Selector = "span"
        let a: Selector = "a"
        let strong: Selector = "strong"
        let em: Selector = "em"
        let code: Selector = "code"
        let pre: Selector = "pre"
        
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
        let form: Selector = "form"
        let input: Selector = "input"
        let textarea: Selector = "textarea"
        let button: Selector = "button"
        let select: Selector = "select"
        let option: Selector = "option"
        let label: Selector = "label"
        
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
        let table: Selector = "table"
        let thead: Selector = "thead"
        let tbody: Selector = "tbody"
        let tfoot: Selector = "tfoot"
        let tr: Selector = "tr"
        let td: Selector = "td"
        let th: Selector = "th"
        
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
        let span: Selector = "span"
        let div: Selector = "div"
        let result = span.descendant(of: div)
        #expect(result.rawValue == "div span")
    }
    
    @Test("Child combinator method")
    func childCombinatorMethod() {
        let p: Selector = "p"
        let div: Selector = "div"
        let result = p.child(of: div)
        #expect(result.rawValue == "div > p")
    }
    
    @Test("Next sibling combinator method")
    func nextSiblingCombinatorMethod() {
        let p: Selector = "p"
        let h1: Selector = "h1"
        let result = p.nextSibling(of: h1)
        #expect(result.rawValue == "h1 + p")
        
        // Test alias
        let aliasResult = p.adjacent(to: h1)
        #expect(aliasResult.rawValue == "h1 + p")
    }
    
    @Test("Subsequent sibling combinator method")
    func subsequentSiblingCombinatorMethod() {
        let li: Selector = "li"
        let result = li.subsequentSibling(of: li)
        #expect(result.rawValue == "li ~ li")
        
        // Test alias
        let aliasResult = li.sibling(of: li)
        #expect(aliasResult.rawValue == "li ~ li")
    }
    
    @Test("Column combinator method")
    func columnCombinatorMethod() {
        let td: Selector = "td"
        let col: Selector = "col"
        let result = td.column(of: col)
        #expect(result.rawValue == "col || td")
    }
    
    // MARK: - Method-Based API Tests
    
    @Test("Child combinator method")
    func childCombinatorMethodAPI() {
        let div: Selector = "div"
        let p: Selector = "p"
        let result = p.child(of: div)
        #expect(result.rawValue == "div > p")
    }
    
    @Test("Next sibling combinator method")
    func nextSiblingCombinatorMethodAPI() {
        let h1: Selector = "h1"
        let p: Selector = "p"
        let result = p.nextSibling(of: h1)
        #expect(result.rawValue == "h1 + p")
    }
    
    @Test("Subsequent sibling combinator method")
    func subsequentSiblingCombinatorMethodAPI() {
        let li: Selector = "li"
        let result = li.subsequentSibling(of: li)
        #expect(result.rawValue == "li ~ li")
    }
    
    @Test("Column combinator method")
    func columnCombinatorMethodAPI() {
        let col: Selector = "col"
        let td: Selector = "td"
        let result = td.column(of: col)
        #expect(result.rawValue == "col || td")
    }
    
    @Test("Selector list method")
    func selectorListMethod() {
        let h1: Selector = "h1"
        let h2: Selector = "h2"
        let result = h1.or(h2)
        #expect(result.rawValue == "h1, h2")
    }
    
    @Test("Multiple selector list method")
    func multipleSelectorListMethod() {
        let h1: Selector = "h1"
        let h2: Selector = "h2"
        let h3: Selector = "h3"
        let result = h1.or(h2, h3)
        #expect(result.rawValue == "h1, h2, h3")
    }
    
    @Test("Compound selector method")
    func compoundSelectorMethod() {
        let div: Selector = "div"
        let result = div.and(Selector.class("header"))
        #expect(result.rawValue == "div.header")
    }
    
    // MARK: - Complex Combinator Tests
    
    @Test("Complex combinator chains using methods")
    func complexCombinatorChainsUsingMethods() {
        let div: Selector = "div"
        let h1: Selector = "h1"
        let p: Selector = "p"
        let nav: Selector = "nav"
        let li: Selector = "li"
        let a: Selector = "a"
        let table: Selector = "table"
        let tbody: Selector = "tbody"
        let tr: Selector = "tr"
        
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
        let result = Selector.hasAttribute("disabled")
        #expect(result.rawValue == "[disabled]")
    }
    
    @Test("Attribute equals selector")
    func attributeEqualsSelector() {
        let result = Selector.attribute("type", equals: "submit")
        #expect(result.rawValue == "[type=\"submit\"]")
    }
    
    @Test("Attribute contains word selector")
    func attributeContainsWordSelector() {
        let result = Selector.attribute("class", containsWord: "active")
        #expect(result.rawValue == "[class~=\"active\"]")
    }
    
    @Test("Attribute starts with selector")
    func attributeStartsWithSelector() {
        let result = Selector.attribute("href", startsWith: "https")
        #expect(result.rawValue == "[href^=\"https\"]")
    }
    
    @Test("Attribute ends with selector")
    func attributeEndsWithSelector() {
        let result = Selector.attribute("src", endsWith: ".jpg")
        #expect(result.rawValue == "[src$=\".jpg\"]")
    }
    
    @Test("Attribute contains substring selector")
    func attributeContainsSubstringSelector() {
        let result = Selector.attribute("title", contains: "example")
        #expect(result.rawValue == "[title*=\"example\"]")
    }
    
    @Test("Attribute starts with or hyphen selector")
    func attributeStartsWithOrHyphenSelector() {
        let result = Selector.attribute("lang", startsWithOrHyphen: "en")
        #expect(result.rawValue == "[lang|=\"en\"]")
    }
    
    // MARK: - Class and ID Selector Tests
    
    @Test("Class selector")
    func classSelector() {
        let result = Selector.class("header")
        #expect(result.rawValue == ".header")
    }
    
    @Test("ID selector")
    func idSelector() {
        let result = Selector.id("main")
        #expect(result.rawValue == "#main")
    }
    
    // MARK: - Input Type Tests
    
    @Test("Generic input type selector")
    func genericInputTypeSelector() {
        let result = Selector.inputType("email")
        #expect(result.rawValue == "input[type=\"email\"]")
    }
    
    @Test("Predefined input type selectors")
    func predefinedInputTypeSelectors() {
        let inputText = Selector.inputText
        let inputPassword = Selector.inputPassword
        let inputEmail = Selector.inputEmail
        let inputSubmit = Selector.inputSubmit
        let inputCheckbox = Selector.inputCheckbox
        let inputRadio = Selector.inputRadio
        
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
        let div: Selector = "div"
        let result = div.withClass("container")
        #expect(result.rawValue == "div.container")
    }
    
    @Test("withId convenience method")
    func withIdConvenienceMethod() {
        let div: Selector = "div"
        let result = div.withId("main")
        #expect(result.rawValue == "div#main")
    }
    
    @Test("withAttribute convenience method")
    func withAttributeConvenienceMethod() {
        let input: Selector = "input"
        let result = input.withAttribute("type", equals: "submit")
        #expect(result.rawValue == "input[type=\"submit\"]")
    }
    
    @Test("withPseudo convenience method")
    func withPseudoConvenienceMethod() {
        let a: Selector = "a"
        let result = a.withPseudo(.hover)
        #expect(result.rawValue == "a:hover")
    }
    
    @Test("Chained convenience methods")
    func chainedConvenienceMethods() {
        let div: Selector = "div"
        let result = div.withClass("card").withId("header").withAttribute("role", equals: "banner")
        #expect(result.rawValue == "div.card#header[role=\"banner\"]")
    }
    
    // MARK: - Universal and Namespace Tests
    
    @Test("Universal selector")
    func universalSelector() {
        #expect(Selector.universal.rawValue == "*")
    }
    
    @Test("Namespace method")
    func namespaceMethod() {
        let circle: Selector = "circle"
        let result = circle.namespace("svg")
        #expect(result.rawValue == "svg|circle")
    }
    
    @Test("Namespace static method")
    func namespaceStaticMethod() {
        let circle: Selector = "circle"
        let result = Selector.namespace("svg", element: circle)
        #expect(result.rawValue == "svg|circle")
    }
    
    // MARK: - Complex Real-World Examples
    
//    @Test("Complex real-world selectors")
//    func complexRealWorldSelectors() {
//        // nav > ul > li:first-child > a
//        let navLink: Selector = Selector.nav > Selector.ul > Selector.li.withPseudo(.firstChild) > Selector.a
//        #expect(navLink.rawValue == "nav > ul > li:first-child > a")
//        
//        // form input[type="email"]:focus, form input[type="password"]:focus  
//        let focusedInputs: Selector = (Selector.form >> Selector.inputEmail.withPseudo(.focus)) |
//                           (Selector.form >> Selector.inputPassword.withPseudo(.focus))
//        #expect(focusedInputs.rawValue == "form input[type=\"email\"]:focus, form input[type=\"password\"]:focus")
//        
//        // table.data-table > tbody > tr:nth-child(odd) > td
//        let oddTableRows: Selector = Selector.table.withClass("data-table") > Selector.tbody >
//                          Selector.tr.withPseudo(.nthChild("odd")) > Selector.td
//        #expect(oddTableRows.rawValue == "table.data-table > tbody > tr:nth-child(odd) > td")
//        
//        // div.modal#settings[aria-hidden="false"]
//        let visibleModal = Selector.div.withClass("modal").withId("settings").withAttribute("aria-hidden", equals: "false")
//        #expect(visibleModal.rawValue == "div.modal#settings[aria-hidden=\"false\"]")
//    }
//    
//    @Test("Selector with multiple classes")
//    func selectorWithMultipleClasses() {
//        let result = Selector.div.withClass("btn").withClass("btn-primary").withClass("active")
//        #expect(result.rawValue == "div.btn.btn-primary.active")
//    }
    
    @Test("Complex attribute and pseudo combinations")
    func complexAttributeAndPseudoCombinations() {
        // input[type="text"]:not(:disabled):focus
        let focusedEnabledInput = Selector.inputText.withPseudo(.not(.disabled)).withPseudo(.focus)
        #expect(focusedEnabledInput.rawValue == "input[type=\"text\"]:not(:disabled):focus")
    }
    
    @Test("HTML align-content with prefix renders properly")
    func htmlAlignContentWithPrefixRendersCorrectly() {
        assertInlineSnapshot(
            of: HTMLDocument {
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
            my-component .align-content-KzNip3{align-content:space-between}

                </style>
              </head>
              <body>
            <div class="align-content-KzNip3">
            </div>
              </body>
            </html>
            """
        }
    }
}
