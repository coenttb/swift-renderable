//
//  File.swift
//  swift-html
//
//  Created by Coen ten Thije Boonkkamp on 02/04/2025.
//

public import Rendering_HTML
import Rendering_TestSupport

extension Snapshotting where Value: HTML.DocumentProtocol, Format == String {
    public static var html: Self {
        .html()
    }

    public static func html(
        printerConfiguration: HTML.Context.Configuration = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            HTML.Context.Configuration.$current.withValue(printerConfiguration) {
                (try? String(value)) ?? "HTML rendering failed"
            }
        }
    }
}

extension Snapshotting where Value: HTML.View, Format == String {
    public static var html: Self {
        .html()
    }

    public static func html(
        printerConfiguration: HTML.Context.Configuration = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            HTML.Context.Configuration.$current.withValue(printerConfiguration) {
                (try? String(value)) ?? "HTML rendering failed"
            }
        }
    }
}
