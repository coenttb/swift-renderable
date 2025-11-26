//
//  File.swift
//  swift-html
//
//  Created by Coen ten Thije Boonkkamp on 02/04/2025.
//

public import PointFreeHTML
import SnapshotTesting

extension Snapshotting where Value: PointFreeHTML.HTMLDocumentProtocol, Format == String {
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

extension Snapshotting where Value: PointFreeHTML.HTML, Format == String {
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
