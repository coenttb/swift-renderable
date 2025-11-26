//
//  HTML.InlineStyle.Protocol.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Rendering

// Protocol to enable type erasure for HTML.InlineStyle
protocol HTMLInlineStyleProtocol {
    func extractStyles() -> [HTML.Style]
    func extractContent() -> any HTML.View
}
