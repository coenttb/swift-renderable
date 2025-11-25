//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// Conformance of `Never` to `HTML` to support the type system.
///
/// This conformance is provided to allow the use of the `HTML` protocol in
/// contexts where no content is expected or possible.
extension Never: HTML {
    public static func _render(_ html: Self, into printer: inout HTMLPrinter) {}

    @inlinable
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {}

    public var body: Never { fatalError() }
}
