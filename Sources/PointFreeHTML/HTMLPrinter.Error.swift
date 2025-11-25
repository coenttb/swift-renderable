//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

extension HTMLPrinter {
    /// An error type representing HTML rendering failures.
    ///
    /// This error is thrown when there's a problem rendering HTML content
    /// or when the rendered bytes cannot be converted to a string.
    public struct Error: Swift.Error {
        /// A description of what went wrong during HTML rendering.
        public let message: String
    }
}
