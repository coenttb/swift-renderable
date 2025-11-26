//
//  HTML.Style Tests.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

@testable import Rendering_HTML
import Testing

@Suite
struct `HTML.Style Tests` {

    // MARK: - Initialization

    @Test
    func `Style stores property and value`() {
        let style = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        #expect(style.property == "color")
        #expect(style.value == "red")
    }

    @Test
    func `Style stores optional components`() {
        let style = HTML.Style(
            property: "display",
            value: "none",
            atRule: HTML.AtRule(rawValue: "(min-width: 768px)"),
            selector: HTML.Selector.class("container"),
            pseudo: .hover
        )
        #expect(style.property == "display")
        #expect(style.value == "none")
        #expect(style.atRule != nil)
        #expect(style.selector != nil)
        #expect(style.pseudo != nil)
    }

    // MARK: - Hashable

    @Test
    func `Style is Hashable`() {
        let style1 = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        let style2 = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        let style3 = HTML.Style(
            property: "color",
            value: "blue",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )

        #expect(style1 == style2)
        #expect(style1 != style3)
    }

    @Test
    func `Style can be used in Set`() {
        let style1 = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        let style2 = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        let style3 = HTML.Style(
            property: "margin",
            value: "10px",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )

        var styles: Set<HTML.Style> = []
        styles.insert(style1)
        styles.insert(style2) // Duplicate
        styles.insert(style3)

        #expect(styles.count == 2)
    }

    // MARK: - Sendable

    @Test
    func `Style is Sendable`() {
        let style = HTML.Style(
            property: "color",
            value: "red",
            atRule: nil,
            selector: nil,
            pseudo: nil
        )
        Task {
            _ = style
        }
        #expect(true) // Compile-time check
    }
}
