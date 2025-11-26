//
//  AtRule Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import RenderingHTML
import RenderingHTMLTestSupport
import Testing

@Suite("AtRule Tests")
struct AtRuleTests {

    // MARK: - Initialization

    @Test("AtRule basic initialization")
    func basicInitialization() {
        let atRule = AtRule(rawValue: "@media print")
        #expect(atRule.rawValue == "@media print")
    }

    @Test("AtRule with complex media query")
    func complexMediaQuery() {
        let atRule = AtRule(rawValue: "@media (min-width: 768px) and (max-width: 1024px)")
        #expect(atRule.rawValue == "@media (min-width: 768px) and (max-width: 1024px)")
    }

    @Test("AtRule with screen media")
    func screenMedia() {
        let atRule = AtRule(rawValue: "@media screen")
        #expect(atRule.rawValue == "@media screen")
    }

    // MARK: - RawRepresentable

    @Test("AtRule RawRepresentable conformance")
    func rawRepresentable() {
        let atRule = AtRule(rawValue: "@media (hover: hover)")
        let recreated = AtRule(rawValue: atRule.rawValue)
        #expect(atRule == recreated)
    }

    // MARK: - Hashable

    @Test("AtRule equality - same values")
    func equalitySameValues() {
        let atRule1 = AtRule(rawValue: "@media print")
        let atRule2 = AtRule(rawValue: "@media print")
        #expect(atRule1 == atRule2)
    }

    @Test("AtRule equality - different values")
    func equalityDifferentValues() {
        let atRule1 = AtRule(rawValue: "@media print")
        let atRule2 = AtRule(rawValue: "@media screen")
        #expect(atRule1 != atRule2)
    }

    @Test("AtRule in Set")
    func inSet() {
        var atRules = Set<AtRule>()
        let print = AtRule(rawValue: "@media print")
        let screen = AtRule(rawValue: "@media screen")
        let printDuplicate = AtRule(rawValue: "@media print")

        atRules.insert(print)
        atRules.insert(screen)
        atRules.insert(printDuplicate)

        #expect(atRules.count == 2)
    }

    @Test("AtRule as dictionary key")
    func asDictionaryKey() {
        var styles: [AtRule: String] = [:]
        let print = AtRule(rawValue: "@media print")
        let screen = AtRule(rawValue: "@media screen")

        styles[print] = "display: none"
        styles[screen] = "display: block"

        #expect(styles[print] == "display: none")
        #expect(styles[screen] == "display: block")
    }

    // MARK: - Sendable

    @Test("AtRule is Sendable")
    func isSendable() async {
        let atRule = AtRule(rawValue: "@media print")

        let result = await Task {
            atRule.rawValue
        }.value

        #expect(result == "@media print")
    }

    // MARK: - Common Media Queries

    @Test("AtRule for prefers-color-scheme dark")
    func prefersColorSchemeDark() {
        let atRule = AtRule(rawValue: "@media (prefers-color-scheme: dark)")
        #expect(atRule.rawValue.contains("prefers-color-scheme"))
        #expect(atRule.rawValue.contains("dark"))
    }

    @Test("AtRule for prefers-reduced-motion")
    func prefersReducedMotion() {
        let atRule = AtRule(rawValue: "@media (prefers-reduced-motion: reduce)")
        #expect(atRule.rawValue.contains("prefers-reduced-motion"))
    }

    @Test("AtRule for orientation")
    func orientation() {
        let landscape = AtRule(rawValue: "@media (orientation: landscape)")
        let portrait = AtRule(rawValue: "@media (orientation: portrait)")
        #expect(landscape.rawValue.contains("landscape"))
        #expect(portrait.rawValue.contains("portrait"))
    }

    // MARK: - Breakpoints

    @Test("AtRule for min-width breakpoint")
    func minWidthBreakpoint() {
        let atRule = AtRule(rawValue: "@media (min-width: 1200px)")
        #expect(atRule.rawValue == "@media (min-width: 1200px)")
    }

    @Test("AtRule for max-width breakpoint")
    func maxWidthBreakpoint() {
        let atRule = AtRule(rawValue: "@media (max-width: 576px)")
        #expect(atRule.rawValue == "@media (max-width: 576px)")
    }

    @Test("AtRule for combined breakpoints")
    func combinedBreakpoints() {
        let atRule = AtRule(rawValue: "@media (min-width: 768px) and (max-width: 991px)")
        #expect(atRule.rawValue.contains("min-width"))
        #expect(atRule.rawValue.contains("max-width"))
    }

    // MARK: - Integration

    @Test("AtRule used with StyleKey")
    func usedWithStyleKey() {
        let atRule = AtRule(rawValue: "@media print")
        let styleKey = StyleKey(atRule, ".no-print")

        #expect(styleKey.atRule == atRule)
        #expect(styleKey.selector == ".no-print")
    }
}
