//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

// Protocol to enable type erasure for HTMLInlineStyle
protocol HTMLInlineStyleProtocol {
    func extractStyles() -> [Style]
    func extractContent() -> any HTML
}
