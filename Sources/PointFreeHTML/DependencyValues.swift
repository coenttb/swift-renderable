//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 25/11/2025.
//

public import Dependencies

extension DependencyValues {
    /// The HTML printer to use for rendering HTML.
    ///
    /// This dependency allows for customization of HTML rendering
    /// without having to pass a printer explicitly.
    public var htmlPrinter: HTMLPrinter {
        get { self[HTMLPrinterKey.self] }
        set { self[HTMLPrinterKey.self] = newValue }
    }
}

/// Private key for the HTML printer dependency.
private enum HTMLPrinterKey: DependencyKey {
    /// Default printer for production use.
    static var liveValue: HTMLPrinter { HTMLPrinter() }

    /// Pretty-printing printer for preview use.
    static var previewValue: HTMLPrinter { HTMLPrinter(.pretty) }

    /// Pretty-printing printer for test use.
    static var testValue: HTMLPrinter { HTMLPrinter(.default) }
}
