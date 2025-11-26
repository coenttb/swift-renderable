//
//  AtRule Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `AtRule Tests` {

    // MARK: - Initialization

    @Test
    func `AtRule basic initialization`() {
        let atRule = HTML.AtRule(rawValue: "@media print")
        #expect(atRule.rawValue == "@media print")
    }

    @Test
    func `AtRule with complex media query`() {
        let atRule = HTML.AtRule(rawValue: "@media (min-width: 768px) and (max-width: 1024px)")
        #expect(atRule.rawValue == "@media (min-width: 768px) and (max-width: 1024px)")
    }

    @Test
    func `AtRule with screen media`() {
        let atRule = HTML.AtRule(rawValue: "@media screen")
        #expect(atRule.rawValue == "@media screen")
    }

    // MARK: - RawRepresentable

    @Test
    func `AtRule RawRepresentable conformance`() {
        let atRule = HTML.AtRule(rawValue: "@media (hover: hover)")
        let recreated = HTML.AtRule(rawValue: atRule.rawValue)
        #expect(atRule == recreated)
    }

    // MARK: - Hashable

    @Test
    func `AtRule equality - same values`() {
        let atRule1 = HTML.AtRule(rawValue: "@media print")
        let atRule2 = HTML.AtRule(rawValue: "@media print")
        #expect(atRule1 == atRule2)
    }

    @Test
    func `AtRule equality - different values`() {
        let atRule1 = HTML.AtRule(rawValue: "@media print")
        let atRule2 = HTML.AtRule(rawValue: "@media screen")
        #expect(atRule1 != atRule2)
    }

    @Test
    func `AtRule in Set`() {
        var atRules = Set<HTML.AtRule>()
        let print = HTML.AtRule(rawValue: "@media print")
        let screen = HTML.AtRule(rawValue: "@media screen")
        let printDuplicate = HTML.AtRule(rawValue: "@media print")

        atRules.insert(print)
        atRules.insert(screen)
        atRules.insert(printDuplicate)

        #expect(atRules.count == 2)
    }

    @Test
    func `AtRule as dictionary key`() {
        var styles: [HTML.AtRule: String] = [:]
        let print = HTML.AtRule(rawValue: "@media print")
        let screen = HTML.AtRule(rawValue: "@media screen")

        styles[print] = "display: none"
        styles[screen] = "display: block"

        #expect(styles[print] == "display: none")
        #expect(styles[screen] == "display: block")
    }

    // MARK: - Sendable

    @Test
    func `AtRule is Sendable`() async {
        let atRule = HTML.AtRule(rawValue: "@media print")

        let result = await Task {
            atRule.rawValue
        }.value

        #expect(result == "@media print")
    }

    // MARK: - Common Media Queries

    @Test
    func `AtRule for prefers-color-scheme dark`() {
        let atRule = HTML.AtRule(rawValue: "@media (prefers-color-scheme: dark)")
        #expect(atRule.rawValue.contains("prefers-color-scheme"))
        #expect(atRule.rawValue.contains("dark"))
    }

    @Test
    func `AtRule for prefers-reduced-motion`() {
        let atRule = HTML.AtRule(rawValue: "@media (prefers-reduced-motion: reduce)")
        #expect(atRule.rawValue.contains("prefers-reduced-motion"))
    }

    @Test
    func `AtRule for orientation`() {
        let landscape = HTML.AtRule(rawValue: "@media (orientation: landscape)")
        let portrait = HTML.AtRule(rawValue: "@media (orientation: portrait)")
        #expect(landscape.rawValue.contains("landscape"))
        #expect(portrait.rawValue.contains("portrait"))
    }

    // MARK: - Breakpoints

    @Test
    func `AtRule for min-width breakpoint`() {
        let atRule = HTML.AtRule(rawValue: "@media (min-width: 1200px)")
        #expect(atRule.rawValue == "@media (min-width: 1200px)")
    }

    @Test
    func `AtRule for max-width breakpoint`() {
        let atRule = HTML.AtRule(rawValue: "@media (max-width: 576px)")
        #expect(atRule.rawValue == "@media (max-width: 576px)")
    }

    @Test
    func `AtRule for combined breakpoints`() {
        let atRule = HTML.AtRule(rawValue: "@media (min-width: 768px) and (max-width: 991px)")
        #expect(atRule.rawValue.contains("min-width"))
        #expect(atRule.rawValue.contains("max-width"))
    }

    // MARK: - Integration

    @Test
    func `AtRule used with StyleKey`() {
        let atRule = HTML.AtRule(rawValue: "@media print")
        let styleKey = HTML.StyleKey(atRule, ".no-print")

        #expect(styleKey.atRule == atRule)
        #expect(styleKey.selector == ".no-print")
    }
}
