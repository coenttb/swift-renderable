//
//  CustomStringConvertible.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

import Rendering

/// Provides a default `description` implementation for HTML types that also conform to `CustomStringConvertible`.
///
/// This allows any HTML element to be printed or interpolated into strings,
/// automatically rendering its HTML representation.
///
/// ## Example
///
/// ```swift
/// struct Greeting: HTML.View, CustomStringConvertible {
///     var body: some HTML.View {
///         tag("div") { HTML.Text("Hello!") }
///     }
/// }
///
/// let greeting = Greeting()
/// print(greeting) // Prints: <div>Hello!</div>
/// ```
extension CustomStringConvertible where Self: HTML.View {
    public var description: String {
        String(decoding: self.bytes, as: UTF8.self)
    }
}
