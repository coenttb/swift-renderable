//
//  HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

/// Namespace for HTML-related types.
///
/// The `HTML` enum provides a namespace for all HTML rendering types,
/// similar to how SwiftUI uses namespacing. The main protocol is
/// available as `HTML.View`.
///
/// Example:
/// ```swift
/// struct MyPage: HTML.View {
///     var body: some HTML.View {
///         HTML.Element(tag: "div") {
///             HTML.Text("Hello, World!")
///         }
///     }
/// }
/// ```
public enum HTML {}

extension HTML {
    public static var tag: HTML.Tag.Type {
        HTML.Tag.self
    }
}

extension HTML {
    /// &quot; - Double quotation mark HTML entity
    package static let doubleQuotationMark: [UInt8] = [
        .ascii.ampersand,
        .ascii.q,
        .ascii.u,
        .ascii.o,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &#39; - Apostrophe HTML entity
    package static let apostrophe: [UInt8] = [
        .ascii.ampersand,
        .ascii.numberSign,
        .ascii.3,
        .ascii.9,
        .ascii.semicolon
    ]

    /// &amp; - Ampersand HTML entity
    package static let ampersand: [UInt8] = [
        .ascii.ampersand,
        .ascii.a,
        .ascii.m,
        .ascii.p,
        .ascii.semicolon
    ]

    /// &lt; - Less-than HTML entity
    package static let lessThan: [UInt8] = [
        .ascii.ampersand,
        .ascii.l,
        .ascii.t,
        .ascii.semicolon
    ]

    /// &gt; - Greater-than HTML entity
    package static let greaterThan: [UInt8] = [
        .ascii.ampersand,
        .ascii.g,
        .ascii.t,
        .ascii.semicolon
    ]
}
