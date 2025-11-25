//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// A composite key for the styles dictionary, combining at-rule and selector.
///
/// This flattened structure avoids nested dictionary lookups and improves performance.
public struct StyleKey: Hashable, Sendable {
    public let atRule: AtRule?
    public let selector: String
    
    public init(_ atRule: AtRule?, _ selector: String) {
        self.atRule = atRule
        self.selector = selector
    }
}
