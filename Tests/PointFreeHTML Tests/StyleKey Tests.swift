//
//  StyleKey Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

@testable import PointFreeHTML
import PointFreeHTMLTestSupport
import Testing

@Suite("StyleKey Tests")
struct StyleKeyTests {

    // MARK: - Initialization

    @Test("StyleKey initialization without atRule")
    func initWithoutAtRule() {
        let key = StyleKey(nil, ".my-class")
        #expect(key.atRule == nil)
        #expect(key.selector == ".my-class")
    }

    @Test("StyleKey initialization with atRule")
    func initWithAtRule() {
        let atRule = AtRule(rawValue: "@media (max-width: 768px)")
        let key = StyleKey(atRule, ".mobile-class")
        #expect(key.atRule?.rawValue == "@media (max-width: 768px)")
        #expect(key.selector == ".mobile-class")
    }

    // MARK: - Hashable Conformance

    @Test("StyleKey equality - same values")
    func equalitySameValues() {
        let key1 = StyleKey(nil, ".test")
        let key2 = StyleKey(nil, ".test")
        #expect(key1 == key2)
    }

    @Test("StyleKey equality - different selectors")
    func equalityDifferentSelectors() {
        let key1 = StyleKey(nil, ".test1")
        let key2 = StyleKey(nil, ".test2")
        #expect(key1 != key2)
    }

    @Test("StyleKey equality - different atRules")
    func equalityDifferentAtRules() {
        let atRule1 = AtRule(rawValue: "@media print")
        let atRule2 = AtRule(rawValue: "@media screen")
        let key1 = StyleKey(atRule1, ".test")
        let key2 = StyleKey(atRule2, ".test")
        #expect(key1 != key2)
    }

    @Test("StyleKey equality - nil vs non-nil atRule")
    func equalityNilVsNonNilAtRule() {
        let atRule = AtRule(rawValue: "@media print")
        let key1 = StyleKey(nil, ".test")
        let key2 = StyleKey(atRule, ".test")
        #expect(key1 != key2)
    }

    @Test("StyleKey equality - same atRule and selector")
    func equalitySameAtRuleAndSelector() {
        let atRule = AtRule(rawValue: "@media print")
        let key1 = StyleKey(atRule, ".print-class")
        let key2 = StyleKey(atRule, ".print-class")
        #expect(key1 == key2)
    }

    // MARK: - Hash Value

    @Test("StyleKey hash consistency")
    func hashConsistency() {
        let key1 = StyleKey(nil, ".test")
        let key2 = StyleKey(nil, ".test")
        #expect(key1.hashValue == key2.hashValue)
    }

    @Test("StyleKey different keys have different hashes")
    func differentKeysHaveDifferentHashes() {
        let key1 = StyleKey(nil, ".class1")
        let key2 = StyleKey(nil, ".class2")
        // Hash values could theoretically collide, but should be different for different values
        // We mainly test that the hashable conformance works
        var set = Set<StyleKey>()
        set.insert(key1)
        set.insert(key2)
        #expect(set.count == 2)
    }

    // MARK: - Use in Dictionary

    @Test("StyleKey as dictionary key")
    func asDictionaryKey() {
        var styles: [StyleKey: String] = [:]

        let key1 = StyleKey(nil, ".class1")
        let key2 = StyleKey(nil, ".class2")
        let atRule = AtRule(rawValue: "@media print")
        let key3 = StyleKey(atRule, ".print-class")

        styles[key1] = "color: red"
        styles[key2] = "color: blue"
        styles[key3] = "display: block"

        #expect(styles[key1] == "color: red")
        #expect(styles[key2] == "color: blue")
        #expect(styles[key3] == "display: block")
        #expect(styles.count == 3)
    }

    @Test("StyleKey overwrites existing value")
    func overwritesExistingValue() {
        var styles: [StyleKey: String] = [:]
        let key = StyleKey(nil, ".test")

        styles[key] = "color: red"
        styles[key] = "color: blue"

        #expect(styles[key] == "color: blue")
        #expect(styles.count == 1)
    }

    // MARK: - Use in Set

    @Test("StyleKey in Set")
    func inSet() {
        var keySet = Set<StyleKey>()

        let key1 = StyleKey(nil, ".class1")
        let key2 = StyleKey(nil, ".class2")
        let key1Duplicate = StyleKey(nil, ".class1")

        keySet.insert(key1)
        keySet.insert(key2)
        keySet.insert(key1Duplicate)

        #expect(keySet.count == 2)
        #expect(keySet.contains(key1))
        #expect(keySet.contains(key2))
    }

    // MARK: - Sendable Conformance

    @Test("StyleKey is Sendable")
    func isSendable() async {
        let key = StyleKey(nil, ".test")

        // Test that StyleKey can be used across task boundaries
        let result = await Task {
            return key.selector
        }.value

        #expect(result == ".test")
    }

    // MARK: - Realistic Usage

    @Test("StyleKey with class selector")
    func withClassSelector() {
        let key = StyleKey(nil, ".button")
        #expect(key.selector == ".button")
    }

    @Test("StyleKey with ID selector")
    func withIDSelector() {
        let key = StyleKey(nil, "#header")
        #expect(key.selector == "#header")
    }

    @Test("StyleKey with compound selector")
    func withCompoundSelector() {
        let key = StyleKey(nil, ".btn.btn-primary")
        #expect(key.selector == ".btn.btn-primary")
    }

    @Test("StyleKey with media query")
    func withMediaQuery() {
        let atRule = AtRule(rawValue: "@media (min-width: 1200px)")
        let key = StyleKey(atRule, ".container")
        #expect(key.atRule?.rawValue == "@media (min-width: 1200px)")
        #expect(key.selector == ".container")
    }
}
