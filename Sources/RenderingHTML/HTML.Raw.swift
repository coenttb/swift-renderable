//
//  HTML.Raw.swift
//
//
//  Created by Point-Free, Inc
//

public import Rendering

// Public typealias to disambiguate between the Rendering module and Rendering protocol
// when accessing the Raw type from the Rendering module.
public typealias RenderingRaw = Raw

extension HTML {
    /// Represents raw, unescaped HTML content.
    ///
    /// `HTML.Raw` allows you to insert raw HTML content without any escaping or processing.
    /// This is useful when you need to include pre-generated HTML or for special cases
    /// where you need to bypass the normal HTML generation mechanism.
    ///
    /// Example:
    /// ```swift
    /// var body: some HTML.View {
    ///     div {
    ///         // Normal, escaped content
    ///         p { "Regular <p> content will be escaped" }
    ///
    ///         // Raw, unescaped content
    ///         HTML.Raw("<script>console.log('This is raw JS');</script>")
    ///     }
    /// }
    /// ```
    ///
    /// - Warning: Using `HTML.Raw` with user-provided content can lead to security
    ///   vulnerabilities such as cross-site scripting (XSS) attacks. Only use
    ///   `HTML.Raw` with trusted content that you have full control over.
    ///
    /// Note: This is a typealias to the `Raw` type from the Rendering module.
    /// The same `Raw` type can be used for HTML, SVG, XML, or any other rendering context.
    public typealias Raw = RenderingRaw
}

// Give Raw (from Rendering module) the HTML.View conformance
extension Raw: Rendering {
    public typealias Content = Never
    public typealias Context = HTML.Context

    /// Renders the raw bytes directly to the buffer without any processing.
    public static func _render<Buffer: RangeReplaceableCollection>(
        _ raw: Self,
        into buffer: inout Buffer,
        context: inout HTML.Context
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: raw.bytes)
    }

    /// This type uses direct rendering and doesn't have a body.
    public var body: Never { fatalError() }
}

extension Raw: HTML.View {}
