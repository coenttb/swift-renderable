//
//  File.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 22/07/2025.
//

import Foundation

extension CustomStringConvertible where Self: HTML {
    public var description: String {
        try! String(self)
    }
}
