//
//  RangeReplaceableCollection+HTML.swift
//  pointfree-html
//
//  Created by Coen ten Thije Boonkkamp on 26/11/2025.
//

import Rendering

extension Collection<UInt8> {
    public static var html: HTML.Type {
        HTML.self
    }
}
