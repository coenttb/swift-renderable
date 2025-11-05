//
//  File.swift
//  swift-html
//
//  Created by Coen ten Thije Boonkkamp on 02/04/2025.
//

import Dependencies
import PointFreeHTML
import SnapshotTesting

extension Snapshotting where Value: PointFreeHTML.HTMLDocumentProtocol, Format == String {
    public static var html: Self {
        .html()
    }

    public static func html(
        printerConfiguration: HTMLPrinter.Configuration = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            return withDependencies {
                $0.htmlPrinter = .init(.pretty)
            } operation: {
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
        printerConfiguration: HTMLPrinter.Configuration = .pretty
    ) -> Self {
        Snapshotting<String, String>.lines.pullback { value in
            return withDependencies {
                $0.htmlPrinter = .init(.pretty)
            } operation: {
                (try? String(value)) ?? "HTML rendering failed"
            }
        }
    }
}
