//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension HTML.Tag {
    package enum Inline: String, CaseIterable {
        case a = "a"
        case abbr = "abbr"
        case acronym = "acronym"
        case b = "b"
        case bdo = "bdo"
        case big = "big"
        case br = "br"
        case button = "button"
        case cite = "cite"
        case code = "code"
        case del = "del"
        case dfn = "dfn"
        case em = "em"
        case i = "i"
        case img = "img"
        case input = "input"
        case ins = "ins"
        case kbd = "kbd"
        case label = "label"
        case map = "map"
        case mark = "mark"
        case object = "object"
        case output = "output"
        case q = "q"
        case s = "s"
        case samp = "samp"
        case script = "script"
        case select = "select"
        case small = "small"
        case span = "span"
        case strong = "strong"
        case sub = "sub"
        case sup = "sup"
        case textarea = "textarea"
        case time = "time"
        case tt = "tt"
        case u = "u"
        case `var` = "var"
    }
}
