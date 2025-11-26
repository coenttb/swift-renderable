//
//  AnyHTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

import Rendering

/// Type-erased wrapper for any HTML content.
public struct AnyHTML {
    let base: any HTML
    public init(_ base: any HTML) {
        self.base = base
    }
}

extension AnyHTML: HTML {
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: AnyHTML,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        func render<T: HTML>(_ html: T) {
            T._render(html, into: &buffer, context: &context)
        }
        render(html.base)
    }

    public var body: Never { fatalError() }
}

extension AnyHTML {
    public init(
        @Builder _ closure: () -> any HTML
    ) {
        self = .init(closure())
    }
}
