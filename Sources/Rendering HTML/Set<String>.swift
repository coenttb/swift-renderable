//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Rendering

extension Set<String> {
    /// A set of HTML tags that are considered inline elements.
    ///
    /// Inline elements are rendered without additional newlines or indentation,
    /// as they typically appear within the flow of text content.
    package static let inlineTags: Self = [
        "a",
        "abbr",
        "acronym",
        "b",
        "bdo",
        "big",
        "br",
        "button",
        "cite",
        "code",
        "del",
        "dfn",
        "em",
        "i",
        "img",
        "input",
        "ins",
        "kbd",
        "label",
        "map",
        "mark",
        "object",
        "output",
        "q",
        "s",
        "samp",
        "script",
        "select",
        "small",
        "span",
        "strong",
        "sub",
        "sup",
        "textarea",
        "time",
        "tt",
        "u",
        "var",
    ]
}
