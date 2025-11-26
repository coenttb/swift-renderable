//
//  StyleKey Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import Rendering_HTML
import Rendering_HTML_TestSupport
import Testing

@Suite
struct `StyleKey Tests` {

    // MARK: - Initialization

    @Test
    func `StyleKey initialization without atRule`() {
        let key = HTML.StyleKey(nil, ".my-class")
        #expect(key.atRule == nil)
        #expect(key.selector == ".my-class")
    }

    @Test
    func `StyleKey initialization with atRule`() {
        let atRule = HTML.AtRule(rawValue: "@media (max-width: 768px)")
        let key = HTML.StyleKey(atRule, ".mobile-class")
        #expect(key.atRule?.rawValue == "@media (max-width: 768px)")
        #expect(key.selector == ".mobile-class")
    }

    // MARK: - Hashable Conformance

    @Test
    func `StyleKey equality - same values`() {
        let key1 = HTML.StyleKey(nil, ".test")
        let key2 = HTML.StyleKey(nil, ".test")
        #expect(key1 == key2)
    }

    @Test
    func `StyleKey equality - different selectors`() {
        let key1 = HTML.StyleKey(nil, ".test1")
        let key2 = HTML.StyleKey(nil, ".test2")
        #expect(key1 != key2)
    }

    @Test
    func `StyleKey equality - different atRules`() {
        let atRule1 = HTML.AtRule(rawValue: "@media print")
        let atRule2 = HTML.AtRule(rawValue: "@media screen")
        let key1 = HTML.StyleKey(atRule1, ".test")
        let key2 = HTML.StyleKey(atRule2, ".test")
        #expect(key1 != key2)
    }

    @Test
    func `StyleKey equality - nil vs non-nil atRule`() {
        let atRule = HTML.AtRule(rawValue: "@media print")
        let key1 = HTML.StyleKey(nil, ".test")
        let key2 = HTML.StyleKey(atRule, ".test")
        #expect(key1 != key2)
    }

    @Test
    func `StyleKey equality - same atRule and selector`() {
        let atRule = HTML.AtRule(rawValue: "@media print")
        let key1 = HTML.StyleKey(atRule, ".print-class")
        let key2 = HTML.StyleKey(atRule, ".print-class")
        #expect(key1 == key2)
    }

    // MARK: - Hash Value

    @Test
    func `StyleKey hash consistency`() {
        let key1 = HTML.StyleKey(nil, ".test")
        let key2 = HTML.StyleKey(nil, ".test")
        #expect(key1.hashValue == key2.hashValue)
    }

    @Test
    func `StyleKey different keys have different hashes`() {
        let key1 = HTML.StyleKey(nil, ".class1")
        let key2 = HTML.StyleKey(nil, ".class2")
        // Hash values could theoretically collide, but should be different for different values
        // We mainly test that the hashable conformance works
        var set = Set<HTML.StyleKey>()
        set.insert(key1)
        set.insert(key2)
        #expect(set.count == 2)
    }

    // MARK: - Use in Dictionary

    @Test
    func `StyleKey as dictionary key`() {
        var styles: [HTML.StyleKey: String] = [:]

        let key1 = HTML.StyleKey(nil, ".class1")
        let key2 = HTML.StyleKey(nil, ".class2")
        let atRule = HTML.AtRule(rawValue: "@media print")
        let key3 = HTML.StyleKey(atRule, ".print-class")

        styles[key1] = "color: red"
        styles[key2] = "color: blue"
        styles[key3] = "display: block"

        #expect(styles[key1] == "color: red")
        #expect(styles[key2] == "color: blue")
        #expect(styles[key3] == "display: block")
        #expect(styles.count == 3)
    }

    @Test
    func `StyleKey overwrites existing value`() {
        var styles: [HTML.StyleKey: String] = [:]
        let key = HTML.StyleKey(nil, ".test")

        styles[key] = "color: red"
        styles[key] = "color: blue"

        #expect(styles[key] == "color: blue")
        #expect(styles.count == 1)
    }

    // MARK: - Use in Set

    @Test
    func `StyleKey in Set`() {
        var keySet = Set<HTML.StyleKey>()

        let key1 = HTML.StyleKey(nil, ".class1")
        let key2 = HTML.StyleKey(nil, ".class2")
        let key1Duplicate = HTML.StyleKey(nil, ".class1")

        keySet.insert(key1)
        keySet.insert(key2)
        keySet.insert(key1Duplicate)

        #expect(keySet.count == 2)
        #expect(keySet.contains(key1))
        #expect(keySet.contains(key2))
    }

    // MARK: - Sendable Conformance

    @Test
    func `StyleKey is Sendable`() async {
        let key = HTML.StyleKey(nil, ".test")

        // Test that StyleKey can be used across task boundaries
        let result = await Task {
            return key.selector
        }.value

        #expect(result == ".test")
    }

    // MARK: - Realistic Usage

    @Test
    func `StyleKey with class selector`() {
        let key = HTML.StyleKey(nil, ".button")
        #expect(key.selector == ".button")
    }

    @Test
    func `StyleKey with ID selector`() {
        let key = HTML.StyleKey(nil, "#header")
        #expect(key.selector == "#header")
    }

    @Test
    func `StyleKey with compound selector`() {
        let key = HTML.StyleKey(nil, ".btn.btn-primary")
        #expect(key.selector == ".btn.btn-primary")
    }

    @Test
    func `StyleKey with media query`() {
        let atRule = HTML.AtRule(rawValue: "@media (min-width: 1200px)")
        let key = HTML.StyleKey(atRule, ".container")
        #expect(key.atRule?.rawValue == "@media (min-width: 1200px)")
        #expect(key.selector == ".container")
    }
}
