//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public struct AnyHTML: HTML {
    let base: any HTML
    public init(_ base: any HTML) {
        self.base = base
    }
    public static func _render(_ html: AnyHTML, into printer: inout HTMLPrinter) {
        func render<T: HTML>(_ html: T) {
            T._render(html, into: &printer)
        }
        render(html.base)
    }

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
        _ closure: () -> any HTML
    ) {
        self = .init(closure())
    }
}
