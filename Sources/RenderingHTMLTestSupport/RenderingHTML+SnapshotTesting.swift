//
//  File.swift
//  swift-html
//
//  Created by Coen ten Thije Boonkkamp on 02/04/2025.
//

public import RenderingHTML
import SnapshotTesting

extension Snapshotting where Value: RenderingHTML.HTMLDocumentProtocol, Format == String {
    public static var html: Self {
        .html()
    }

    public static func html(
        printerConfiguration: HTMLContext.Rendering = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            HTMLContext.Rendering.$current.withValue(printerConfiguration) {
                (try? String(value)) ?? "HTML rendering failed"
            }
        }
    }
}

extension Snapshotting where Value: RenderingHTML.HTML, Format == String {
    public static var html: Self {
        .html()
    }

    public static func html(
        printerConfiguration: HTMLContext.Rendering = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            HTMLContext.Rendering.$current.withValue(printerConfiguration) {
                (try? String(value)) ?? "HTML rendering failed"
            }
        }
    }
}
