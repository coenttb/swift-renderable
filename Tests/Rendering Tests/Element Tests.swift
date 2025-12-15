//
//  Element Tests.swift
//  swift-renderable
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import OrderedCollections
import Testing

@testable import Rendering

@Suite
struct `Element Tests` {

    // MARK: - Initialization

    @Test
    func `Element can be created with minimal parameters`() {
        let element = Rendering.Element<String>(
            tagName: "div",
            content: "hello"
        )
        #expect(element.tagName == "div")
        #expect(element.content == "hello")
        #expect(element.isBlock == true)
        #expect(element.isVoid == false)
        #expect(element.preservesWhitespace == false)
        #expect(element.attributes.isEmpty)
    }

    @Test
    func `Element can be created with all parameters`() {
        let element = Rendering.Element<String>(
            tagName: "input",
            isBlock: false,
            isVoid: true,
            preservesWhitespace: false,
            attributes: ["type": "text", "name": "email"],
            content: nil
        )
        #expect(element.tagName == "input")
        #expect(element.isBlock == false)
        #expect(element.isVoid == true)
        #expect(element.content == nil)
        #expect(element.attributes["type"] == "text")
        #expect(element.attributes["name"] == "email")
    }

    @Test
    func `Element preservesWhitespace can be set`() {
        let element = Rendering.Element<String>(
            tagName: "pre",
            preservesWhitespace: true,
            content: "  code  "
        )
        #expect(element.preservesWhitespace == true)
    }

    // MARK: - Tag Names

    @Test(arguments: [
        "div", "span", "p", "a", "img", "br", "hr",
        "h1", "h2", "h3", "h4", "h5", "h6",
        "ul", "ol", "li", "table", "tr", "td",
        "form", "input", "button", "select", "textarea",
        "header", "footer", "main", "nav", "aside", "article", "section",
    ])
    func `Element accepts common HTML tag names`(tagName: String) {
        let element = Rendering.Element<String>(tagName: tagName, content: nil)
        #expect(element.tagName == tagName)
    }

    @Test
    func `Element accepts custom tag names`() {
        let element = Rendering.Element<String>(tagName: "my-custom-component", content: nil)
        #expect(element.tagName == "my-custom-component")
    }

    // MARK: - Attributes

    @Test
    func `attribute modifier adds single attribute`() {
        let element = Rendering.Element<String>(tagName: "div", content: nil)
            .attribute("class", "container")

        #expect(element.attributes["class"] == "container")
    }

    @Test
    func `attribute modifier chains multiple attributes`() {
        let element = Rendering.Element<String>(tagName: "div", content: nil)
            .attribute("class", "container")
            .attribute("id", "main")
            .attribute("data-value", "123")

        #expect(element.attributes["class"] == "container")
        #expect(element.attributes["id"] == "main")
        #expect(element.attributes["data-value"] == "123")
    }

    @Test
    func `attribute modifier with nil value does not add attribute`() {
        let element = Rendering.Element<String>(tagName: "div", content: nil)
            .attribute("class", nil)

        #expect(element.attributes["class"] == nil)
    }

    @Test
    func `attribute modifier with empty string adds empty attribute`() {
        let element = Rendering.Element<String>(tagName: "input", content: nil)
            .attribute("disabled", "")

        #expect(element.attributes["disabled"] == "")
    }

    @Test
    func `attribute modifier overwrites existing attribute`() {
        let element = Rendering.Element<String>(tagName: "div", content: nil)
            .attribute("class", "first")
            .attribute("class", "second")

        #expect(element.attributes["class"] == "second")
    }

    @Test
    func `modifyingAttributes allows custom modifications`() {
        let element = Rendering.Element<String>(
            tagName: "div",
            attributes: ["class": "original"],
            content: nil
        ).modifyingAttributes { attrs in
            attrs["class"] = "modified"
            attrs["id"] = "new"
        }

        #expect(element.attributes["class"] == "modified")
        #expect(element.attributes["id"] == "new")
    }

    @Test
    func `attributes preserve insertion order`() {
        let element = Rendering.Element<String>(tagName: "div", content: nil)
            .attribute("z-index", "1")
            .attribute("alpha", "a")
            .attribute("beta", "b")

        let keys = Array(element.attributes.keys)
        #expect(keys == ["z-index", "alpha", "beta"])
    }

    // MARK: - Content Types

    @Test
    func `Element can hold String content`() {
        let element = Rendering.Element<String>(tagName: "p", content: "text")
        #expect(element.content == "text")
    }

    @Test
    func `Element can hold Int content`() {
        let element = Rendering.Element<Int>(tagName: "span", content: 42)
        #expect(element.content == 42)
    }

    @Test
    func `Element can hold nil content`() {
        let element = Rendering.Element<String>(tagName: "br", content: nil)
        #expect(element.content == nil)
    }

    @Test
    func `Element can hold array content`() {
        let element = Rendering.Element<[String]>(tagName: "ul", content: ["a", "b", "c"])
        #expect(element.content == ["a", "b", "c"])
    }

    // MARK: - Conditional Conformances

    @Test
    func `Element is Sendable when Content is Sendable`() {
        let element = Rendering.Element<String>(tagName: "div", content: "test")
        Task {
            _ = element.tagName
        }
        #expect(Bool(true))  // Compile-time check
    }

    @Test
    func `Element is Equatable when Content is Equatable`() {
        let element1 = Rendering.Element<String>(tagName: "div", content: "test")
        let element2 = Rendering.Element<String>(tagName: "div", content: "test")
        let element3 = Rendering.Element<String>(tagName: "span", content: "test")

        #expect(element1 == element2)
        #expect(element1 != element3)
    }

    @Test
    func `Element equality considers attributes`() {
        let element1 = Rendering.Element<String>(tagName: "div", content: "test")
            .attribute("class", "a")
        let element2 = Rendering.Element<String>(tagName: "div", content: "test")
            .attribute("class", "a")
        let element3 = Rendering.Element<String>(tagName: "div", content: "test")
            .attribute("class", "b")

        #expect(element1 == element2)
        #expect(element1 != element3)
    }

    @Test
    func `Element is Hashable when Content is Hashable`() {
        let element1 = Rendering.Element<String>(tagName: "div", content: "test")
        let element2 = Rendering.Element<String>(tagName: "div", content: "test")

        var set: Set<Rendering.Element<String>> = []
        set.insert(element1)

        #expect(set.contains(element2))
    }

    // MARK: - Void Elements

    @Test(arguments: ["br", "hr", "img", "input", "meta", "link"])
    func `void elements have no content`(tagName: String) {
        let element = Rendering.Element<String>(
            tagName: tagName,
            isVoid: true,
            content: nil
        )
        #expect(element.isVoid == true)
        #expect(element.content == nil)
    }

    // MARK: - Block vs Inline

    @Test(arguments: ["div", "p", "h1", "ul", "table", "form"])
    func `block elements default to isBlock true`(tagName: String) {
        let element = Rendering.Element<String>(tagName: tagName, content: nil)
        #expect(element.isBlock == true)
    }

    @Test
    func `inline elements can set isBlock to false`() {
        let element = Rendering.Element<String>(
            tagName: "span",
            isBlock: false,
            content: "inline"
        )
        #expect(element.isBlock == false)
    }
}
