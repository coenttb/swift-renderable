//
//  HTMLRaw.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

/// Represents raw, unescaped HTML content.
///
/// `HTMLRaw` allows you to insert raw HTML content without any escaping or processing.
/// This is useful when you need to include pre-generated HTML or for special cases
/// where you need to bypass the normal HTML generation mechanism.
///
/// Example:
/// ```swift
/// var body: some HTML {
///     div {
///         // Normal, escaped content
///         p { "Regular <p> content will be escaped" }
///
///         // Raw, unescaped content
///         HTMLRaw("<script>console.log('This is raw JS');</script>")
///     }
/// }
/// ```
///
/// - Warning: Using `HTMLRaw` with user-provided content can lead to security
///   vulnerabilities such as cross-site scripting (XSS) attacks. Only use
///   `HTMLRaw` with trusted content that you have full control over.
public typealias HTMLRaw = Raw

extension Raw: Rendering {
    public typealias Content = Never
    public typealias Context = HTMLContext

    /// Renders the raw HTML bytes directly to the buffer without any processing.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ html: Self,
        into buffer: inout Buffer,
        context: inout HTMLContext
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: html.bytes)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension Raw: HTML {}
