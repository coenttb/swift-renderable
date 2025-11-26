//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

extension HTML {
    /// Represents a CSS style with its property, value, and selectors.
    ///
    /// Used internally for tracking styles and generating deterministic class names.
    package struct Style: Hashable, Sendable {
        let property: String
        let value: String
        let atRule: HTML.AtRule?
        let selector: HTML.Selector?
        let pseudo: HTML.Pseudo?
    }
}
