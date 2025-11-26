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
