//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

/// Allows optional values to be used as HTML elements.
///
/// This conformance allows for convenient handling of optional HTML content,
/// where `nil` values simply render nothing.
extension Optional: HTML where Wrapped: HTML {
    /// Renders the optional HTML element if it exists.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        guard let html else { return }
        Wrapped._render(html, into: &buffer, context: &context)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}
