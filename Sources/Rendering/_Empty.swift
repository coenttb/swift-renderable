//
//  Empty.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// An empty rendering type that produces no output.
///
/// Use `Empty` when you need to satisfy a type requirement but don't want
/// to produce any rendered content.
public struct _Empty<Context>: Rendering, Sendable {
    public typealias Content = Never

    public init() {}

    public static func _render<Buffer: RangeReplaceableCollection>(
        _ markup: _Empty,
        into buffer: inout Buffer,
        context: inout Context
    ) where Buffer.Element == UInt8 {
        // Produces no output
    }

    public var body: Never { fatalError() }
}
