//
//  File.swift
//  swift-html
//
//  Created by Coen ten Thije Boonkkamp on 02/04/2025.
//

import Dependencies
import Foundation
import PointFreeHTML
import SnapshotTesting

extension Snapshotting where Value: PointFreeHTML.HTMLDocumentProtocol, Format == String {
    public static var html: Self {
        Snapshotting<String, String>.lines.pullback { value in
            return withDependencies {
                $0.htmlPrinter = .init(.pretty)
            } operation: {
                String(bytes: value.render(), encoding: .utf8) ?? "HTML rendering failed"
            }
        }
    }
}

extension Snapshotting where Value: HTML, Format == String {
    public static var html: Self {
        Snapshotting<String, String>.lines.pullback { value in

            return withDependencies {
                $0.htmlPrinter = .init(.pretty)
            } operation: {
                String(bytes: value.render(), encoding: .utf8) ?? "HTML rendering failed"
            }
        }
    }
}
