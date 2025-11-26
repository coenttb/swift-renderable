//
//  Builder+HTML.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering
public typealias BuilderRaw = Builder

extension Builder {
    /// Creates an empty HTML component when no content is provided.
    ///
    /// - Returns: An empty HTML component.
    public static func buildBlock() -> Empty {
        Empty()
    }

    /// Converts a text expression to HTML text.
    ///
    /// - Parameter expression: The HTML text to convert.
    /// - Returns: The same HTML text.
    public static func buildExpression(_ expression: HTML.Text) -> HTML.Text {
        expression
    }
}

extension HTML {
    public typealias Builder = BuilderRaw
}
