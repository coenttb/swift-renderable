//
//  CustomStringConvertible.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

/// Provides a default `description` implementation for HTML types that also conform to `CustomStringConvertible`.
///
/// This allows any HTML element to be printed or interpolated into strings,
/// automatically rendering its HTML representation.
///
/// ## Example
///
/// ```swift
/// struct Greeting: HTML, CustomStringConvertible {
///     var body: some HTML {
///         tag("div") { HTMLText("Hello!") }
///     }
/// }
///
/// let greeting = Greeting()
/// print(greeting) // Prints: <div>Hello!</div>
/// ```
extension CustomStringConvertible where Self: HTML {
    public var description: String {
        String(decoding: self.bytes, as: UTF8.self)
    }
}
